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
//            print("🍉 🔄 Загрузили локальные уведомления из SwiftData, сейчас их: \(fetchedNotices.count)")
            
            self.notices = fetchedNotices
//            print("🍉 🔄 Список уведомлений обновлен, теперь: \(notices.count)")
            
            //            let duration = Date().timeIntervalSince(startTime)
            //            print("🍉 ✅ Загрузка завершена за \(String(format: "%.2f", duration))с. Уведомлений: \(fetchedNotices.count)")
            
        } catch {
            print("🍉 ❌ Ошибка загрузки уведомлений: \(error)")
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
        // ШАГ 1: Ждём синхронизацию с iCloud
//        print("🍉 ⏳ Ожидание синхронизации iCloud (1 секунда)...")
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 секунда
        
        do {
//            print("🍉 ☁️ Начинаем импорт уведомлений из облака...")
            
            let cloudResponse: [CodableNotice] = try await networkService.fetchDataFromURLAsync()
//            print("🍉 📦 Получено \(cloudResponse.count) уведомлений из облака")
            
            // Фильтрация по дате
            let lastDate = appStateManager.getLastNoticeDate() ?? Date.distantPast
            let relevantCloudNotices = cloudResponse.filter {
                $0.noticeDate > lastDate
            }
//            print("🍉 📦 Отобрано \(relevantCloudNotices.count) уведомлений из облака")
            
            guard !relevantCloudNotices.isEmpty else {
                print("🍉 ☑️ Массив новых (ранее не загруженных) уведомлений из облака пуст, ✅ выходим из импорта")
                return
            }
            
            // ШАГ 2: Проверяем и удаляем локальные дубликаты ПЕРЕД добавлением новых
            // Удаляем дубликаты уведомлений в SwiftUI, оставляя только один экземпляр для каждого ID
            removeDuplicateNotices()
            
            // Собираем ID локальный уведомлений
            let existingIDs = Set(notices.map { $0.id })
            // Фильтруем новые по ID, которых нет в SwiftData
            let newNoticesByID = relevantCloudNotices.filter { !existingIDs.contains($0.id) }
            
            guard !newNoticesByID.isEmpty else {
//                print("🍉 ✅ Все уведомления уже есть в базе (дубликатов нет)")
//                loadNoticesFromSwiftData()
                updateUnreadStatus()
                return
            }
//            print("🍉 🆕 Новых уведомлений (по ID): \(newNoticesByID.count)")
            
            // Конвертируем и добавляем новые уведомления
//            print("🍉 ➕ Добавляем \(newNoticesByID.count) новых уведомлений...")
            for cloudNotice in newNoticesByID {
                let newNotice = NoticeMigrationHelper.convertFromCodable(cloudNotice)
                modelContext.insert(newNotice)
//                print("  ✓ Добавлено: \(newNotice.title)")
            }
//            print("🍉 💾 Сохранены в SwiftData")
            
//            print("🍉 💾 Предыдущая дата обновления уведомлений: \(lastDate)")
            if let latestDate = cloudResponse.map({ $0.noticeDate }).max() {
                appStateManager.updateLatestNoticeDate(latestDate)
                print("🍉 💾 Новая дата обновления уведомлений: \(latestDate)")
            }
            
            // Сохраняем в SwiftData
            saveContext()
//            print("🍉 💾 Уведомления сохранены в SwiftData")
            
            // Обнровляем массив уведомлений
            loadNoticesFromSwiftData()
            updateUnreadStatus() // устанавливаем флаг наличия непрочиатнных сообщений
//            print("🍉 🔄 Список уведомлений обновлен, теперь: \(notices.count)")
            
            // Включаем флаг оповещения, чтобы уведомить пользователя о новых уведомлениях
            appStateManager.markUserNotNotifiedBySound() // isUserNotNotified -> true
            
            
            // Отправляем hapticManager.notification уведомление пользователю
            if isNotificationOn {
                sendLocalNotification(count: newNoticesByID.count)
            }
//            print("🍉 ✅ Импорт завершён: добавлено \(newNoticesByID.count) уведомлений")
        } catch {
            self.errorMessage = error.localizedDescription
            self.showErrorMessageAlert = true
            self.hapticManager.notification(type: .error)
//            print("🍉 ❌ Ошибка импорта: \(error.localizedDescription)")
        }
    }
    
    
    // MARK: - Sync Notice Status
    /// Синхронизирует статус isRead из облака в локальные уведомления
    //    private func syncNoticeStatusFromCloud(cloudNotices: [CodableNotice], localNotices: [Notice]) {
    //        print("🍉🔄 Синхронизация статуса уведомлений из облака...")
    //        // Создаём словарь: ID → isRead из облака
    //        let cloudStatusMap = Dictionary(
    //            uniqueKeysWithValues: cloudNotices.map { ($0.id, $0.isRead)
    //            })
    //
    //        var updatedCount = 0
    //
    //        for localNotice in localNotices {
    //            guard let cloudIsRead = cloudStatusMap[localNotice.id] else {
    //                continue // Уведомления нет в облаке
    //            }
    //
    //            if localNotice.isRead != cloudIsRead {
    //                print("  🔄 [\(localNotice.id)] локально: \(localNotice.isRead) → облако: \(cloudIsRead)")
    //                localNotice.isRead = cloudIsRead
    //                updatedCount += 1
    //            }
    //        }
    //
    //        if updatedCount > 0 {
    //            saveContext()
    //            print(" 🍉 ✅ Обновлено статусов: \(updatedCount)")
    //        } else {
    //            print(" 🍉 Нет обновления, все статусы синхронизированы")
    //        }
    //    }
    //
    //
    // MARK: - Remove Duplicates
    /// Удаляет дубликаты уведомлений в SwiftUI, оставляя только один экземпляр каждого ID
    
    private func removeDuplicateNotices() {
//        print("🍉 🔍 Проверка дубликатов уведомлений...")
        let descriptor = FetchDescriptor<Notice>()
        
        do {
            let allNotices = try modelContext.fetch(descriptor)
            
            if !allNotices.isEmpty {
                // Группируем по ID
                let groupedById = Dictionary(grouping: allNotices, by: { $0.id })
                
                // Находим дубликаты
                // duplicates - это словарь: [ID: [список дублирующихся уведомлений]]
                let duplicates = groupedById.filter { $0.value.count > 1 }
                
                guard !duplicates.isEmpty else {
//                    print("🍉 ✅ Дубликатов уведомлений не обнаружено")
                    return
                }
//                print("🍉 🗑️ Обнаружены дубликаты уведомлений: \(duplicates.count) ID с дубликатами")
                
                // Для каждого ID оставляем только первый, остальные удаляем
                // id - уникальный идентификатор уведомления (String)
                // noticesList - массив дубликатов с одинаковым ID (массив Notice)
                for (id, noticesList) in duplicates {
//                    print("  🔍 ID \(id): найдено \(noticesList.count) дубликатов")
                    
                    // Проходим по всем дубликатам с одинаковым id
                    // Проверяем: есть ли хотя бы одно уведомление с isRead = true
                    // Сохраняем одно уведомсление из дубликатов в noticeToKeep
                    let noticeToKeep: Notice
                    
                    if let readNotice = noticesList.first(where: { $0.isRead }) {
                        // Есть прочитанная версия - оставляем ее
                        noticeToKeep = readNotice
//                        print("    ✓ Сохраняем ПРОЧИТАННУЮ версию")
                    } else {
                        // Все непрочитанные - оставляем первую
                        noticeToKeep = noticesList.first!
//                        print("    ✓ Сохраняем первую версию (все непрочитанные)")
                    }
                    
                    // Удаляем все кроме noticeToKeep
                    for notice in noticesList where notice.persistentModelID != noticeToKeep.persistentModelID {
                        modelContext.delete(notice)
//                        print("    ✗ Удалён дубликат: '\(notice.title)'")
                    }
                }
                
                saveContext()
//                loadNoticesFromSwiftData()
//                updateUnreadStatus()
            }
        } catch {
            print("🍉 ❌ Ошибка при удалении дубликатов: \(error)")
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
//        print("📊 Непрочитанных уведомлений: \(notices.filter { !$0.isRead }.count)")
    }
    
    // MARK: - Mark as Read
    func markAsRead(noticeId: String) {
        // Ищем уведомление по ID в массиве
        guard let notice = notices.first(where: { $0.id == noticeId }) else {
//            print("🍉 ⚠️ Уведомление с ID \(noticeId) не найдено")
            return
        }
        
        guard !notice.isRead else {
//            print("🍉 ℹ️ Уведомление уже прочитано")
            return
        }
        
        notice.isRead = true
        saveContext()
        updateUnreadStatus()
//        print("🍉 ✅ Уведомление \(noticeId) отмечено как прочитанное")
        
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
//        print("🍉 🗑️ Уведомление удалено, осталось: \(notices.count)")
        
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
//        print("🍉 ➕ Уведомление добавлено, всего: \(notices.count)")
        
        updateUnreadStatus()
    }
    
    // MARK: - Save Context
    
    private func saveContext() {
        do {
            try modelContext.save()
//            print("🍉 💾 SwiftData контекст сохранён")
        } catch {
//            print("🍉 ❌ Ошибка сохранения контекста: \(error)")
            errorMessage = "Ошибка сохранения данных"
            showErrorMessageAlert = true
            hapticManager.notification(type: .error)
        }
    }
    
    // MARK: - Local Notifications
    
    /// Отправить локальное уведомление о новых уведомлениях
    private func sendLocalNotification(count: Int) {
        
        guard isNotificationOn else { return }
        
        if isSoundNotificationOn {
            hapticManager.notification(type: .success)
        }
        
//        print("🍉 🔔 Отправлено локальное уведомление: \(count) новых уведомлений")
    }
    
}


// MARK: - Preview Helper

extension NoticeViewModel {

    /// Создание mock ViewModel для Preview
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

        // Добавляем mock данные
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
