//
//  NotificationCentre.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 14.11.2025.
//
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
class NoticeViewModel: ObservableObject {
    
    // MARK: - Properties
    
    var modelContext: ModelContext? = nil {
        didSet {
            if modelContext != nil {
                // Загружаем уведомления из SwiftData - локальные данные
                loadNoticesFromSwiftData()
            }
        }
    }
    private var hasLoadedInitialData = false
    private var hasImportedFromCloud = false // 🔥 Флаг для однократного импорта

    private let hapticManager = HapticService.shared
    private let networkService: NetworkService
    
    @Published var notices: [Notice] = []
    @Published var errorMessage: String?
    @Published var showErrorMessageAlert: Bool = false
    
    // MARK: - AppStorage
    
    @AppStorage("isUserNotified") var isUserNotified: Bool = false
    @AppStorage("isNotificationOn") var isNotificationOn: Bool = true
    @AppStorage("isSoundNotificationOn") var isSoundNotificationOn: Bool = true
    @AppStorage("dateOfLatestNoticesUpdate") var dateOfLatestNoticesUpdate: Date = Date.distantPast
    
    // MARK: - Init
    
    init(
        modelContext: ModelContext? = nil,
        networkService: NetworkService = NetworkService(baseURL: Constants.cloudNoticesURL)
    ) {
        self.modelContext = modelContext
        self.networkService = networkService
    }
    
    // MARK: - SwiftData Operations
    
    private var safeContext: ModelContext {
        guard let context = modelContext else {
            fatalError("ModelContext не установлен")
        }
        return context
    }

    /// Загрузка уведомлений из SwiftData
    func loadNoticesFromSwiftData() {
        
        guard let context = modelContext else {
            print("🍉 ⏩ Пропускаем загрузку: данные уже загружены")
            return
        }
        
        let descriptor = FetchDescriptor<Notice>(
            sortBy: [SortDescriptor(\.noticeDate, order: .reverse)]
        )
        
        do {
            notices = try context.fetch(descriptor)
            print("🍉 ✅ Загружено \(notices.count) уведомлений из SwiftData (однократно)")
            hasLoadedInitialData = true
            // 🔥 Импорт из облака делаем только после загрузки локальных данных
            if !hasImportedFromCloud {
                // Импортируем новые уведомления из облака
                importNoticesFromCloud()
                hasImportedFromCloud = true
            }

        } catch {
            errorMessage = "Ошибка загрузки уведомлений"
            showErrorMessageAlert = true
            hapticManager.notification(type: .error)
            print("🍉 ❌ Ошибка загрузки из SwiftData: \(error)")
        }
    }
    
    /// Отметить уведомление как прочитанное
    func isReadSetTrue(notice: Notice) {
        notice.isRead = true
        saveContext()
        loadNoticesFromSwiftData()
    }
    
    /// Переключить статус прочтения
    func isReadToggle(notice: Notice) {
        notice.isRead.toggle()
        saveContext()
        loadNoticesFromSwiftData()
    }
    
    /// Удалить уведомление
    func deleteNotice(notice: Notice?) {
        guard let validNotice = notice else {
            print("🍉 ❌ NVM(deleteNotice): переданное уведомление nil")
            return
        }
        
        safeContext.delete(validNotice)
        saveContext()
        loadNoticesFromSwiftData()
    }
    
    /// Удалить все уведомления
    func deleteAllNotices(completion: @escaping () -> Void) {
        do {
            try safeContext.delete(model: Notice.self)
            saveContext()
            loadNoticesFromSwiftData()
            completion()
        } catch {
            errorMessage = "Ошибка удаления уведомлений"
            showErrorMessageAlert = true
            hapticManager.notification(type: .error)
            print("🍉 ❌ Ошибка удаления всех уведомлений: \(error)")
        }
    }
    
    /// Сохранение контекста
    private func saveContext() {
        do {
            try safeContext.save()
            print("🍉 💾 SwiftData контекст сохранён")
            // 🌥️ iCloud автоматически синхронизирует изменения!
        } catch {
            errorMessage = "Ошибка сохранения данных"
            showErrorMessageAlert = true
            hapticManager.notification(type: .error)
            print("🍉 ❌ Ошибка сохранения контекста: \(error)")
        }
    }
    
    // MARK: - Cloud Import
    
