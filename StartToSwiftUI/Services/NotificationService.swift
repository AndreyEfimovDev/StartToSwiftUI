//
//  NotificationService.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 14.11.2025.
//

import Foundation
import SwiftUI

class NotificationService: ObservableObject {
    
    private let fileManager = FileStorageService.shared
    private let hapticManager = HapticService.shared
    private let networkService = NetworkService()

    @Published var errorMessage: String?
    @Published var showErrorMessageAlert = false

    @Published var notices: [Notice] = []
        
    func importNotificationsFromCloud(
        urlString: String = Constants.cloudNotificationsURL,
        completion: @escaping () -> Void
    ) {
        errorMessage = nil
        showErrorMessageAlert = false
        
        networkService.fetchPostsFromURL(from: urlString) { [weak self] (result: Result<[Notice], Error>) in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let cloudResponse):
                    
                    if !cloudResponse.isEmpty {
                        print("✅ Successfully imported \(cloudResponse.count) notifications from the cloud")

                        // Selecting Cloud posts with unique Titles only -  - do not append such posts from Cloud
                        let cloudNoticesAfterCheckForUniqueID = cloudResponse.filter { noticeFromCloud in
                            !(self?.notices.contains(where: { $0.id == noticeFromCloud.id }) ?? false)
                        }
                        // Appending loaded notifications to notices[]
                        self?.notices.append(contentsOf: cloudNoticesAfterCheckForUniqueID)
                        self?.hapticManager.notification(type: .success)
//                        if let latestDateOfPost = self?.getLatestDateFromNotifications(notes: cloudResponse) {
//                            self?.dateOfLastNotice = latestDateOfPost
//                        }
                        print("✅ Successfully appended \(cloudNoticesAfterCheckForUniqueID.count) notifications from the cloud")
                    } else {
                        self?.hapticManager.impact(style: .light)
                        print("☑️ No new notifications from the cloud.")
                        
                    }
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.showErrorMessageAlert = true
                    self?.hapticManager.notification(type: .error)
                    print("❌ Cloud import error: \(error.localizedDescription)")
                }
                completion()
            }
        }
    }

    private func getLatestDateFromNotifications(notes: [Notice]) -> Date? {
        guard !notes.isEmpty else { return nil }
        
        return notes.max(by: { $0.noticeDate < $1.noticeDate })?.noticeDate
    }
    
    func isReadSet(notice: Notice) {
        
        if let index = notices.firstIndex(of: notice) {
                notices[index].isRead = true
        }
    }

}
