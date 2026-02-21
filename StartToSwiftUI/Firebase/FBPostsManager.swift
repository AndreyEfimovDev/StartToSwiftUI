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
    
    let networkService = NetworkManager(urlString: Constants.cloudPostsURL)

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
    
    func migratePostsFromGitHubToFirebase() async {
        
        // Step 1: load posts from GitHub
        guard let cloudResponse: [CodablePost] = try? await networkService.fetchDataFromURLAsync() else {
            log("❌ Migration: failed to fetch from GitHub", level: .error)
            return
        }
        
        var successCount = 0
        
        // Step 2: write each post to Firestore with original id as documentId
        for codablePost in cloudResponse {
            let data: [String: Any] = [
                "category": codablePost.category,
                "title": codablePost.title,
                "intro": codablePost.intro,
                "author": codablePost.author,
                "post_type": codablePost.postType.rawValue,
                "url_string": codablePost.urlString,
                "post_platform": codablePost.postPlatform.rawValue,
                "post_date": Timestamp(date: codablePost.postDate ?? Date()),
                "study_level": codablePost.studyLevel.rawValue,
                "date": Timestamp(date: codablePost.date)
            ]
            
            do {
                try await postsCollection.document(codablePost.id).setData(data)
                successCount += 1
                log("✅ Migrated: \(codablePost.title)", level: .info)
            } catch {
                log("❌ Failed to migrate: \(codablePost.title) — \(error.localizedDescription)", level: .error)
            }
        }
        
        log("🏁 Migration complete: \(successCount)/\(cloudResponse.count) posts", level: .info)
    }

}

// MARK: - Firestore Protocol
protocol FBPostsManagerProtocol {
    func getAllPosts(after: Date?) async -> [FBPostModel]
    func migratePostsFromGitHubToFirebase() async
}
