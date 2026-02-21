//
//  FBPostsManager.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 21.02.2026.
//

import Foundation
import FirebaseFirestore

// MARK: - Firestore Manager
final class FBPostsManager: FBPostsManagerProtocol {
    
    init() {}
    
    private let postsCollection: CollectionReference = Firestore.firestore().collection("posts")

    func getAllPosts(after date: Date?) async -> [FBPostModel] {
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
            return posts
        } catch {
            log("❌ Firebase: getAllPosts_after_date error: \(error.localizedDescription)", level: .error)
            return []
        }
    }

}

// MARK: - Firestore Protocol
protocol FBPostsManagerProtocol {
    func getAllPosts(after: Date?) async -> [FBPostModel]
}
