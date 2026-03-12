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
final class NoticesViewModel: ObservableObject {
    
    private let dataSource: NoticesDataSourceProtocol
    private let hapticManager = HapticManager.shared
    private let fbNoticesManager: FBNoticesManagerProtocol
    private let appStateManager: AppSyncStateManager?

    
    @Published var notices: [Notice] = []
    @Published var hasUnreadNotices: Bool = false
    @Published var shouldAnimateNoticeButton = false
    
    @Published var errorMessage: String?
    @Published var showErrorMessageAlert: Bool = false
    
    @AppStorage("isNotificationOn") var isShowBadgeForNewNotices: Bool = true

    private var cancellables = Set<AnyCancellable>()
    
    private var lastLoadTime: Date = Date(timeIntervalSince1970: 0)
    private let minLoadInterval: TimeInterval = 3
    
    private var swiftDataSource: SwiftDataNoticesDataSource? {
        dataSource as? SwiftDataNoticesDataSource
    }
    
    
    var unreadCount: Int {
        notices.filter { !$0.isRead }.count
    }

    var sortedNotices: [Notice] {
        notices.sorted { $0.noticeDate > $1.noticeDate }
    }

    
    init(
        dataSource: NoticesDataSourceProtocol,
        appStateManager: AppSyncStateManager? = nil,
        fbNoticesManager: FBNoticesManagerProtocol = FBNoticesManager(),
    ) {
        self.dataSource = dataSource
        self.appStateManager = appStateManager
        self.fbNoticesManager = fbNoticesManager
    }

    /// Convenience initializer for backward compatibility
    convenience init(
        modelContext: ModelContext,
        appStateManager: AppSyncStateManager? = nil,
        fbNoticesManager: FBNoticesManagerProtocol = FBNoticesManager()
    ) {
        self.init(
            dataSource: SwiftDataNoticesDataSource(modelContext: modelContext),
            appStateManager: appStateManager,
            fbNoticesManager: fbNoticesManager
        )
    }

    func start() {
        setupSubscriptionForChangesInCloud()
    }
    
