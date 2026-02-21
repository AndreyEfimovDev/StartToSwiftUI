//
//  FBNoticeManager.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 20.02.2026.
//

import Foundation
//import FirebaseCore
import FirebaseFirestore

// MARK: - Firestore Manager
final class FBNoticesManager: FBNoticesManagerProtocol {
    
    init() {}
    
    private let noticesCollection: CollectionReference = Firestore.firestore().collection("notices")
    
//    func getAllNotices() async -> [FBNoticeModel] {
//        do {
//            let snapshot = try await noticesCollection.getDocuments()
//            let notices = snapshot.documents.compactMap{ FBNoticeModel(document: $0) }
//            log("🔥 Firebase: received \(notices.count) notices", level: .info)
//            return notices
//        } catch {
//            log("❌ Firebase getAllNotices error: \(error.localizedDescription)", level: .error)
//            return []
//        }
//    }
    
    func getAllNotices(after date: Date) async -> [FBNoticeModel] {
        do {
            let snapshot = try await noticesCollection
                .whereField("notice_date", isGreaterThan: Timestamp(date: date))
                .getDocuments()
            let notices = snapshot.documents.compactMap{ FBNoticeModel(document: $0) }
            log("🔥 Firebase: received \(notices.count) notices", level: .info)
            return notices
        } catch {
            log("❌ Firebase getAllNotices_after_date error: \(error.localizedDescription)", level: .error)
            return []
        }
    }

}

// MARK: - Firestore Protocol
protocol FBNoticesManagerProtocol {
//    func getAllNotices() async -> [FBNoticeModel]
    func getAllNotices(after: Date) async -> [FBNoticeModel]
}
