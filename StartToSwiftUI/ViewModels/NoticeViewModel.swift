//
//  NotificationCentre.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 14.11.2025.
//
//

import SwiftUI
import SwiftData

@MainActor
final class NoticeViewModel: ObservableObject {
    
//    private let modelContext: ModelContext
    private let dataSource: NoticesDataSourceProtocol
    private let hapticManager = HapticService.shared
    private let networkService: NetworkServiceProtocol
    
    @Published var notices: [Notice] = []
    @Published var hasUnreadNotices: Bool = false // флаг наличия непрочиатнных уведомлений
    @AppStorage("isNotificationOn") var isNotificationOn: Bool = true
    @AppStorage("isSoundNotificationOn") var isSoundNotificationOn: Bool = true
    
    @Published var errorMessage: String?
    @Published var showErrorMessageAlert: Bool = false
    
    init(
        dataSource: NoticesDataSourceProtocol,
        networkService: NetworkServiceProtocol = NetworkService(baseURL: Constants.cloudNoticesURL)
    ) {
        self.dataSource = dataSource
        self.networkService = networkService
        loadNoticesFromSwiftData()
        updateUnreadStatus()
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
    
    // MARK: - Load Notices
    func loadNoticesFromSwiftData() {
        
        // Check and remove local duplicates BEFORE loading notices from SwiftData
        // Removing duplicate notices in SwiftUI, leaving only one instance for each ID
        // Remove duplicates for SwiftData only
        if dataSource is SwiftDataNoticesDataSource {
            removeDuplicateNotices()
        }

        do {
            let loadedNotices = try dataSource.fetchNotices()
            self.notices = loadedNotices
            
            
//          let duration = Date().timeIntervalSince(startTime)
//          log("🍉 ✅ Download completed in \(String(format: "%.2f", duration))s. Notifications: \(fetchedNotices.count)", level: .info)
            
        } catch {
            self.errorMessage = error.localizedDescription
            self.showErrorMessageAlert = true
            self.hapticManager.notification(type: .error)
            log("🍉 ❌ Error loading notices: \(error)", level: .error)
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
        
        // For Mock sources - simplified logic
        if !(dataSource is SwiftDataNoticesDataSource) {
            do {
                let cloudResponse: [CodableNotice] = try await networkService.fetchDataFromURLAsync()
                
                // Filter by ID
                let existingIDs = Set(notices.map { $0.id })
                let newNoticesByID = cloudResponse.filter { !existingIDs.contains($0.id) }
                
                guard !newNoticesByID.isEmpty else {
                    updateUnreadStatus()
                    return
                }
                
                // Convert and add
                for cloudNotice in newNoticesByID {
                    let newNotice = NoticeMigrationHelper.convertFromCodable(cloudNotice)
                    dataSource.insert(newNotice)
                }
                
                try dataSource.save()
                loadNoticesFromSwiftData()
                updateUnreadStatus()
                
                log("🍉 ✅ Import complete (Mock): \(newNoticesByID.count) notices added", level: .info)
            } catch {
                self.errorMessage = error.localizedDescription
                self.showErrorMessageAlert = true
                log("🍉 ❌ Import error (Mock): \(error.localizedDescription)", level: .error)
            }
            return
        }

        
        // Get the modelContext only if it is a SwiftData source
        guard let swiftDataSource = dataSource as? SwiftDataNoticesDataSource else {
            log("🍉 ⚠️ importNoticesFromCloud: only for SwiftData", level: .info)
            return
        }

        let appStateManager = AppSyncStateManager(modelContext: swiftDataSource.modelContext)
        
        do {
            
            let cloudResponse: [CodableNotice] = try await networkService.fetchDataFromURLAsync()
            log("🍉 📦 Received \(cloudResponse.count) notifications from the cloud", level: .info)
            
            // Filter by latest date
            let lastDate = appStateManager.getLastNoticeDate() ?? Date.distantPast
            let relevantCloudNotices = cloudResponse.filter {
                $0.noticeDate > lastDate
            }
            log("🍉 📦 Selected \(relevantCloudNotices.count) notifications from the cloud", level: .info)
            
            guard !relevantCloudNotices.isEmpty else {
                return
            }
            
            // Check and remove local duplicates BEFORE adding new ones
            // Removing duplicate notifications in SwiftUI, leaving only one instance for each ID
            removeDuplicateNotices()
            
            // Collecting local notification IDs
            let existingIDs = Set(notices.map { $0.id })
            // Filter new notices by IDs that are not in SwiftData
            let newNoticesByID = relevantCloudNotices.filter { !existingIDs.contains($0.id) }
            
            guard !newNoticesByID.isEmpty else {
                updateUnreadStatus()
                return
            }
            log("🍉 🆕 New notices (by ID): \(newNoticesByID.count)", level: .info)
            
            // Converting and adding new notifications
            log("🍉 ➕ Adding (newNoticesByID.count) new notices...", level: .info)
            for cloudNotice in newNoticesByID {
                let newNotice = NoticeMigrationHelper.convertFromCodable(cloudNotice)
                dataSource.insert(newNotice)
                log("  ✓ Added: \(newNotice.title)", level: .info)
            }
            
            log("🍉 💾 Previous notices update date: \(lastDate)", level: .info)
            if let latestDate = cloudResponse.map({ $0.noticeDate }).max() {
                appStateManager.updateLatestNoticeDate(latestDate)
                log("🍉 💾 New notifications update date: \(latestDate)", level: .info)
            }
            
            // Save to SwiftData
            saveContext()
            
            // Update the notices array
            loadNoticesFromSwiftData()
            updateUnreadStatus() // set the flag for unread notices
            
            // Enable the flag to notify the user of new notices
            appStateManager.markUserNotNotifiedBySound() // isUserNotNotified -> true
            
            
            // Sending a hapticManager.notification notification to the user
            if isNotificationOn {
                sendLocalNotification(count: newNoticesByID.count)
            }
            log("🍉 ✅ Import complete: \(newNoticesByID.count) notices added",  level: .info)
        } catch {
            self.errorMessage = error.localizedDescription
            self.showErrorMessageAlert = true
            self.hapticManager.notification(type: .error)
            log("🍉 ❌ Import error: \(error.localizedDescription)", level: .error)
        }
    }
    
    // MARK: - Remove Duplicates
    /// Remove duplicate notifications in SwiftUI, leaving only one instance of each ID.
    private func removeDuplicateNotices() {
        
        // Работает только для SwiftData
        guard let swiftDataSource = dataSource as? SwiftDataNoticesDataSource else {
            return
        }

        let descriptor = FetchDescriptor<Notice>()
        
        do {
            let allNotices = try swiftDataSource.modelContext.fetch(descriptor)
            
            if !allNotices.isEmpty {
                // Grouped by Id
                let groupedById = Dictionary(grouping: allNotices, by: { $0.id })
                
                // Find duplicates
                // duplicates is a dictionary: [ID: [list of duplicate notifications]]
                let duplicates = groupedById.filter { $0.value.count > 1 }
                
                guard !duplicates.isEmpty else {
                    return
                }
                log("🍉 🗑️ Duplicate notifications found: \(duplicates.count) ID with duplicates", level: .info)
                
                // For each ID, keep only the first one and delete the rest
                // id - unique notice identifier (String)
                // noticesList - array of duplicates with the same ID (notices array)
                for (id, noticesList) in duplicates {
                    log("  🔍 ID \(id): found \(noticesList.count) duplicates", level: .info)
                    
                    // Loop through all duplicates with the same id
                    // Check if there is at least one notice with isRead = true
                    // Save one notice from the duplicates to noticeToKeep
                    let noticeToKeep: Notice
                    
                    if let readNotice = noticesList.first(where: { $0.isRead }) {
                        // There is a read version - keep it
                        noticeToKeep = readNotice
                    } else if let firstNotice = noticesList.first {
                        // All unread - keep the first one
                        noticeToKeep = firstNotice
                    } else {
                        log("⚠️ Unexpected situation: empty array noticesList for ID \(id)", level: .warning)
                        continue // skip the remaining code and move on to the next iteration of the loop
                    }
                    
                    // Delete everything except noticeToKeep
                    for notice in noticesList where notice.persistentModelID != noticeToKeep.persistentModelID {
                        dataSource.delete(notice)
                        log("    ✗ Duplicate removed: '\(notice.title)'", level: .info)
                    }
                }
                saveContext()

            }
        } catch {
            self.errorMessage = error.localizedDescription
            self.showErrorMessageAlert = true
            self.hapticManager.notification(type: .error)
            log("🍉 ❌ Error removing duplicates: \(error)", level: .error)
        }
    }
    
    // MARK: - Mark all as read
    func markAllAsRead() {
        for notice in notices where !notice.isRead {
            notice.isRead = true
        }
        saveContext()
        updateUnreadStatus()
    }
    
    // MARK: - Update Unread Status
    func updateUnreadStatus() {
        // We check if there is at least one unread notice
        hasUnreadNotices = notices.contains(where: { !$0.isRead })
    }
    
    // MARK: - Mark as Read
    func markAsRead(noticeId: String) {
        guard let notice = notices.first(where: { $0.id == noticeId }) else {
            self.errorMessage = "Notice with ID \(noticeId) not found"
            self.showErrorMessageAlert = true
            self.hapticManager.notification(type: .error)
            log("🍉 ⚠️ markAsRead: notice with ID \(noticeId) not found", level: .info)
            return
        }
        
        guard !notice.isRead else { return }
        
        notice.isRead = true
        saveContext()
        updateUnreadStatus()
    }
    
    // MARK: - Toggle Read Status
    func isReadToggle(notice: Notice?) {
        guard let notice = notice else {
            self.errorMessage = "Notice passed is nil"
            self.showErrorMessageAlert = true
            self.hapticManager.notification(type: .error)
            log("🍉 ⚠️ isReadToggle: notice passed is nil", level: .info)
            return
        }
        notice.isRead.toggle()
        saveContext()
        updateUnreadStatus()
    }
    
    // MARK: - Delete Notice
    func deleteNotice(notice: Notice?) {
        guard let notice = notice else {
            self.errorMessage = "Notice passed to delete does not exists (nil)"
            self.showErrorMessageAlert = true
            self.hapticManager.notification(type: .error)
            log("🍉 ⚠️ deleteNotice: notice passed is nil", level: .info)
            return
        }
        dataSource.delete(notice)
        saveContext()

        notices.removeAll { $0.id == notice.id }
        log("🍉 🗑️ deleteNotice: notice is removed, remains: \(notices.count)", level: .info)
        
        updateUnreadStatus()
    }
    
    // MARK: - Add Notice
    func addNotice(_ notice: Notice) {
        log("🔍 Attempting to add notice: \(notice.id), title: \(notice.title)", level: .info)
        log("🔍 Current notices count: \(notices.count)", level: .info)
           
           // Checking for duplicates in an already loaded array
           guard !notices.contains(where: { $0.id == notice.id }) else {
               log("🍉 ⚠️ Notice with ID \(notice.id) already exists", level: .info)
               print("🔍 Duplicate found, returning")
               return
           }
           
           do {
               log("🔍 Inserting into context...", level: .info)
               dataSource.insert(notice)
               
               log("🔍 Saving context...", level: .info)
               try dataSource.save()
               
               log("🔍 Reloading from SwiftData...", level: .info)
               loadNoticesFromSwiftData()
               log("🍉 ➕ Notice added, total: \(notices.count)", level: .info)
               
               updateUnreadStatus()
           } catch {
               log("🔍 Error: \(error)", level: .error)
               errorMessage = "Error adding notice: \(error.localizedDescription)"
               showErrorMessageAlert = true
               hapticManager.notification(type: .error)
               log("🍉 ❌ Error adding notice: \(error)", level: .error)
           }
    }
    
    // MARK: - Save Context
    private func saveContext() {
        do {
            try dataSource.save()
        } catch {
            errorMessage = "Error saving notices"
            showErrorMessageAlert = true
            hapticManager.notification(type: .error)
            log("🍉 ❌ Error saving context: \(error)", level: .error)
        }
    }
    
    // MARK: - Local Notifications
    /// Send local notification of new notices
    private func sendLocalNotification(count: Int) {
        
        guard isNotificationOn else { return }
        
        if isSoundNotificationOn {
            hapticManager.notification(type: .success)
        }
        log("🍉 🔔 Local notification sent: \(count) new notifications", level: .info)
    }
    
}

//
//// MARK: - Preview Helper
//extension NoticeViewModel {
//
//    /// Creating a Mock ViewModel for Preview
//    static func mockViewModel() -> NoticeViewModel {
//        let config = ModelConfiguration(isStoredInMemoryOnly: true)
//        let container = try! ModelContainer(
//            for: Notice.self,
//            configurations: config
//        )
//
//        let viewModel = NoticeViewModel(
//            modelContext: container.mainContext,
//            networkService: NetworkService(baseURL: Constants.cloudNoticesURL)
//        )
//
//        let mockNotices = [
//            Notice(
//                id: "1",
//                title: "Updating the application",
//                noticeDate: Date().addingTimeInterval(-86400),
//                noticeMessage: "A new version of the app with improvements is available",
//                isRead: false
//            ),
//            Notice(
//                id: "2",
//                title: "New study materials",
//                noticeDate: Date().addingTimeInterval(-172800),
//                noticeMessage: "New SwiftUI tutorials have been added",
//                isRead: true
//            ),
//            Notice(
//                id: "3",
//                title: "Reminder",
//                noticeDate: Date().addingTimeInterval(-259200),
//                noticeMessage: "Don't forget to sync your data",
//                isRead: false
//            )
//        ]
//
//        for notice in mockNotices {
//            container.mainContext.insert(notice)
//        }
//
//        try? container.mainContext.save()
//        viewModel.loadNoticesFromSwiftData()
//
//        return viewModel
//    }
//}
