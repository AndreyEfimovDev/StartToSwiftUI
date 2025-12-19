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
class NoticeViewModel: ObservableObject {
    
    
    private let modelContext: ModelContext
    private let hapticManager = HapticService.shared
    private let networkService: NetworkService
    
    @Published var notices: [Notice] = []
    @Published var hasUnreadNotices: Bool = false
    @Published var errorMessage: String?
    @Published var showErrorMessageAlert: Bool = false
    
    @AppStorage("isNotificationOn") var isNotificationOn: Bool = true
    @AppStorage("isSoundNotificationOn") var isSoundNotificationOn: Bool = true
    
    init(
        modelContext: ModelContext,
        networkService: NetworkService = NetworkService(baseURL: Constants.cloudNoticesURL)
    ){
        self.modelContext = modelContext
        print("✅ NoticeViewModel инициализирован с ModelContext")
        self.networkService = networkService
        loadNoticesFromSwiftData()
        print("✅ Загрузили локальный уведомления из SwiftData")
        updateUnreadStatus()
    }
    
    // MARK: - Load Notices
    func loadNoticesFromSwiftData() {

        do {
            let descriptor = FetchDescriptor<Notice>(
                sortBy: [SortDescriptor(\.noticeDate, order: .reverse)]
            )
            let fetchedNotices = try modelContext.fetch(descriptor)
            
            // ✅ Обновляем только если реально изменилось
            if fetchedNotices.count != notices.count ||
                fetchedNotices.map({ $0.id }) != notices.map({ $0.id }) {
                self.notices = fetchedNotices
                print("🍉 🔄 Список уведомлений обновлен, теперь: \(notices.count)")
            }
        } catch {
            print("🍉 ❌ Ошибка загрузки уведомлений: \(error)")
        }
    }
    
    // MARK: - Import from Cloud
    /// Вызываем один раз при запуске приложения
    @MainActor
    func importNoticesFromCloud() async {
        print("🍉 ☁️ Начинаем импорт уведомлений из облака...")
        let appStateManager = AppStateManager(modelContext: modelContext)

        do {
            let cloudResponse: [CodableNotice] = try await networkService.fetchDataFromURLAsync()
            
            guard !cloudResponse.isEmpty else {
                print("🍉 ☑️ Массив уведомлений из облака пуст")
                return
            }
            print("🍉 📦 Получено \(cloudResponse.count) уведомлений из облака")
            
            // Загружаем существующие уведомления
            let descriptor = FetchDescriptor<Notice>()
            let existingNotices = try modelContext.fetch(descriptor)
            print("🍉 📊 В локальной базе: \(existingNotices.count) уведомлений")
            
            // Создаём Set существующих ID для быстрой проверки
            let existingIDs = Set(existingNotices.map { $0.id })
            // Филтруем из облака только уведомления с уникальным ID по оношению к локальным уведомлениям
            let newNoticesByID = cloudResponse.filter { !existingIDs.contains($0.id) }
            
            guard !newNoticesByID.isEmpty else {
                print("🍉 ✅ Все уведомления уже есть в базе (дубликатов нет)")
                return
            }
            print("🍉 🆕 Новых уведомлений (по ID): \(newNoticesByID.count)")
            
            // Конвертируем и добавляем новые уведомления
            print("🍉 ➕ Добавляем \(newNoticesByID.count) новых уведомлений...")
            var addedNotices: [Notice] = []
            for cloudNotice in newNoticesByID {
                let newNotice = NoticeMigrationHelper.convertFromCodable(cloudNotice)
                modelContext.insert(newNotice)
                addedNotices.append(newNotice)
                print("  ✓ Добавлено: \(newNotice.title)")
            }
            
            // Сохраняем в SwiftData
            saveContext()
            print("🍉 💾 Уведомления сохранены в SwiftData")
            
            // Добавляем в массив notices вручную!
            notices.insert(contentsOf: addedNotices, at: 0)
            notices.sort { $0.noticeDate > $1.noticeDate }
            print("🍉 🔄 Список уведомлений обновлен, теперь: \(notices.count)")
            
            // Включаем флаг оповещения, чтобы уведомить пользователя о новых уведомлениях
            appStateManager.markUserNotNotifiedBySound() // isUserNotNotified -> true
            updateUnreadStatus()
            
            // Отправляем уведомление пользователю
            if isNotificationOn {
                sendLocalNotification(count: newNoticesByID.count)
            }
            print("🍉 ✅ Импорт завершён: добавлено \(newNoticesByID.count) уведомлений")
        } catch {
            self.errorMessage = error.localizedDescription
            self.showErrorMessageAlert = true
            self.hapticManager.notification(type: .error)
            print("🍉 ❌ Ошибка импорта: \(error.localizedDescription)")
        }
    }

