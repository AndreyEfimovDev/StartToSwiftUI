//
//  NotificationCentre.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 14.11.2025.
//
//

//
//   AudioServicesPlaySystemSound(1002) // New mail
//   AudioServicesPlaySystemSound(1007) // Mail sent
//   AudioServicesPlaySystemSound(1012) // Time passing
//   AudioServicesPlaySystemSound(1013) // Low power
//   AudioServicesPlaySystemSound(1020) // Suspense
//   AudioServicesPlaySystemSound(1022) // Anticipate
//   AudioServicesPlaySystemSound(1025) // Bloom
//   AudioServicesPlaySystemSound(1030) // Sherwood Forest
//   AudioServicesPlaySystemSound(1032) // Spell
//   AudioServicesPlaySystemSound(1033) // Calypso
//   AudioServicesPlaySystemSound(1034) // News flash

import Foundation
import SwiftUI
import AudioToolbox

class NoticeViewModel: ObservableObject {
    
    private let fileManager = JSONFileManager.shared
    private let hapticManager = HapticService.shared
    private let networkService: NetworkService

    @Published var notices: [Notice] = []
    @Published var errorMessage: String?
    @Published var showErrorMessageAlert = false
    
    @Published var selectedNoticeIDs: Set<String> = []
    @Published var isSelectionMode: Bool = false
    @Published var isNewNotices: Bool = false

    @AppStorage("isUserNotified") var isUserNotified: Bool = false
    @AppStorage("isNotificationOn") var isNotificationOn: Bool = true
    @AppStorage("isSoundNotificationOn") var isSoundNotificationOn: Bool = true
    @AppStorage("dateOfLatestNoticesUpdate") var dateOfLatestNoticesUpdate: Date = Date.distantPast

    init(
        networkService: NetworkService = NetworkService(baseURL: Constants.cloudNoticesURL)
    ) {
        self.networkService = networkService
        
        // Loading notices from a local JSON file and after notices imported from Cloud
        if fileManager.checkIfFileExists(fileName: Constants.localNoticesFileName) {
            
            self.loadLocalNotices(from: Constants.localNoticesFileName) {[weak self] localNotices in
                self?.importNoticesFromCloud()
            }
        } else {
            self.importNoticesFromCloud()
        }
        
    }
    
    // MARK: PRIVATE FUNCTIONS
    
