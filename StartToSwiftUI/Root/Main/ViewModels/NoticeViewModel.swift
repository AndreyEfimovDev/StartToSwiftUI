//
//  NotificationCentre.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 14.11.2025.
//

import Foundation
import SwiftUI

class NoticeViewModel: ObservableObject {
    
    private let fileManager = JSONFileManager.shared
    private let hapticManager = HapticService.shared
    private let networkService: NetworkService

    @Published var notices: [Notice] = []
    @Published var errorMessage: String?
    @Published var showErrorMessageAlert = false
    
    init(
        networkService: NetworkService = NetworkService(baseURL: Constants.cloudNoticesURL)
    ) {
        self.networkService = networkService
        
        // Loading notices from a local JSON file and after notices imported from Cloud
        self.loadLocalNotices(from: Constants.localNoticesFileName) {[weak self] localNotices in
            self?.importNoticesFromCloud(localNotices: localNotices)
        }
    }

    private func loadLocalNotices(from urlOnLocalNotices: String, completion: @escaping ([Notice]) -> Void) {
        
            fileManager.loadData(fileName: urlOnLocalNotices) { [weak self] (result: Result<[Notice], FileStorageError>) in
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
    
    
    private func importNoticesFromCloud(localNotices: [Notice]) {
        
        errorMessage = nil
        showErrorMessageAlert = false
        
        networkService.fetchDataFromURL() { [weak self] (result: Result<[Notice], Error>) in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let cloudResponse):
                    
                    if !cloudResponse.isEmpty {
                        print("🍉 NVN: Successfully imported \(cloudResponse.count) notices from the cloud")

                        // Selecting Cloud notices with unique ID - append such posts from Cloud
                        let cloudNoticesAfterCheckForUniqueID = cloudResponse.filter { noticeFromCloud in
                            !(self?.notices.contains(where: { $0.id == noticeFromCloud.id }) ?? false)
                        }
                        print("🍉 NVN(importNoticesFromCloud): Cloud notices with unique ID  \(cloudNoticesAfterCheckForUniqueID.count)")

                        
                        if !cloudNoticesAfterCheckForUniqueID.isEmpty {
                            let mergedNotices = localNotices + cloudNoticesAfterCheckForUniqueID
                            self?.notices = mergedNotices
                            self?.saveNotices()
                            print("🍉 NVN(importNoticesFromCloud): Successfully appended \(cloudNoticesAfterCheckForUniqueID.count) notifications from the cloud")
                        } else {
                            print("🍉 NVN(importNoticesFromCloud): No new notices from the cloud")
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

    
    private func getLatestDateFromNotices(notices: [Notice]) -> Date? {
        guard !notices.isEmpty else {
            print("🍉 ☑️ NVN(getLatestDateFromNotices): notices is empty")

            return nil
        }
        
        return notices.max(by: { $0.noticeDate < $1.noticeDate })?.noticeDate
    }
    
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

}
