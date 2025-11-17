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
    private let networkService = NetworkService()

    @Published var errorMessage: String?
    @Published var showErrorMessageAlert = false

    @Published var notices: [Notice] = [] {
        didSet {
            fileManager.saveData(
                notices,
                fileName: Constants.localNoticesFileName
            ) { [weak self] result in
                
                self?.errorMessage = nil
                self?.showErrorMessageAlert = false
                
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        print("🍉✅ NVM(notices - didSet): Notices saved successfully.")
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                        self?.showErrorMessageAlert = true
                        self?.hapticManager.notification(type: .error)
                        print("🍉❌ NVM(notices - didSet): Failed to save notices: \(error)")
                    }
                }
            }
            
        }
    }
    
    init() {
        
        // Loading notices from a local JSON file
        if fileManager.checkIfFileExists(fileName: Constants.localNoticesFileName) {
            self.loadNotices()
        }
        // Import notices from Cloud
        self.importNoticesFromCloud()
        
    }
    
    
    private func loadNotices() {
        fileManager.loadData(
            fileName: Constants.localNoticesFileName
        ) { [weak self] (result: Result<[Notice], FileStorageError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let loadedNotices):
                    print("🍉✅ NVM(loadNotices): Successfully received array of notices from JSON file.")
                    if !loadedNotices.isEmpty {
                        // Updating App posts
                        self?.notices = loadedNotices
                        self?.hapticManager.notification(type: .success)
                        print("🍉✅ NVM(loadNotices): Successfully loaded \(loadedNotices.count) notices a local JSON file.")
                    } else {
                        self?.notices = []
                        self?.hapticManager.impact(style: .light)
                        print("🍉☑️ NVM(loadNotices): Array of notices from a local JSON file is empty.")
                        
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.showErrorMessageAlert = true
                    self?.hapticManager.notification(type: .error)
                    print("🍉❌ NVM(loadNotices): Local load error: \(error.localizedDescription)")
                }
            }
        }
    }

    func importNoticesFromCloud(
        urlString: String = Constants.cloudNoticesURL
    ) {
        errorMessage = nil
        showErrorMessageAlert = false
        
        networkService.fetchDataFromURL(
            from: urlString
        ) { [weak self] (result: Result<[Notice], Error>) in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let cloudResponse):
                    
                    if !cloudResponse.isEmpty {
                        print("🍉✅ NVN: Successfully imported \(cloudResponse.count) notices from the cloud")

                        // Selecting Cloud notices with unique ID - append such posts from Cloud
                        let cloudNoticesAfterCheckForUniqueID = cloudResponse.filter { noticeFromCloud in
                            !(self?.notices.contains(where: { $0.id == noticeFromCloud.id }) ?? false)
                        }
                        print("🍉✅ NVN: Cloud notices with unique ID  \(cloudNoticesAfterCheckForUniqueID.count)")

                        
                        if !cloudNoticesAfterCheckForUniqueID.isEmpty {
                            self?.notices.append(contentsOf: cloudNoticesAfterCheckForUniqueID)
                            self?.hapticManager.notification(type: .success)
                            print("🍉✅ NVN: Successfully appended \(cloudNoticesAfterCheckForUniqueID.count) notifications from the cloud")
                        } else {
                            print("🍉✅ NVN: No new notices from the cloud")
                        }
                    } else {
                        self?.hapticManager.impact(style: .light)
                        print("🍉☑️ NVN: Array of notifications from the cloud is empty.")
                    }
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.showErrorMessageAlert = true
                    self?.hapticManager.notification(type: .error)
                    print("🍉❌ NVN: Cloud import error: \(error.localizedDescription)")
                }
            }
        }
    }

    private func getLatestDateFromNotifications(notes: [Notice]) -> Date? {
        guard !notes.isEmpty else { return nil }
        
        return notes.max(by: { $0.noticeDate < $1.noticeDate })?.noticeDate
    }
    
    func isReadSetTrue(notice: Notice) {
        if let index = notices.firstIndex(of: notice) {
            notices[index].isRead = true
        }
    }
    
    func isReadToggle(notice: Notice) {
        if let index = notices.firstIndex(of: notice) {
                notices[index].isRead.toggle()
        }
    }


    func deleteNotice(notice: Notice?) {
        if let validNotice = notice {
            if let index = notices.firstIndex(of: validNotice) {
                notices.remove(at: index)
            }
        } else {
            print("🍉 ❌ NVN(deletePost): passed notice is nil")
        }
    }

}