    private func loadLocalNotices(from urlOnLocalNotices: String, completion: @escaping ([Notice]) -> Void) {
        
        fileManager.loadData(
            fileName: urlOnLocalNotices
        ) { [weak self] (result: Result<[Notice], FileStorageError>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let loadedNotices):
                        print("🍉 NVM(loadNotices): Successfully received array of notices from JSON file.")
                        if !loadedNotices.isEmpty {
                            // Updating App posts
                            self?.notices = loadedNotices
                            print("🍉 NVM(loadNotices): Successfully loaded \(loadedNotices.count) notices a local JSON file.")
                        } else {
                            print("🍉☑️ NVM(loadNotices): Array of notices from a local JSON file is empty.")
                        }
                        completion(loadedNotices)
                        
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                        self?.showErrorMessageAlert = true
                        self?.hapticManager.notification(type: .error)
                        print("🍉❌ NVM(loadNotices): Local load error: \(error.localizedDescription)")
                        completion([])
                    }
                }
            }
    }
    
    
    private func importNoticesFromCloud() {
        
        errorMessage = nil
        showErrorMessageAlert = false
        
        networkService.fetchDataFromURL() { [weak self] (result: Result<[Notice], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let cloudResponse):
                    
                    if !cloudResponse.isEmpty {
                        print("🍉 NVN(importNoticesFromCloud): Successfully imported \(cloudResponse.count) notices from the cloud")
                        print("🍉 NVN(importNoticesFromCloud): The latest notices update  \(self?.dateOfLatestNoticesUpdate.formatted(date: .abbreviated, time: .shortened) ?? "")")

                        // Select Cloud notices with date older than date of latest notices update
                        let cloudNoticesWithNewerDates = cloudResponse.filter {
                            $0.noticeDate > (self?.dateOfLatestNoticesUpdate ?? .distantPast)
                        }
                        print("🍉 NVN(importNoticesFromCloud): Cloud notices with newer dates  \(cloudNoticesWithNewerDates.count)")
                        
                        if !cloudNoticesWithNewerDates.isEmpty {
                            
                            // Make User informed of new notifications
                            if let isNotificationOnChecked = self?.isNotificationOn {
                                if isNotificationOnChecked {
                                    self?.isNewNotices = true
                                }
                            }
                            
                            // Set a new date of latest notices update
                            if let latestNoticeDate = cloudNoticesWithNewerDates.map({ $0.noticeDate }).max() {
                                self?.dateOfLatestNoticesUpdate = latestNoticeDate
                            }
                            print("🍉 NVN(importNoticesFromCloud): New date of latest notices update  \(self?.dateOfLatestNoticesUpdate.formatted(date: .abbreviated, time: .shortened) ?? "")")

                            // Select Cloud notices with unique ID
                            let newLoadedNotices = cloudNoticesWithNewerDates.filter { notice in
                                !(self?.notices.contains(where: { $0.id == notice.id }) ?? false)
                            }
                            print("🍉 NVN(importNoticesFromCloud): Cloud notices with unique ID  \(newLoadedNotices.count)")
                                                        
                            if !newLoadedNotices.isEmpty {
                                self?.notices.append(contentsOf: newLoadedNotices)
                                self?.saveNotices()
                                print("🍉 NVN(importNoticesFromCloud): Successfully appended \(newLoadedNotices.count) notifications from the cloud")
                            } else {
                                print("🍉 NVN(importNoticesFromCloud): No new notices from the cloud")
                            }
                        }
                        
                    } else {
                        print("🍉☑️ NVN(importNoticesFromCloud): Array of notifications from the cloud is empty.")
                    }
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.showErrorMessageAlert = true
                    self?.hapticManager.notification(type: .error)
                    print("🍉❌ NVN(importNoticesFromCloud): Cloud import error: \(error.localizedDescription)")
                }
            }
        }
    }

    
    private func saveNotices() {
        
        fileManager.saveData(notices, fileName: Constants.localNoticesFileName) { [weak self] result in
            
            self?.errorMessage = nil
            self?.showErrorMessageAlert = false
            
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("🍉 NVM(saveNotices): Notices saved successfully.")
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.showErrorMessageAlert = true
                    self?.hapticManager.notification(type: .error)
                    print("🍉❌ NVM(saveNotices): Failed to save notices: \(error)")
                }
            }
        }
    }

//    
//    private func getLatestDateFromNotices(notices: [Notice]) -> Date? {
//        guard !notices.isEmpty else {
//            print("🍉 ☑️ NVN(getLatestDateFromNotices): notices is empty")
//
//            return nil
//        }
//        
//        return notices.max(by: { $0.noticeDate < $1.noticeDate })?.noticeDate
//    }
//    
    
    // MARK: FUNCTIONS

    func isReadSetTrue(notice: Notice) {
        if let index = notices.firstIndex(of: notice) {
            notices[index].isRead = true
            saveNotices()
        } else {
            print("🍉 ❌ NVN(isReadSetTrue): passed notice is nil")
        }
    }
    
    func isReadToggle(notice: Notice) {
        if let index = notices.firstIndex(of: notice) {
            notices[index].isRead.toggle()
            saveNotices()
        }
        else {
            print("🍉 ❌ NVN(isReadToggle): passed notice is nil")
        }
    }

    func deleteNotice(notice: Notice?) {
        if let validNotice = notice {
            if let index = notices.firstIndex(of: validNotice) {
                notices.remove(at: index)
                saveNotices()
            }
        } else {
            print("🍉 ❌ NVN(deletePost): passed notice is nil")
        }
    }

}