    // MARK: - Отметить все как прочитанные
    func markAllAsRead() {
        for notice in notices where !notice.isRead {
            notice.isRead = true
        }
        saveContext()
        updateUnreadStatus()
    }
    
    // MARK: - Update Unread Status
    func updateUnreadStatus() {
        // проверяем, есть ли хотя бы одно непрочитанное учедомления
        hasUnreadNotices = notices.contains(where: { !$0.isRead })
        print("📊 Непрочитанных уведомлений: \(notices.filter { !$0.isRead }.count)")
    }
    
    // MARK: - Mark as Read
    func markAsRead(noticeId: String) {
        // Ищем уведомление по ID в массиве
        guard let notice = notices.first(where: { $0.id == noticeId }) else {
            print("🍉 ⚠️ Уведомление с ID \(noticeId) не найдено")
            return
        }
        
        guard !notice.isRead else {
            print("🍉 ℹ️ Уведомление уже прочитано")
            return
        }
        
        notice.isRead = true
        saveContext()
        updateUnreadStatus()
        print("🍉 ✅ Уведомление \(noticeId) отмечено как прочитанное")
        
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
        
        // Удаляем из массива вручную
        notices.removeAll { $0.id == notice.id }
        print("🍉 🗑️ Уведомление удалено, осталось: \(notices.count)")
        
        updateUnreadStatus()
    }
    
    // MARK: - Add Notice
    func addNotice(_ notice: Notice) {
        // Проверяем, нет ли уже такого ID
        guard !notices.contains(where: { $0.id == notice.id }) else {
            print("🍉 ⚠️ Уведомление с ID \(notice.id) уже существует")
            return
        }
        
        modelContext.insert(notice)
        saveContext()
        
        // ✅ Добавляем в массив вручную
        notices.insert(notice, at: 0)
        print("🍉 ➕ Уведомление добавлено, всего: \(notices.count)")
        
        updateUnreadStatus()
    }
    
    // MARK: - Save Context
    
    private func saveContext() {
        do {
            try modelContext.save()
            print("🍉 💾 SwiftData контекст сохранён")
        } catch {
            print("🍉 ❌ Ошибка сохранения контекста: \(error)")
            errorMessage = "Ошибка сохранения данных"
            showErrorMessageAlert = true
            hapticManager.notification(type: .error)
        }
    }

//    
//    private func saveContextAndReload() {
//        do {
//            try modelContext.save()
//            print("🍉 💾 SwiftData контекст сохранён")
//            // 🌥️ iCloud автоматически синхронизирует изменения!
//            refreshNotices()
//        } catch {
//            print("🍉 ❌ Ошибка сохранения контекста: \(error)")
//            errorMessage = "Ошибка сохранения данных"
//            showErrorMessageAlert = true
//            hapticManager.notification(type: .error)
//        }
//    }
//    
//    private func refreshNotices() {
//        let descriptor = FetchDescriptor<Notice>(
//            sortBy: [SortDescriptor(\.noticeDate, order: .reverse)]
//        )
//        
//        do {
//            self.notices = try modelContext.fetch(descriptor)
//            print("🍉 🔄 Список уведомлений обновлен, теперь: \(self.notices.count)")
//        } catch {
//            print("🍉 ❌ Ошибка обновления уведомлений: \(error)")
//        }
//    }
//    
    // MARK: - Local Notifications
    
    /// Отправить локальное уведомление о новых уведомлениях
    private func sendLocalNotification(count: Int) {
        
        guard isNotificationOn else { return }
        
        if isSoundNotificationOn {
            hapticManager.notification(type: .success)
        }
        
        print("🍉 🔔 Отправлено локальное уведомление: \(count) новых уведомлений")
    }
    
}
//// MARK: - Preview Helper
//
//extension NoticeViewModel {
//    
//    /// Создание mock ViewModel для Preview
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
//        // Добавляем mock данные
//        let mockNotices = [
//            Notice(
//                id: "1",
//                title: "Обновление приложения",
//                noticeDate: Date().addingTimeInterval(-86400),
//                noticeMessage: "Доступна новая версия приложения с улучшениями",
//                isRead: false
//            ),
//            Notice(
//                id: "2",
//                title: "Новые материалы",
//                noticeDate: Date().addingTimeInterval(-172800),
//                noticeMessage: "Добавлены новые учебные материалы по SwiftUI",
//                isRead: true
//            ),
//            Notice(
//                id: "3",
//                title: "Напоминание",
//                noticeDate: Date().addingTimeInterval(-259200),
//                noticeMessage: "Не забудьте синхронизировать данные",
//                isRead: false
//            )
//        ]
//        
//        for notice in mockNotices {
//            container.mainContext.insert(notice)
//        }
//        
//        try? container.mainContext.save()
//        viewModel.refreshNotices()
//        
//        return viewModel
//    }
//}
