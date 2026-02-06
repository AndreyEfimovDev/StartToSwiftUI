//
//  NotificationCentre.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 14.11.2025.
//
//

import SwiftUI
import SwiftData
import AudioToolbox
import Combine

@MainActor
final class NoticeViewModel: ObservableObject {
    
    private let dataSource: NoticesDataSourceProtocol
    private let hapticManager = HapticService.shared
    private let networkService: NetworkServiceProtocol
    
    @Published var notices: [Notice] = []
    @Published var hasUnreadNotices: Bool = false
    @Published var shouldAnimateNoticeButton = false
    @AppStorage("isNotificationOn") var isNotificationOn: Bool = true
    @AppStorage("isSoundNotificationOn") var isSoundNotificationOn: Bool = true
    
    @Published var errorMessage: String?
    @Published var showErrorMessageAlert: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    private var swiftDataSource: SwiftDataNoticesDataSource? {
        dataSource as? SwiftDataNoticesDataSource
    }
    
    private var appStateManager: AppSyncStateManager? {
        swiftDataSource.map { AppSyncStateManager(modelContext: $0.modelContext) }
    }
    
    var unreadCount: Int {
        notices.filter { !$0.isRead }.count
    }

    var sortedNotices: [Notice] {
        notices.sorted { $0.noticeDate > $1.noticeDate }
    }

    
    init(
        dataSource: NoticesDataSourceProtocol,
        networkService: NetworkServiceProtocol = NetworkService(baseURL: Constants.cloudNoticesURL)
    ) {
        self.dataSource = dataSource
        self.networkService = networkService
        loadNoticesFromSwiftData()
        
        // Subscribing to changes from CloudKit
        setupSubscriptionForChangesInCloud()
        
        Task {
            await importNoticesFromCloud()
        }
    }
    
