//
//  FBNoticeManager.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 20.02.2026.
//

import Foundation
import FirebaseFirestore

// MARK: - Firestore Notices Manager
final class FBNoticesManager: FBNoticesManagerProtocol {
    
    init() {}
    
    private let noticesCollection: CollectionReference = Firestore.firestore().collection("notices")
    
    func fetchFBNotices(after date: Date) async -> Result<[FBNoticeModel], FBFetchError> {
        do {
            let snapshot = try await noticesCollection
                .whereField("notice_date", isGreaterThan: Timestamp(date: date))
                .getDocuments()
            let notices = snapshot.documents.compactMap { FBNoticeModel(document: $0) }
            log("🔥 Firebase: received \(notices.count) notices", level: .info)
            return .success(notices)
        } catch let error as NSError {
            if error.domain == FirestoreErrorDomain,
               error.code == FirestoreErrorCode.unavailable.rawValue {
                log("📵 Firebase: network unavailable (notices)", level: .warning)
                return .failure(.networkUnavailable)
            }
            log("❌ Firebase: fetchFBNotices error: \(error.localizedDescription)", level: .error)
            return .failure(.unknown(error))
        }
    }
}

// MARK: - Firestore Protocol
protocol FBNoticesManagerProtocol {
    func fetchFBNotices(after: Date) async -> Result<[FBNoticeModel], FBFetchError>
}
