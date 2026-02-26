//
//  PostsViewModelTests.swift
//  StartToSwiftUIUnitTests
//
//  Created by Andrey Efimov on 21.01.2026.
//

import XCTest
import SwiftData
import Combine
@testable import StartToSwiftUI

@MainActor
final class PostsViewModelTests: XCTestCase {
    
    var dataSource: MockPostsDataSource!
    var networkService: MockFBPostsManager!
    var vm: PostsViewModel!
    
    override func setUp() async throws {
        // Сбросить UserDefaults перед каждым тестом
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        
        // Используем Mock DataSource вместо реального SwiftData
        dataSource = MockPostsDataSource(posts: [])
        
        // Используем Mock NetworkService
        networkService = MockFBPostsManager.mockPosts([])
        
        // Инициализируем ViewModel с моками
        vm = PostsViewModel(
            dataSource: dataSource
        )
        
        // Небольшая задержка для async операций
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 секунда
    }
    
    override func tearDown() {
        dataSource = nil
        networkService = nil
        vm = nil
    }
    
    // MARK: - Network Tests
    
    func testImportPostsFromFirebaseSuccess() async throws {
        // Given
        let mockPosts = [
            FBPostModel.mock(postId: "1", title: "Firebase Post 1"),
            FBPostModel.mock(postId: "2", title: "Firebase Post 2")
        ]
        let mockFB = MockFBPostsManager.mockPosts(mockPosts)
        let testVM = PostsViewModel(
            dataSource: MockPostsDataSource(posts: []),
            fbPostsManager: mockFB
        )
        
        // When
        let success = await testVM.importPostsFromFirebase()
        
        // Then
        XCTAssertTrue(success)
        XCTAssertEqual(testVM.allPosts.count, 2)
        XCTAssertEqual(mockFB.fetchCallCount, 1)
    }
    
    func testImportPostsFromFirebaseSkipsDuplicates() async throws {
        // Given
        let existingPost = Post(id: "1", title: "Existing", intro: "Content")
        let dataSource = MockPostsDataSource(posts: [existingPost])

        let mockPosts = [
            FBPostModel.mock(postId: "1", title: "Existing"), // дубликат по id
            FBPostModel.mock(postId: "2", title: "New Post")
        ]
        let mockFB = MockFBPostsManager.mockPosts(mockPosts)
        let testVM = PostsViewModel(
            dataSource: dataSource,
            fbPostsManager: mockFB
        )
        
        // Загружаем существующие посты в allPosts
        testVM.loadPostsFromSwiftData()
        XCTAssertEqual(testVM.allPosts.count, 1) // убеждаемся что existing загрузился

        // When
        let success = await testVM.importPostsFromFirebase()

        // Then
        XCTAssertTrue(success)
        XCTAssertEqual(testVM.allPosts.count, 2) // existing + 1 new
    }
    
    func testImportPostsFromFirebaseEmptyResponse() async throws {
        // Given
        let mockFB = MockFBPostsManager.mockEmpty()
        let testVM = PostsViewModel(
            dataSource: MockPostsDataSource(posts: []),
            fbPostsManager: mockFB
        )
        
        // When
        let success = await testVM.importPostsFromFirebase()
        
        // Then
        XCTAssertTrue(success)
        XCTAssertEqual(testVM.allPosts.count, 0)
    }
    
    func testImportPostsWithDifferentLevels() async throws {
        // Given
        let mockPosts = [
            FBPostModel.mockBeginner,
            FBPostModel.mockMiddle,
            FBPostModel.mockAdvanced
        ]
        let mockFB = MockFBPostsManager.mockPosts(mockPosts)
        let testVM = PostsViewModel(
            dataSource: MockPostsDataSource(posts: []),
            fbPostsManager: mockFB
        )
        
        // When
        let success = await testVM.importPostsFromFirebase()
        
        // Then
        XCTAssertTrue(success)
        XCTAssertEqual(testVM.allPosts.count, 3)
        XCTAssertTrue(testVM.allPosts.contains { $0.studyLevel == .beginner })
        XCTAssertTrue(testVM.allPosts.contains { $0.studyLevel == .middle })
        XCTAssertTrue(testVM.allPosts.contains { $0.studyLevel == .advanced })
    }
    
    func testCheckFBPostsForUpdates_WhenNoAppStateManager_ReturnsFalse() async throws {
        // Given — MockPostsDataSource → appStateManager = nil
        let mockFB = MockFBPostsManager.mockPosts([FBPostModel.mockBeginner])
        let testVM = PostsViewModel(
            dataSource: MockPostsDataSource(posts: []),
            fbPostsManager: mockFB
        )
        
        // When
        let hasUpdates = await testVM.checkFBPostsForUpdates()
        
        // Then
        XCTAssertFalse(hasUpdates)
    }
    
    func testCheckFBPostsForUpdates_WhenNewPosts_ReturnsTrue() async throws {
        // Given — реальный SwiftData контекст для appStateManager
        let container = try ModelContainer(
            for: Post.self, Notice.self, AppSyncState.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext
        
        let mockFB = MockFBPostsManager.mockPosts([FBPostModel.mockBeginner])
        let testVM = PostsViewModel(
            modelContext: context,
            fbPostsManager: mockFB
        )
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // When — lastLoadedDate = nil → returns true
        let hasUpdates = await testVM.checkFBPostsForUpdates()
        
        // Then
        XCTAssertTrue(hasUpdates)
    }
}