    /// Convenience initializer for backward compatibility
      convenience init(
          modelContext: ModelContext,
          networkService: NetworkServiceProtocol = NetworkService(baseURL: Constants.cloudNoticesURL)
      ) {
          self.init(
              dataSource: SwiftDataNoticesDataSource(modelContext: modelContext),
              networkService: networkService
          )
      }
    
    
    // MARK: - CloudKit Sync
    private func setupSubscriptionForChangesInCloud() {
        NotificationCenter.default.publisher(for: Notification.Name.NSPersistentStoreRemoteChange)
            .receive(on: DispatchQueue.main)
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadNoticesFromSwiftData()
                log("Cloud notices sync subscribtion run", level: .info)
            }
            .store(in: &cancellables)
    }

    // MARK: - Load Notices
    func loadNoticesFromSwiftData(removeDuplicates: Bool = true) {
        
        // Removing duplicate notices in SwiftUI, leaving only one instance for each ID - for SwiftData only
        if removeDuplicates, let swiftDataSource {
            removeDuplicateNotices(from: swiftDataSource)
        }

        do {
            self.notices = try dataSource.fetchNotices()
            updateUnreadStatus()  // ← always update status when fetch notices
//          let duration = Date().timeIntervalSince(startTime)
//          log("🍉 ✅ Download completed in \(String(format: "%.2f", duration))s. Notifications: \(fetchedNotices.count)", level: .info)
        } catch {
            handleError(error, message: "Error loading notices")
        }
    }
    
    // MARK: - Import from Cloud
    /// Called once upon application startup
    ///
    /// 1. Download from the cloud → get cloudResponse
    /// 2. Filter cloud notices by date - select those later than the last download date → get relevantCloudNotices
    /// 3. Remove local duplicates → removeDuplicateNotices()
    /// 4. Filter by ID → create newNoticesByID with those that don't exist locally only
    /// 5. Add only truly new notices → newNoticesByID. If there are new ones:
    /// - Convert → NoticeMigrationHelper
    /// - Add to context → modelContext.insert()
    /// - Save to SwiftData → saveContext()
    /// - Update UI by load the updated list →  loadNoticesFromSwiftData()
    /// 7. Notify the user:
    /// - markUserNotNotifiedBySound() → set the flag for sound notification
    /// - sendLocalNotification() → system notification (if enabled)
    /// 
    func importNoticesFromCloud() async {
        
        do {
            
            let cloudResponse: [CodableNotice] = try await networkService.fetchDataFromURLAsync()
            
            loadNoticesFromSwiftData() // sync with Cloud
            
            // Filter by date (SwiftData only)
            let relevantNotices: [CodableNotice]
            if let appStateManager, let swiftDataSource {
                let lastDate = appStateManager.getLastNoticeDate() ?? Date.distantPast
                relevantNotices = cloudResponse.filter { $0.noticeDate > lastDate }
                log("🍉 📦 Received \(cloudResponse.count), selected \(relevantNotices.count) notices", level: .info)
                removeDuplicateNotices(from: swiftDataSource)
            } else {
                relevantNotices = cloudResponse
            }
            
            // Filter by ID (general logic)
            let existingIDs = Set(notices.map { $0.id })
            let newNotices = relevantNotices.filter { !existingIDs.contains($0.id) }
            
            guard !newNotices.isEmpty else { return }
            
            // Adding new notices
            for cloudNotice in newNotices {
                dataSource.insert(NoticeMigrationHelper.convertFromCodable(cloudNotice))
            }
            
            // Updating and saving the state
            if let appStateManager {
                if let latestDate = cloudResponse.map({ $0.noticeDate }).max() {
                    appStateManager.updateLatestNoticeDate(latestDate)
                }
                appStateManager.markUserNotNotifiedBySound()
                
                saveContext()
                
                if isNotificationOn {
                    sendLocalNotification(count: newNotices.count)
                }
            } else {
                try dataSource.save()
            }
            
            loadNoticesFromSwiftData(removeDuplicates: false)
            
            log("🍉 ✅ Import complete: \(newNotices.count) notices added", level: .info)
            
        } catch {
            handleError(error, message: "Import error")
        }
    }
    
    // MARK: - Remove Duplicates
    /// Remove duplicate notifications in SwiftUI, leaving only one instance of each ID
    /// Passing Swift DataSource as a parameter avoids double-checking
    private func removeDuplicateNotices(from swiftDataSource: SwiftDataNoticesDataSource) {
        do {
            let allNotices = try swiftDataSource.modelContext.fetch(FetchDescriptor<Notice>())
            
            // Find only groups with duplicates
            let duplicateGroups = Dictionary(grouping: allNotices, by: \.id)
                .filter { $0.value.count > 1 }
            
            guard !duplicateGroups.isEmpty else { return }
            
            log("🍉 🗑️ Found \(duplicateGroups.count) IDs with duplicates", level: .info)
            
            for (id, noticesList) in duplicateGroups {
                log("  🔍 ID \(id): \(noticesList.count) duplicates", level: .info)
                
                // Priority: Read > First
                let noticeToKeep = noticesList.first { $0.isRead } ?? noticesList[0]
                
                // Delete the rest
                for notice in noticesList where notice.persistentModelID != noticeToKeep.persistentModelID {
                    dataSource.delete(notice)
                    log("    ✗ Removed: '\(notice.title)'", level: .info)
                }
            }
            saveContext()
        } catch {
            handleError(error, message: "Error removing duplicates")
        }
    }
    
    // MARK: - Mark all as read
    func markAllAsRead() {
        notices.filter { !$0.isRead }.forEach { $0.isRead = true }
        saveContext()
        updateUnreadStatus()
    }
    
    // MARK: - Update Unread Status
    func updateUnreadStatus() {
        guard !notices.isEmpty else {
                hasUnreadNotices = false
                return
            }

        // Check if there is at least one unread notice
        hasUnreadNotices = notices.contains(where: { !$0.isRead })
    }
    
    // MARK: - Mark as Read
    func markAsRead(_ noticeId: String) {
        guard let notice = notices.first(where: { $0.id == noticeId }) else {
            handleError(nil, message: "Notice with ID \(noticeId) not found")
            return
        }
        setReadStatus(notice, isRead: true)
    }
    
    // MARK: - Toggle Read Status
    func toggleReadStatus(_ notice: Notice?) {
        guard let notice else {
            handleError(nil, message: "Notice is nil")
            return
        }
        setReadStatus(notice, isRead: !notice.isRead)
    }
    
    private func setReadStatus(_ notice: Notice, isRead: Bool) {
        guard notice.isRead != isRead else { return }
        notice.isRead = isRead
        saveContext()
        loadNoticesFromSwiftData()
    }
    
    // MARK: - Delete Notice
    func deleteNotice(_ notice: Notice?) {
        guard let notice else {
            handleError(nil, message: "Notice to delete is nil")
            return
        }
        dataSource.delete(notice)
        saveContext()
        loadNoticesFromSwiftData()  // ← synchronize the array with the datasource
        log("🍉 🗑️ Notice removed, remains: \(notices.count)", level: .info)
    }
    
    // MARK: - Add Notice
    func addNotice(_ notice: Notice) {
        // Checking for duplicates in an already loaded array
        guard !notices.contains(where: { $0.id == notice.id }) else {
            log("🍉 ⚠️ Notice with ID \(notice.id) already exists", level: .info)
            return
        }
        
        do {
            dataSource.insert(notice)
            try dataSource.save()
            loadNoticesFromSwiftData()
            log("🍉 ➕ Notice added, total: \(notices.count)", level: .info)
        } catch {
            handleError(error, message: "Error adding notice")
        }
    }
    
    // MARK: - Save Context
    private func saveContext() {
        do {
            try dataSource.save()
        } catch {
            handleError(error, message: "Error saving notices")
        }
    }
    
    
    private func handleError(_ error: Error?, message: String) {
        let description = error?.localizedDescription ?? message
        errorMessage = description
        showErrorMessageAlert = true
        hapticManager.notification(type: .error)
        log("🍉 ❌ \(message): \(description)", level: .error)
    }

    
    // MARK: - Notifications
    /// Send local notification of new notices
    private func sendLocalNotification(count: Int) {
        guard isNotificationOn, isSoundNotificationOn else { return }
        hapticManager.notification(type: .success)
        log("🍉 🔔 Local notification sent: \(count) new", level: .info)
    }
    
    
    /// One-time sound alert to the user when new notifications appear
    func playSoundNotificationIfNeeded() {
        guard let appStateManager,
              hasUnreadNotices,
              isNotificationOn,
              appStateManager.getUserNotifiedBySoundStatus() else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            guard let self else { return }
            
            if self.isSoundNotificationOn {
                AudioServicesPlaySystemSound(1013)
                appStateManager.markUserNotifiedBySound()
            }
            
            // Notify View about animation (через Publisher или callback)
            self.shouldAnimateNoticeButton = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.shouldAnimateNoticeButton = false
            }
        }
    }

}

// MARK: Convert an old encoded JSON notice to a SwiftData one
struct NoticeMigrationHelper {
    static func convertFromCodable(_ codableNotice: CodableNotice) -> Notice {
        return Notice(
            id: codableNotice.id,
            title: codableNotice.title,
            noticeDate: codableNotice.noticeDate,
            noticeMessage: codableNotice.noticeMessage,
            isRead: codableNotice.isRead
        )
    }
}