    /// Импорт уведомлений из облака
    func importNoticesFromCloud() {
        
        errorMessage = nil
        showErrorMessageAlert = false
        
        // Явно указываем тип для generic параметра
        networkService.fetchDataFromURL { [weak self] (result: Result<[CodableNotice], Error>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let cloudResponse):
                    
                    guard !cloudResponse.isEmpty else {
                        print("🍉 ☑️ NVM(importNoticesFromCloud): Массив уведомлений из облака пуст")
                        return
                    }
                    
                    print("🍉 NVM(importNoticesFromCloud): Успешно импортировано \(cloudResponse.count) уведомлений из облака (однократно)")
                    print("🍉 NVM(importNoticesFromCloud): Последнее обновление: \(self.dateOfLatestNoticesUpdate.formatted(date: .abbreviated, time: .shortened))")
                    self.hasImportedFromCloud = true
                    
                    // Фильтруем уведомления с датой новее последнего обновления
                    let cloudNoticesWithNewerDates = cloudResponse.filter {
                        $0.noticeDate > self.dateOfLatestNoticesUpdate
                    }
                    print("🍉 NVM(importNoticesFromCloud): Уведомлений с новой датой: \(cloudNoticesWithNewerDates.count)")
                    
                    guard !cloudNoticesWithNewerDates.isEmpty else {
                        print("🍉 ☑️ NVM(importNoticesFromCloud): Нет новых уведомлений")
                        return
                    }
                    
                    // Помечаем пользователя как неуведомлённого
                    self.isUserNotified = false
                    
                    // Обновляем дату последнего обновления
                    if let latestNoticeDate = cloudNoticesWithNewerDates.map({ $0.noticeDate }).max() {
                        self.dateOfLatestNoticesUpdate = latestNoticeDate
                        print("🍉 NVM(importNoticesFromCloud): Новая дата последнего обновления: \(self.dateOfLatestNoticesUpdate.formatted(date: .abbreviated, time: .shortened))")
                    }
                    
                    // Фильтруем уведомления с уникальным ID
                    let existingIds = Set(self.notices.map { $0.id })
                    let newLoadedNotices = cloudNoticesWithNewerDates
                        .filter { !existingIds.contains($0.id) }
                        .map { NoticeMigrationHelper.convertFromCodable($0) }
                    
                    print("🍉 NVM(importNoticesFromCloud): Уведомлений с уникальным ID: \(newLoadedNotices.count)")
                    
                    if !newLoadedNotices.isEmpty {
                        // Добавляем новые уведомления в SwiftData
                        for notice in newLoadedNotices {
                            self.safeContext.insert(notice)
                        }
                        self.saveContext()
                        self.refreshNotices()

                        // Отправляем уведомление пользователю
                        if self.isNotificationOn {
                            self.sendLocalNotification(count: newLoadedNotices.count)
                        }
                        print("🍉 ✅ NVM(importNoticesFromCloud): Успешно добавлено \(newLoadedNotices.count) уведомлений")
                    } else {
                        print("🍉 ☑️ NVM(importNoticesFromCloud): Нет новых уведомлений из облака")
                    }
                    
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showErrorMessageAlert = true
                    self.hapticManager.notification(type: .error)
                    print("🍉 ❌ NVM(importNoticesFromCloud): Ошибка импорта: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func refreshNotices() {
        guard let context = modelContext else {
            print("🍉 ⚠️ Невозможно обновить: ModelContext не установлен")
            return
        }
        
        let descriptor = FetchDescriptor<Notice>(
            sortBy: [SortDescriptor(\.noticeDate, order: .reverse)]
        )
        
        do {
            self.notices = try context.fetch(descriptor)
            print("🍉 🔄 Список уведомлений обновлен, теперь: \(self.notices.count)")
        } catch {
            print("🍉 ❌ Ошибка обновления уведомлений: \(error)")
        }
    }

    
    // MARK: - Helper Methods
    
    /// Количество непрочитанных уведомлений
    var unreadNoticesCount: Int {
        notices.filter { !$0.isRead }.count
    }
    
    /// Есть ли непрочитанные уведомления
    var hasUnreadNotices: Bool {
        unreadNoticesCount > 0
    }
    
    /// Отметить все как прочитанные
    func markAllAsRead() {
        for notice in notices where !notice.isRead {
            notice.isRead = true
        }
        saveContext()
        loadNoticesFromSwiftData()
        isUserNotified = true
    }
    
    /// Получить уведомление по ID
    func getNotice(id: String) -> Notice? {
        notices.first(where: { $0.id == id })
    }
    
    // MARK: - Local Notifications
    
    /// Отправить локальное уведомление о новых уведомлениях
    private func sendLocalNotification(count: Int) {
        guard isNotificationOn else { return }
        
        // Здесь можно добавить UNUserNotificationCenter
        // для отправки системного уведомления
        
        if isSoundNotificationOn {
            hapticManager.notification(type: .success)
        }
        
        print("🍉 🔔 Отправлено локальное уведомление: \(count) новых уведомлений")
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
