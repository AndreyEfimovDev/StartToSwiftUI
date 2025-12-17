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
    
    private let modelContext: ModelContext
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
        modelContext: ModelContext,
        networkService: NetworkService = NetworkService(baseURL: Constants.cloudNoticesURL)
    ) {
        self.modelContext = modelContext
        self.networkService = networkService
        
        // Загружаем уведомления из SwiftData
        loadNoticesFromSwiftData()
        
        // Импортируем новые уведомления из облака
        importNoticesFromCloud()
    }
    
    // MARK: - SwiftData Operations
    
    /// Загрузка уведомлений из SwiftData
    func loadNoticesFromSwiftData() {
        let descriptor = FetchDescriptor<Notice>(
            sortBy: [SortDescriptor(\.noticeDate, order: .reverse)]
        )
        
        do {
            notices = try modelContext.fetch(descriptor)
            print("🍉 ✅ Загружено \(notices.count) уведомлений из SwiftData")
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
        
        modelContext.delete(validNotice)
        saveContext()
        loadNoticesFromSwiftData()
    }
    
    /// Удалить все уведомления
    func deleteAllNotices(completion: @escaping () -> Void) {
        do {
            try modelContext.delete(model: Notice.self)
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
            try modelContext.save()
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
                    
                    print("🍉 NVM(importNoticesFromCloud): Успешно импортировано \(cloudResponse.count) уведомлений из облака")
                    print("🍉 NVM(importNoticesFromCloud): Последнее обновление: \(self.dateOfLatestNoticesUpdate.formatted(date: .abbreviated, time: .shortened))")
                    
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
                            self.modelContext.insert(notice)
                        }
                        self.saveContext()
                        self.loadNoticesFromSwiftData()
                        
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



//class NoticeViewModel: ObservableObject {
//    
//    private let fileManager = JSONFileManager.shared
//    private let hapticManager = HapticService.shared
//    private let networkService: NetworkService
//
//    @Published var notices: [Notice] = []
//    @Published var errorMessage: String?
//    @Published var showErrorMessageAlert: Bool = false
//    
//    @AppStorage("isUserNotified") var isUserNotified: Bool = false
//    @AppStorage("isNotificationOn") var isNotificationOn: Bool = true
//    @AppStorage("isSoundNotificationOn") var isSoundNotificationOn: Bool = true
//    @AppStorage("dateOfLatestNoticesUpdate") var dateOfLatestNoticesUpdate: Date = Date.distantPast
//
//    init(
//        networkService: NetworkService = NetworkService(baseURL: Constants.cloudNoticesURL)
//    ) {
//        self.networkService = networkService
//        
//        // Loading notices from a local JSON file and after notices imported from Cloud
//        if fileManager.checkIfFileExists(fileName: Constants.localNoticesFileName) {
//            
//            self.loadLocalNotices(from: Constants.localNoticesFileName) {[weak self] localNotices in
//                self?.importNoticesFromCloud()
//            }
//        } else {
//            self.importNoticesFromCloud()
//        }
//        
//    }
//    
//    // MARK: PRIVATE FUNCTIONS
//    
//    private func loadLocalNotices(from urlOnLocalNotices: String, completion: @escaping ([Notice]) -> Void) {
//        
//        fileManager.loadData(
//            fileName: urlOnLocalNotices
//        ) { [weak self] (result: Result<[Notice], FileStorageError>) in
//                DispatchQueue.main.async {
//                    switch result {
//                    case .success(let loadedNotices):
//                        print("🍉 NVM(loadNotices): Successfully received array of notices from JSON file.")
//                        if !loadedNotices.isEmpty {
//                            // Updating App posts
//                            self?.notices = loadedNotices
//                            print("🍉 NVM(loadNotices): Successfully loaded \(loadedNotices.count) notices a local JSON file.")
//                        } else {
//                            print("🍉☑️ NVM(loadNotices): Array of notices from a local JSON file is empty.")
//                        }
//                        completion(loadedNotices)
//                        
//                    case .failure(let error):
//                        self?.errorMessage = error.localizedDescription
//                        self?.showErrorMessageAlert = true
//                        self?.hapticManager.notification(type: .error)
//                        print("🍉❌ NVM(loadNotices): Local load error: \(error.localizedDescription)")
//                        completion([])
//                    }
//                }
//            }
//    }
//    
//    private func importNoticesFromCloud() {
//        
//        errorMessage = nil
//        showErrorMessageAlert = false
//        
//        networkService.fetchDataFromURL() { [weak self] (result: Result<[Notice], Error>) in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let cloudResponse):
//                    
//                    if !cloudResponse.isEmpty {
//                        print("🍉 NVN(importNoticesFromCloud): Successfully imported \(cloudResponse.count) notices from the cloud")
//                        print("🍉 NVN(importNoticesFromCloud): The latest notices update  \(self?.dateOfLatestNoticesUpdate.formatted(date: .abbreviated, time: .shortened) ?? "")")
//
//                        // Select Cloud notices with date older than date of latest notices update
//                        let cloudNoticesWithNewerDates = cloudResponse.filter {
//                            $0.noticeDate > (self?.dateOfLatestNoticesUpdate ?? .distantPast)
//                        }
//                        print("🍉 NVN(importNoticesFromCloud): Cloud notices with newer dates  \(cloudNoticesWithNewerDates.count)")
//                        
//                        if !cloudNoticesWithNewerDates.isEmpty {
//                            
//                            // Make User informed of new notifications
//                            self?.isUserNotified = false
//                            
//                            // Set a new date of latest notices update
//                            if let latestNoticeDate = cloudNoticesWithNewerDates.map({ $0.noticeDate }).max() {
//                                self?.dateOfLatestNoticesUpdate = latestNoticeDate
//                            }
//                            print("🍉 NVN(importNoticesFromCloud): New date of latest notices update  \(self?.dateOfLatestNoticesUpdate.formatted(date: .abbreviated, time: .shortened) ?? "")")
//
//                            // Select Cloud notices with unique ID
//                            let newLoadedNotices = cloudNoticesWithNewerDates.filter { notice in
//                                !(self?.notices.contains(where: { $0.id == notice.id }) ?? false)
//                            }
//                            print("🍉 NVN(importNoticesFromCloud): Cloud notices with unique ID  \(newLoadedNotices.count)")
//                                                        
//                            if !newLoadedNotices.isEmpty {
//                                self?.notices.append(contentsOf: newLoadedNotices)
//                                self?.saveNotices()
//                                print("🍉 NVN(importNoticesFromCloud): Successfully appended \(newLoadedNotices.count) notifications from the cloud")
//                            } else {
//                                print("🍉 NVN(importNoticesFromCloud): No new notices from the cloud")
//                            }
//                        } else {
//                            print("🍉☑️ NVN(importNoticesFromCloud): No new notifications from the cloud.")
//                        }
//                    } else {
//                        print("🍉☑️ NVN(importNoticesFromCloud): Array of notifications from the cloud is empty.")
//                    }
//                    
//                case .failure(let error):
//                    self?.errorMessage = error.localizedDescription
//                    self?.showErrorMessageAlert = true
//                    self?.hapticManager.notification(type: .error)
//                    print("🍉❌ NVN(importNoticesFromCloud): Cloud import error: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//
//    
//    private func saveNotices() {
//        
//        fileManager.saveData(notices, fileName: Constants.localNoticesFileName) { [weak self] result in
//            
//            self?.errorMessage = nil
//            self?.showErrorMessageAlert = false
//            
//            DispatchQueue.main.async {
//                switch result {
//                case .success:
//                    print("🍉 NVM(saveNotices): Notices saved successfully.")
//                case .failure(let error):
//                    self?.errorMessage = error.localizedDescription
//                    self?.showErrorMessageAlert = true
//                    self?.hapticManager.notification(type: .error)
//                    print("🍉❌ NVM(saveNotices): Failed to save notices: \(error)")
//                }
//            }
//        }
//    }
//
////    
////    private func getLatestDateFromNotices(notices: [Notice]) -> Date? {
////        guard !notices.isEmpty else {
////            print("🍉 ☑️ NVN(getLatestDateFromNotices): notices is empty")
////
////            return nil
////        }
////        
////        return notices.max(by: { $0.noticeDate < $1.noticeDate })?.noticeDate
////    }
////    
//    
//    // MARK: FUNCTIONS
//
//    func isReadSetTrue(notice: Notice) {
//        if let index = notices.firstIndex(of: notice) {
//            notices[index].isRead = true
//            saveNotices()
//        } else {
//            print("🍉 ❌ NVN(isReadSetTrue): passed notice is nil")
//        }
//    }
//    
//    func isReadToggle(notice: Notice) {
//        if let index = notices.firstIndex(of: notice) {
//            notices[index].isRead.toggle()
//            saveNotices()
//        }
//        else {
//            print("🍉 ❌ NVN(isReadToggle): passed notice is nil")
//        }
//    }
//
//    func deleteNotice(notice: Notice?) {
//        if let validNotice = notice {
//            if let index = notices.firstIndex(of: validNotice) {
//                notices.remove(at: index)
//                saveNotices()
//            }
//        } else {
//            print("🍉 ❌ NVN(deletePost): passed notice is nil")
//        }
//    }
//
//}
