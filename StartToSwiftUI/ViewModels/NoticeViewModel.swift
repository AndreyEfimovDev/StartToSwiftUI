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
    
    private let modelContext: ModelContext
    private let hapticManager = HapticService.shared
    private let networkService: NetworkService
    
    @Published var notices: [Notice] = []
    @Published var hasUnreadNotices: Bool = false // флаг наличия непрочиатнных уведомлений
    @AppStorage("isNotificationOn") var isNotificationOn: Bool = true
    @AppStorage("isSoundNotificationOn") var isSoundNotificationOn: Bool = true
    
    @Published var errorMessage: String?
    @Published var showErrorMessageAlert: Bool = false
    
    init(
        modelContext: ModelContext,
        networkService: NetworkService = NetworkService(baseURL: Constants.cloudNoticesURL)
    ) {
        self.modelContext = modelContext
        self.networkService = networkService
        loadNoticesFromSwiftData()
        updateUnreadStatus()
    }
    
    // MARK: - Load Notices
    func loadNoticesFromSwiftData() {
        do {
            
            let descriptor = FetchDescriptor<Notice>(
                sortBy: [SortDescriptor(\.noticeDate, order: .reverse)]
            )
            
            let fetchedNotices = try modelContext.fetch(descriptor)
            
            self.notices = fetchedNotices
            
            
//          let duration = Date().timeIntervalSince(startTime)
//          log("🍉 ✅ Download completed in \(String(format: "%.2f", duration))s. Notifications: \(fetchedNotices.count)", level: .info)
            
        } catch {
            log("🍉 ❌ Error loading notices: \(error)", level: .error)
        }
    }
    
    // MARK: - Import from Cloud
    /// Вызываем один раз при запуске приложения
    ///
    /// 1. Загрузка из облака → получаем cloudResponse
    /// 2. Фильтрация уведомлений из облака по дате  - берем те, что позднее даты последней загрузки → получаем relevantCloudNotices
    /// 3. Удаление локальных дубликатов → removeDuplicateNotices()
    /// 4. Фильтрация по ID → newNoticesByID = только те, которых нет локально
    /// 5. Добавление только действительно новых newNoticesByID. Если есть новые:
    /// - Конвертируем через NoticeMigrationHelper
    /// - Добавляем в контекст modelContext.insert()
    /// - Сохраняем saveContext()
    /// - Обновляем UI - загружаем обновлённый список loadNoticesFromSwiftData()
    /// 7. Уведомляем пользователя:
    /// - markUserNotNotifiedBySound() - флаг для звукового оповещения
    /// - sendLocalNotification() - системное уведомление (если включено)
    
    
    func importNoticesFromCloud() async {
        
        let appStateManager = AppSyncStateManager(modelContext: modelContext)
        
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
            log("🍉 🆕 Новых уведомлений (по ID): \(newNoticesByID.count)", level: .info)
            
            // Converting and adding new notifications
            log("🍉 ➕ Добавляем \(newNoticesByID.count) новых уведомлений...", level: .info)
            for cloudNotice in newNoticesByID {
                let newNotice = NoticeMigrationHelper.convertFromCodable(cloudNotice)
                modelContext.insert(newNotice)
                log("  ✓ Добавлено: \(newNotice.title)", level: .info)
            }
            
            log("🍉 💾 Предыдущая дата обновления уведомлений: \(lastDate)", level: .info)
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
        let descriptor = FetchDescriptor<Notice>()
        
        do {
            let allNotices = try modelContext.fetch(descriptor)
            
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
                        modelContext.delete(notice)
                        log("    ✗ Duplicate removed: '\(notice.title)'", level: .info)
                    }
                }
                saveContext()

            }
        } catch {
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
        // We check if there is at least one unread textbook.
        hasUnreadNotices = notices.contains(where: { !$0.isRead })
    }
    
    // MARK: - Mark as Read
    func markAsRead(noticeId: String) {
        guard let notice = notices.first(where: { $0.id == noticeId }) else {
            log("🍉 ⚠️ Notification with ID \(noticeId) not found", level: .info)
            return
        }
        
        guard !notice.isRead else { return }
        
        notice.isRead = true
        saveContext()
        updateUnreadStatus()
    }
    
    // MARK: - Toggle Read Status
    func isReadToggle(notice: Notice?) {
        guard let notice = notice else { return }
        notice.isRead.toggle()
        saveContext()
        updateUnreadStatus()
    }
    
    // MARK: - Delete Notice
    func deleteNotice(notice: Notice?) {
        guard let notice = notice else { return }
        
        modelContext.delete(notice)
        saveContext()
        

        notices.removeAll { $0.id == notice.id }
        log("🍉 🗑️ Уведомление удалено, осталось: \(notices.count)", level: .info)
        
        updateUnreadStatus()
    }
    
    // MARK: - Add Notice
    func addNotice(_ notice: Notice) {
        // Let's check if such an ID already exists
        guard !notices.contains(where: { $0.id == notice.id }) else {
            log("🍉 ⚠️ Notice with ID \(notice.id) already exists", level: .info)
            return
        }
        
        modelContext.insert(notice)
        saveContext()
        
        notices.insert(notice, at: 0)
        log("🍉 ➕ Notice added, total: \(notices.count)", level: .info)
        
        updateUnreadStatus()
    }
    
    // MARK: - Save Context
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            log("🍉 ❌ Error saving context: \(error)", level: .error)
            errorMessage = "Error saving data"
            showErrorMessageAlert = true
            hapticManager.notification(type: .error)
        }
    }
    
    // MARK: - Local Notifications
    /// Send local notification of new notices
    private func sendLocalNotification(count: Int) {
        
        guard isNotificationOn else { return }
        
        if isSoundNotificationOn {
            hapticManager.notification(type: .success)
        }
        log("🍉 🔔 Отправлено локальное уведомление: \(count) новых уведомлений", level: .info)
    }
    
}


// MARK: - Preview Helper
extension NoticeViewModel {

    /// Creating a Mock ViewModel for Preview
    static func mockViewModel() -> NoticeViewModel {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: Notice.self,
            configurations: config
        )

        let viewModel = NoticeViewModel(
            modelContext: container.mainContext,
            networkService: NetworkService(baseURL: Constants.cloudNoticesURL)
        )

        let mockNotices = [
            Notice(
                id: "1",
                title: "Обновление приложения",
                noticeDate: Date().addingTimeInterval(-86400),
                noticeMessage: "Доступна новая версия приложения с улучшениями",
                isRead: false
            ),
            Notice(
                id: "2",
                title: "Новые материалы",
                noticeDate: Date().addingTimeInterval(-172800),
                noticeMessage: "Добавлены новые учебные материалы по SwiftUI",
                isRead: true
            ),
            Notice(
                id: "3",
                title: "Напоминание",
                noticeDate: Date().addingTimeInterval(-259200),
                noticeMessage: "Не забудьте синхронизировать данные",
                isRead: false
            )
        ]

        for notice in mockNotices {
            container.mainContext.insert(notice)
        }

        try? container.mainContext.save()
        viewModel.loadNoticesFromSwiftData()

        return viewModel
    }
}
