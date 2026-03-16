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
    
    func uploadDevDataPostsToFirebase() async {}
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
