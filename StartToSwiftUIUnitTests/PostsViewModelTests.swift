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
    var networkService: MockNetworkService!
    var vm: PostsViewModel!
    
    override func setUp() async throws {
        // Сбросить UserDefaults перед каждым тестом
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        
        // Используем Mock DataSource вместо реального SwiftData
        dataSource = MockPostsDataSource(posts: [])
        
        // Используем Mock NetworkService
        networkService = MockNetworkService.mockPosts([])
        
        // Инициализируем ViewModel с моками
        vm = PostsViewModel(
            dataSource: dataSource,
            networkService: networkService
        )
        
        // Небольшая задержка для async операций
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 секунда
    }

    override func tearDown() {
        dataSource = nil
        networkService = nil
        vm = nil
    }
    
    func testInitialization() {
        
        // Then
        XCTAssertTrue(vm.allPosts.isEmpty)
        XCTAssertTrue(vm.filteredPosts.isEmpty)
        XCTAssertNil(vm.selectedPostId)
        XCTAssertTrue(vm.searchText.isEmpty)
        
        XCTAssertEqual(vm.selectedLevel, .beginner)  // Дефолт
        XCTAssertEqual(vm.selectedType, .course)     // Дефолт

        // Проверяем ВСЕ свойства, влияющие на фильтры
        XCTAssertNil(vm.selectedRating)
        XCTAssertNil(vm.selectedFavorite)
        XCTAssertNil(vm.selectedPlatform)
        XCTAssertNil(vm.selectedYear)
        XCTAssertNil(vm.selectedSortOption)
        
        XCTAssertEqual(vm.selectedStudyProgress, .added)
        
        // isFiltersEmpty должно быть true
        XCTAssertFalse(vm.isFiltersEmpty)
    }
    
    func testAddPost() {
        // Given
        let initialCount = vm.allPosts.count
        let newPost = Post(title: "Test Post", intro: "Test Content")
        
        // When
        vm.addPost(newPost)
        
        // Then
        XCTAssertEqual(vm.allPosts.count, initialCount + 1)
        XCTAssertTrue(vm.allPosts.contains(where: { $0.id == newPost.id }))
    }
    
    func testAddPostIfNotExistsWithDuplicateID() {
        // Given
        let post = Post(title: "Original", intro: "Content")
        vm.addPost(post)
        
        let duplicatePost = Post(
            id: post.id,
            title: "Duplicate",
            intro: "Different Content"
        )
        
        // When
        let result = vm.addPostIfNotExists(duplicatePost)
        
        // Then
        XCTAssertFalse(result)
        XCTAssertEqual(vm.allPosts.count, 1) // Should not add duplicate
    }
    
    func testAddPostIfNotExistsWithDuplicateTitle() {
        // Given
        let post = Post(title: "Unique Title", intro: "Content")
        vm.addPost(post)
        
        let duplicateTitlePost = Post(
            id: UUID().uuidString,
            title: "Unique Title", // Same title
            intro: "Different Content"
        )
        
        // When
        let result = vm.addPostIfNotExists(duplicateTitlePost)
        
        // Then
        XCTAssertFalse(result)
        XCTAssertEqual(vm.allPosts.count, 1) // Should not add duplicate
    }
    
    func testAddPostIfNotExistsWithUniquePost() {
        // Given
        let initialCount = vm.allPosts.count
        let uniquePost = Post(
            id: UUID().uuidString,
            title: "Unique Title",
            intro: "Unique Content"
        )
        
        // When
        let result = vm.addPostIfNotExists(uniquePost)
        
        // Then
        XCTAssertTrue(result)
        XCTAssertEqual(vm.allPosts.count, initialCount + 1)
    }
    
    func testDeletePost() {
        // Given
        let post = Post(title: "To Delete", intro: "Content")
        vm.addPost(post)
        let initialCount = vm.allPosts.count
        
        // When
        vm.erasePost(post)
        
        // Then
        XCTAssertEqual(vm.allPosts.count, initialCount - 1)
        XCTAssertFalse(vm.allPosts.contains(where: { $0.id == post.id }))
    }
    
    func testDeleteNilPost() {
        // Given
        let initialCount = vm.allPosts.count
        
        // When
        vm.erasePost(nil)
        
        // Then - Should not crash and count should remain unchanged
        XCTAssertEqual(vm.allPosts.count, initialCount)
    }
    
    func testFavoriteToggle() {
        // Given
        let post = Post()
        vm.addPost(post)
        let initialFavoriteStatus = post.favoriteChoice
        
        // When
        vm.favoriteToggle(post)
        
        // Then
        XCTAssertNotEqual(post.favoriteChoice, initialFavoriteStatus)
        XCTAssertEqual(post.favoriteChoice, .yes)
        
        // When - toggle back
        vm.favoriteToggle(post)
        
        // Then
        XCTAssertEqual(post.favoriteChoice, .no)
    }
    
    func testRatePost() {
        // Given
        let post = Post()
        vm.addPost(post)
        vm.selectedRating = .good
        
        // When
        vm.ratePost(post)
        
        // Then
        XCTAssertEqual(post.postRating, .good)
    }
    
    func testUpdatePostStudyProgress() {
        // Given
        let post = Post()
        vm.addPost(post)
        vm.selectedStudyProgress = .studied
        
        // When
        vm.updatePostStudyProgress(post)
        
        // Then
        XCTAssertEqual(post.progress, .studied)
        XCTAssertNotNil(post.studiedDateStamp)
        XCTAssertNil(post.practicedDateStamp)
    }
    
    func testUpdatePostStudyProgressToStarted() {
        // Given
        let post = Post()
        vm.addPost(post)
        vm.selectedStudyProgress = .started
        
        // When
        vm.updatePostStudyProgress(post)
        
        // Then
        XCTAssertEqual(post.progress, .started)
        XCTAssertNotNil(post.startedDateStamp)
        XCTAssertNil(post.studiedDateStamp)
        XCTAssertNil(post.practicedDateStamp)
    }
    
    func testUpdatePostStudyProgressToFresh() {
        // Given
        let post = Post()
        post.progress = .practiced
        post.startedDateStamp = Date()
        post.studiedDateStamp = Date()
        post.practicedDateStamp = Date()
        vm.addPost(post)
        vm.selectedStudyProgress = .added
        
        // When
        vm.updatePostStudyProgress(post)
        
        // Then
        XCTAssertEqual(post.progress, .added)
        XCTAssertNil(post.startedDateStamp)
        XCTAssertNil(post.studiedDateStamp)
        XCTAssertNil(post.practicedDateStamp)
    }
    
    func testCheckNewPostForUniqueTitle() {
        // Given
        let existingPost = Post(title: "Existing Title", intro: "Content")
        print("Before addPost - allPosts count: \(vm.allPosts.count)")
        vm.addPost(existingPost)
        print("After addPost - allPosts count: \(vm.allPosts.count)")
        print("Added post title: \(existingPost.title), id: \(existingPost.id)")
        
        // When & Then - Same title, different ID
        let isUnique = vm.checkNewPostForUniqueTitle(
            "Existing Title",
            editingPostId: UUID().uuidString
        )
        XCTAssertTrue(isUnique)
        
        // When & Then - Same title, same ID (editing)
        let isUniqueWhenEditing = vm.checkNewPostForUniqueTitle(
            "Existing Title",
            editingPostId: existingPost.id
        )
        XCTAssertFalse(isUniqueWhenEditing)
        
        // When & Then - Different title
        let isUniqueNew = vm.checkNewPostForUniqueTitle(
            "New Title",
            editingPostId: nil
        )
        XCTAssertFalse(isUniqueNew)
    }
    
    func testSearchPosts() async throws {
        // Given - посты должны соответствовать дефолтным фильтрам!
        let post1 = Post(title: "SwiftUI Basics", intro: "Learn SwiftUI",
                         postType: .course, studyLevel: .beginner)
        let post2 = Post(title: "Combine Framework", intro: "Reactive programming",
                         postType: .course, studyLevel: .beginner)
        let post3 = Post(title: "Core Data", intro: "Data persistence",
                         postType: .course, studyLevel: .beginner)
        
        [post1, post2, post3].forEach { vm.addPost($0) }
        
        // When
        vm.searchText = Constants.mainCategory
        
        // Ждем debounce
        try await Task.sleep(nanoseconds: 600_000_000)
        
        // Then
        XCTAssertEqual(vm.filteredPosts.count, 1)
        XCTAssertEqual(vm.filteredPosts.first?.title, "SwiftUI Basics")
    }
    
    func testFilterPosts() async throws {
        
        // Given - все посты с postType = .course
        let post1 = Post(title: "Post 1", postType: .course, studyLevel: .beginner, progress: .started)
        let post2 = Post(title: "Post 2", postType: .course, studyLevel: .middle, progress: .studied)
        let post3 = Post(title: "Post 3", postType: .course, studyLevel: .advanced, progress: .practiced)
        
        [post1, post2, post3].forEach { vm.addPost($0) }
        
        // DEBUG: проверяем, что посты добавились
        print("allPosts count: \(vm.allPosts.count)")
        XCTAssertEqual(vm.allPosts.count, 3, "Posts should be added to allPosts")
        
        // Сбрасываем фильтры
        vm.selectedLevel = nil
        vm.selectedType = nil
        
        // Ждём обновления filteredPosts через expectation
        let initialExpectation = XCTestExpectation(description: "Initial filter update")
        var cancellable: AnyCancellable?
        
        cancellable = vm.$filteredPosts
            .dropFirst()
            .sink { filtered in
                print("filteredPosts updated: \(filtered.count)")
                if filtered.count == 3 {
                    initialExpectation.fulfill()
                }
            }
        
        await fulfillment(of: [initialExpectation], timeout: 2.0)
        
        // Проверяем, что видим все 3 поста
        print("filteredPosts count after reset: \(vm.filteredPosts.count)")
        XCTAssertEqual(vm.filteredPosts.count, 3)
        
        cancellable?.cancel()
        
        // Теперь тестируем фильтрацию
        let filterExpectation = XCTestExpectation(description: "Filter by level")
        
        cancellable = vm.$filteredPosts
            .dropFirst()
            .sink { filtered in
                print("filteredPosts after filter: \(filtered.count)")
                filterExpectation.fulfill()
            }

        // When - фильтруем по middle
        vm.selectedLevel = .middle
        
        await fulfillment(of: [filterExpectation], timeout: 2.0)

        // Then
        XCTAssertEqual(vm.filteredPosts.count, 1)
        XCTAssertTrue(vm.filteredPosts.allSatisfy { $0.studyLevel == .middle })
        
        cancellable?.cancel()
    }
    func testGetPost() {
        // Given
        let post = Post(title: "Test Post", intro: "Content")
        vm.addPost(post)
        
        // When
        let foundPost = vm.getPost(id: post.id)
        
        // Then
        XCTAssertNotNil(foundPost)
        XCTAssertEqual(foundPost?.id, post.id)
        XCTAssertEqual(foundPost?.title, "Test Post")
    }
    
    func testGetPostNotFound() {
        // Given
        let nonExistentId = UUID().uuidString
        
        // When
        let foundPost = vm.getPost(id: nonExistentId)
        
        // Then
        XCTAssertNil(foundPost)
    }
    
    func testCheckIfAllFiltersAreEmpty() {        
        // When
        vm.selectedLevel = .beginner
        vm.selectedType = .course
        
        // Then
        XCTAssertFalse(vm.checkIfAllFiltersAreEmpty())
        
        // When - Clear filter
        vm.selectedLevel = nil
        vm.selectedType = nil
        
        // Then
        XCTAssertTrue(vm.checkIfAllFiltersAreEmpty())
    }
    
    // MARK: - Network Tests
    
    func testImportPostsFromCloudSuccess() async throws {
        // Given
        let mockPosts = [
            CodablePost.mock(id: "1", title: "Cloud Post 1"),
            CodablePost.mock(id: "2", title: "Cloud Post 2")
        ]
        
        let mockNetwork = MockNetworkService.mockPosts(mockPosts)
        let testVM = PostsViewModel(
            dataSource: MockPostsDataSource(posts: []),
            networkService: mockNetwork
        )
        
        // When
//        let success = await testVM.importPostsFromCloud()
        let success = await testVM.importPostsFromFirebase()

        // Then
        XCTAssertTrue(success)
        XCTAssertEqual(testVM.allPosts.count, 2)
        XCTAssertEqual(mockNetwork.fetchCallCount, 1)
    }
    
    func testImportPostsFromCloudNetworkError() async throws {
        // Given
        let mockNetwork = MockNetworkService.mockError()
        let testVM = PostsViewModel(
            dataSource: MockPostsDataSource(posts: []),
            networkService: mockNetwork
        )
        
        // When
//        let success = await testVM.importPostsFromCloud()
        let success = await testVM.importPostsFromFirebase()

        // Then
        XCTAssertTrue(success)
        XCTAssertNotNil(testVM.errorMessage)
        XCTAssertTrue(testVM.showErrorMessageAlert)
        XCTAssertEqual(testVM.allPosts.count, 0)
    }
    
    func testImportPostsSkipsDuplicates() async throws {
        // Given
        let existingPost = Post(id: "1", title: "Existing", intro: "Content")
        let dataSource = MockPostsDataSource(posts: [existingPost])
        
        let mockPosts = [
            CodablePost.mock(id: "1", title: "Existing"),
            CodablePost.mock(id: "2", title: "New Post")
        ]
        
        let mockNetwork = MockNetworkService.mockPosts(mockPosts)
        let testVM = PostsViewModel(
            dataSource: dataSource,
            networkService: mockNetwork
        )
        
        // When
        // When
        //        let success = await testVM.importPostsFromCloud()
        let success = await testVM.importPostsFromFirebase()

        // Then
        XCTAssertTrue(success)
        XCTAssertEqual(testVM.allPosts.count, 2) // Only new post added
    }

    func testImportPostsWithDifferentLevels() async throws {
        // Given
        let mockPosts = [
            CodablePost.mockBeginner,
            CodablePost.mockMiddle,
            CodablePost.mockAdvanced
        ]
        
        let mockNetwork = MockNetworkService.mockPosts(mockPosts)
        let testVM = PostsViewModel(
            dataSource: MockPostsDataSource(posts: []),
            networkService: mockNetwork
        )
        
        // When
        // When
        //        let success = await testVM.importPostsFromCloud()
        let success = await testVM.importPostsFromFirebase()

        // Then
        XCTAssertTrue(success)
        XCTAssertEqual(testVM.allPosts.count, 3)
        XCTAssertTrue(testVM.allPosts.contains { $0.studyLevel == .beginner })
        XCTAssertTrue(testVM.allPosts.contains { $0.studyLevel == .middle })
        XCTAssertTrue(testVM.allPosts.contains { $0.studyLevel == .advanced })
    }

    func testImportFavoritePosts() async throws {
        // Given
        let mockPosts = [
            CodablePost.mockFavorite,
            CodablePost.mock(id: "2", title: "Regular Post", favoriteChoice: .no)
        ]
        
        let mockNetwork = MockNetworkService.mockPosts(mockPosts)
        let testVM = PostsViewModel(
            dataSource: MockPostsDataSource(posts: []),
            networkService: mockNetwork
        )
        
        // When
        //        let success = await testVM.importPostsFromCloud()
        let success = await testVM.importPostsFromFirebase()

        // Then
        XCTAssertTrue(success)
        let favoriteCount = testVM.allPosts.filter { $0.favoriteChoice == .yes }.count
        XCTAssertEqual(favoriteCount, 1)
    }

    func testImportDraftPosts() async throws {
        // Given
        let mockPosts = [
            CodablePost.mockDraft,
            CodablePost.mock(id: "2", title: "Published Post", draft: false)
        ]
        
        let mockNetwork = MockNetworkService.mockPosts(mockPosts)
        let testVM = PostsViewModel(
            dataSource: MockPostsDataSource(posts: []),
            networkService: mockNetwork
        )
        
        // When
        //        let success = await testVM.importPostsFromCloud()
        let success = await testVM.importPostsFromFirebase()

        // Then
        XCTAssertTrue(success)
        let draftCount = testVM.allPosts.filter { $0.draft }.count
        XCTAssertEqual(draftCount, 1)
    }

    func testExportPostsToJSON() throws {
        // Given
        let post1 = Post(title: "Post 1", intro: "Content 1")
        let post2 = Post(title: "Post 2", intro: "Content 2")
        [post1, post2].forEach { vm.addPost($0) }
        
        // When
        let result = vm.exportPostsToJSON()
        
        // Then
        switch result {
        case .success(let url):
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
            XCTAssertTrue(url.lastPathComponent.contains("StartToSwiftUI_backup"))
            
            // Проверяем содержимое файла
            let data = try Data(contentsOf: url)
            let exportedPosts = try JSONDecoder.appDecoder.decode([CodablePost].self, from: data)
            XCTAssertEqual(exportedPosts.count, 2)
            
        case .failure(let error):
            XCTFail("Export should succeed: \(error)")
        }
    }
}