    // MARK: - CloudKit Sync
    private func setupSubscriptionForChangesInCloud() {
        NotificationCenter.default.publisher(for: Notification.Name.NSPersistentStoreRemoteChange)
            .receive(on: DispatchQueue.main)
            .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                let now = Date()
                guard now.timeIntervalSince(self.lastLoadTime) >= self.minLoadInterval else {
                    log("Cloud sync skipped (too soon)", level: .debug)
                    return
                }
                self.loadNoticesFromSwiftData()
                log("Cloud notices sync subscription run", level: .info)
            }
            .store(in: &cancellables)
    }

    // MARK: - Load Notices from SwiftData
    func loadNoticesFromSwiftData(removeDuplicates: Bool = true) {
        FBPerformanceManager.shared.startTrace(name: "load_notices_swiftdata")
        lastLoadTime = Date()
        FBCrashManager.shared.addLog("loadNoticesFromSwiftData: notices count: \(notices.count)")

        // Removing duplicate notices in SwiftUI, leaving only one instance for each ID - for SwiftData only
        if removeDuplicates, let swiftDataSource {
            removeDuplicateNotices(from: swiftDataSource)
        }
        FBCrashManager.shared.addLog("loadNoticesFromSwiftData: notices count after check for duplicates: \(notices.count)")

        do {
            self.notices = try dataSource.fetchNotices()
            FBCrashManager.shared.addLog("loadNoticesFromSwiftData: notices count after fetch from SwiftData: \(notices.count)")
            updateUnreadStatus()  // ← always update status when fetch notices
        } catch {
            FBCrashManager.shared.sendNonFatal(error)
            handleError(error, message: "Error loading notices")
        }
        FBPerformanceManager.shared.stopTrace(name: "load_notices_swiftdata")
    }
    
    // MARK: - Import Notices from Firebase
    func importNoticesFromFirebase() async {
        FBPerformanceManager.shared.startTrace(name: "import_notices_firebase")
        FBCrashManager.shared.addLog("loadNoticesFromFirebase: started, notices count: \(notices.count)")

        // Set filter date
        let filterDate: Date
        if let appStateManager {
            let lastNoticeDate = appStateManager.getLastNoticeDate() ?? Date(timeIntervalSince1970: 0)
            log("🔥 LastNoticeDate from appStateManager \(lastNoticeDate)", level: .info)

            let firstLaunchDate = appStateManager.getAppFirstLaunchDate() ?? Date(timeIntervalSince1970: 0)
            log("🔥 FirstLaunchDate from appStateManager \(firstLaunchDate)", level: .info)

            filterDate = max(lastNoticeDate, firstLaunchDate)
            log("🔥 filterDate from appStateManager \(filterDate)", level: .info)
        } else {
            filterDate = Date(timeIntervalSince1970: 0)
        }
        
        // Fetch from Firebase & handle network errors
        let relevantNotices: [FBNoticeModel]
        
        let fetchResult = await fbNoticesManager.fetchFBNotices(after: filterDate)
        switch fetchResult {
        case .success(let notices):
            relevantNotices = notices
        case .failure(.networkUnavailable):
            handleError(nil, message: "No internet connection. Please check your network and try again.")
            FBPerformanceManager.shared.stopTrace(name: "import_notices_firebase")
            return
        case .failure(.unknown(let error)):
            handleError(error, message: "Failed to load notices from Firebase")
            FBPerformanceManager.shared.stopTrace(name: "import_notices_firebase")
            return
        }

        FBCrashManager.shared.addLog("loadNoticesFromFirebase: in progress, notices imported: \(relevantNotices.count)")

        // Sync & filter duplicates
        loadNoticesFromSwiftData()
        let existingIDs = Set(notices.map { $0.id })
        let newNotices = relevantNotices.filter { !existingIDs.contains($0.noticeId) }
        FBCrashManager.shared.addLog("loadNoticesFromFirebase: in progress, new notices found count: \(newNotices.count)")

        // Update latest date
        if let appStateManager,
           let latestDate = relevantNotices.map({ $0.noticeDate }).max() {
            appStateManager.updateLatestNoticeDate(latestDate)
            FBCrashManager.shared.addLog("loadNoticesFromFirebase: latest notices date updated: \(latestDate)")
            log("🔥 LastNoticeDate updated in appStateManager \(latestDate)", level: .info)
        }

        guard !newNotices.isEmpty else {
            FBPerformanceManager.shared.stopTrace(name: "import_notices_firebase")
            return
        }

        // Save new notices
        for firebaseNotice in newNotices {
            dataSource.insert(NoticeMigrationHelper.convertFromFirebase(firebaseNotice))
        }

        if isShowBadgeForNewNotices {
            sendLocalNotification(count: newNotices.count)
        }

        saveContext()
        loadNoticesFromSwiftData(removeDuplicates: false)
        log("🍉 ✅ Import complete: \(newNotices.count) notices added", level: .info)
        FBPerformanceManager.shared.setValue(
            name: "import_notices_firebase",
            value: "\(newNotices.count)/\(relevantNotices.count)",
            forAttribute: "notices_new_of_received"
        )
        FBPerformanceManager.shared.stopTrace(name: "import_notices_firebase")
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
            FBCrashManager.shared.addLog("removeDuplicateNotices: found \(duplicateGroups.count) duplicates")
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
            FBCrashManager.shared.sendNonFatal(error)
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
    func deleteErase(_ notice: Notice?) {
        guard let notice else {
            handleError(nil, message: "Notice to erase is nil")
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
            FBCrashManager.shared.sendNonFatal(error)
            handleError(error, message: "Error adding notice")
        }
    }
    
    // MARK: - Save Context
    private func saveContext() {
        do {
            try dataSource.save()
        } catch {
            FBCrashManager.shared.sendNonFatal(error)
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
        guard isShowBadgeForNewNotices else { return }
        hapticManager.notification(type: .success)
        log("🍉 🔔 Local notification sent: \(count) new", level: .info)
    }
}
