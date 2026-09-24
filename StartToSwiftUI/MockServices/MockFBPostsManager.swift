//
//  MockFBPostsManager.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 26.02.2026.
//

import Foundation

//#if DEBUG
final class MockFBPostsManager: FBPostsManagerProtocol {
    // MARK: - Control Properties
    var postsToReturn: [FBPostModel] = []
    var fetchCallCount = 0
    var shouldSimulateDelay = false
    var shouldSimulateNetworkError = false  // ← новое
    
    // MARK: - Factory Methods
    static func mockPosts(_ posts: [FBPostModel]) -> MockFBPostsManager {
        let mock = MockFBPostsManager()
        mock.postsToReturn = posts
        return mock
    }
    
    static func mockEmpty() -> MockFBPostsManager {
        MockFBPostsManager()
    }
    
    static func mockNetworkError() -> MockFBPostsManager {  // ← новое
        let mock = MockFBPostsManager()
        mock.shouldSimulateNetworkError = true
        return mock
    }
    
    // MARK: - Protocol Implementation
    func fetchFBPosts(after: Date?) async -> Result<[FBPostModel], FBFetchError> {
        fetchCallCount += 1
        if shouldSimulateDelay {
            try? await Task.sleep(nanoseconds: 500_000_000)
        }
        if shouldSimulateNetworkError {
            return .failure(.networkUnavailable)
        }
        guard let after else { return .success(postsToReturn) }
        return .success(postsToReturn.filter { $0.date > after })
    }

    func hasFBPosts(after date: Date) async -> Result<Bool, FBFetchError> {
        if shouldSimulateDelay {
            try? await Task.sleep(nanoseconds: 500_000_000)
        }
        if shouldSimulateNetworkError {
            return .failure(.networkUnavailable)
        }
        return .success(postsToReturn.contains { $0.date > date })
    }
}

// MARK: - Preview Data (DEBUG-режим приложения)
extension MockFBPostsManager {
    /// Мок с постами из `PreviewData` — composition root подставляет его
    /// вместо реального Firestore, когда `DebugConfig.useRealServices == false`.
    static func previewData() -> MockFBPostsManager {
        let posts = [
            PreviewData.samplePost1,
            PreviewData.samplePost2,
            PreviewData.samplePost3,
            PreviewData.samplePost4
        ]
        return mockPosts(posts.map(FBPostModel.init(post:)))
    }
}

extension FBPostModel {
    /// Модель Firestore из локального `Post` — для мок-данных.
    ///
    /// У `FBPostModel` дата публикации обязательна, поэтому при её отсутствии
    /// подставляется `post.date`.
    init(post: Post) {
        self.init(
            postId: post.id,
            category: post.category,
            title: post.title,
            intro: post.intro,
            author: post.author,
            postType: post.postType,
            urlString: post.urlString,
            postPlatform: post.postPlatform,
            postDate: post.postDate ?? post.date,
            studyLevel: post.studyLevel,
            date: post.date
        )
    }
}

// MARK: - FBPostModel Test Helpers
extension FBPostModel {
    static func mock(
        postId: String = UUID().uuidString,
        category: String = Constants.mainCategory,
        title: String = "Test Post",
        intro: String = "Test Intro",
        author: String = "Test Author",
        postType: PostType = .post,
        urlString: String = "https://example.com",
        postPlatform: Platform = .youtube,
        postDate: Date = Date(),
        studyLevel: StudyLevel = .beginner,
        date: Date = Date()
    ) -> FBPostModel {
        FBPostModel(
            postId: postId,
            category: category,
            title: title,
            intro: intro,
            author: author,
            postType: postType,
            urlString: urlString,
            postPlatform: postPlatform,
            postDate: postDate,
            studyLevel: studyLevel,
            date: date
        )
    }
    
    static let mockBeginner = FBPostModel.mock(title: "Beginner Post", studyLevel: .beginner)
    static let mockMiddle = FBPostModel.mock(title: "Middle Post", studyLevel: .middle)
    static let mockAdvanced = FBPostModel.mock(title: "Advanced Post", studyLevel: .advanced)
}
//#endif
