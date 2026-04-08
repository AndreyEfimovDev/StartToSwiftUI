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
            let posts = snapshot.documents.compactMap{ FBPostModel(document: $0) }
            log("🔥 Firebase: received \(posts.count) posts", level: .info)
            return .success(posts)
        } catch let error as NSError {
            // Firestore offline error code = 14 (unavailable)
            if error.domain == FirestoreErrorDomain,
               error.code == FirestoreErrorCode.unavailable.rawValue {
                log("📵 Firebase: network unavailable", level: .warning)
                return .failure(.networkUnavailable)
            }
            log("❌ Firebase: error: \(error.localizedDescription)", level: .error)
            return .failure(.unknown(error))
        }
    }

    func uploadDevDataPostsToFirebase() async {
        
    }
}

// MARK: - Firestore Posts Manager Protocol
protocol FBPostsManagerProtocol {
    func fetchFBPosts(after: Date?) async -> Result<[FBPostModel], FBFetchError>
    func uploadDevDataPostsToFirebase() async
}
