//
//  FBPostsManager.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 21.02.2026.
//

import Foundation
import FirebaseFirestore


enum FBFetchError: Error {
    case networkUnavailable
    case unknown(Error)
}

// MARK: - Firestore Manager
final class FBPostsManager: FBPostsManagerProtocol {
    
    init() {}
    
    private let postsCollection: CollectionReference = Firestore.firestore().collection("posts")

    func fetchFBPosts(after date: Date?) async -> Result<[FBPostModel], FBFetchError> {
        do {
            let query: Query
            if let date {
                query = postsCollection.whereField("date", isGreaterThan: Timestamp(date: date))
            } else {
                query = postsCollection // return all Firebase posts if date = nil
            }

            let snapshot = try await query.getDocuments()
            let decoded = snapshot.documents.map { ($0.documentID, FBPostModel(document: $0)) }
            let posts = decoded.compactMap { $0.1 }
            let droppedIDs = decoded.filter { $0.1 == nil }.map { $0.0 }
            if !droppedIDs.isEmpty {
                log("⚠️ Firebase: \(droppedIDs.count) post document(s) failed to decode: \(droppedIDs)", level: .error)
            }
            log("🔥 Firebase: received \(posts.count) posts", level: .info)
            return .success(posts)
        } catch let error as NSError {
            // Firestore offline error code = 14 (unavailable)
            if error.domain == FirestoreErrorDomain,
               error.code == FirestoreErrorCode.unavailable.rawValue {
                log("📵 Firebase: network unavailable", level: .warning)
                return .failure(.networkUnavailable)
            }
            log("Firebase: error: \(error.localizedDescription)", level: .error)
            return .failure(.unknown(error))
        }
    }
}

// MARK: - Firestore Posts Manager Protocol
protocol FBPostsManagerProtocol {
    func fetchFBPosts(after: Date?) async -> Result<[FBPostModel], FBFetchError>
}
