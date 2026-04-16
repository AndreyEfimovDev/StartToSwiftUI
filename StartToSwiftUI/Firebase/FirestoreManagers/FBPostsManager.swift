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

#warning("Delete this func before deployment to App Store")
    func uploadDevDataPostsToFirebase() async {
        var successCount = 0
        
        /*
         for post in newPosts {
             let datePrefix = DateFormatter.yyyyMMdd.string(from: post.date)
             let trimmedUUID = String(post.id.suffix(from: post.id.index(post.id.startIndex, offsetBy: 11)))
             post.id = "\(datePrefix)_\(trimmedUUID)"
             dataSource.insert(post)
         }

         */
        
        for post in DevData.postsForCloud {
            let datePrefix = DateFormatter.yyyyMMdd.string(from: post.date)
            let trimmedUUID = String(post.id.suffix(from: post.id.index(post.id.startIndex, offsetBy: 11)))
            post.id = "\(datePrefix)_\(trimmedUUID)"

            let data: [String: Any] = [
                "category": post.category,
                "title": post.title,
                "intro": post.intro,
                "author": post.author,
                "post_type": post.postType.rawValue,
                "url_string": post.urlString,
                "post_platform": post.postPlatform.rawValue,
                "post_date": Timestamp(date: post.postDate ?? Date()),
                "study_level": post.studyLevel.rawValue,
                "date": Timestamp(date: post.date)
            ]
            
            do {
                try await postsCollection.document(post.id).setData(data)
                successCount += 1
                log("✅ Migrated: \(post.title)", level: .info)
            } catch {
                log("❌ Failed: \(post.title) — \(error.localizedDescription)", level: .error)
            }
        }
        log("🏁 uploadDevDataPostsToFirebase complete: \(successCount)/\(DevData.postsForCloud.count) posts", level: .info)
    }
}

// MARK: - Firestore Posts Manager Protocol
protocol FBPostsManagerProtocol {
    func fetchFBPosts(after: Date?) async -> Result<[FBPostModel], FBFetchError>
    func uploadDevDataPostsToFirebase() async
}
