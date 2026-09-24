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
            dataSource: dataSource,
            fbPostsManager: networkService,
            services: .make()
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
            appStateManager: MockAppSyncStateManager(),
            fbPostsManager: mockFB,
            services: .make()
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
            appStateManager: MockAppSyncStateManager(),
            fbPostsManager: mockFB,
            services: .make()
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
            appStateManager: MockAppSyncStateManager(),
            fbPostsManager: mockFB,
            services: .make()
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
            appStateManager: MockAppSyncStateManager(),
            fbPostsManager: mockFB,
            services: .make()
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
    
    func testCheckFBPostsForUpdates_WhenNoAppStateManager_ReturnsFailed() async throws {
        // Given — MockPostsDataSource → appStateManager = nil
        let mockFB = MockFBPostsManager.mockPosts([FBPostModel.mockBeginner])
        let testVM = PostsViewModel(
            dataSource: MockPostsDataSource(posts: []),
            fbPostsManager: mockFB,
            services: .make()
        )
        
        // When
        let result = await testVM.checkFBPostsForUpdates()
        
        // Then — проверить нечем
        XCTAssertEqual(result, .failed)
    }
    
    func testCheckFBPostsForUpdates_WhenDateNotSet_ReturnsAvailable() async throws {
        // Given — реальный SwiftData контекст для appStateManager
        let container = try ModelContainer(
            for: Post.self, Notice.self, AppSyncState.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext

        let mockFB = MockFBPostsManager.mockPosts([FBPostModel.mockBeginner])
        let testVM = PostsViewModel(
            modelContext: context,
            appStateManager: AppSyncStateManager(modelContext: context),
            fbPostsManager: mockFB,
            services: .make()
        )
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // When — lastLoadedDate = nil → считаем, что обновления есть
        let result = await testVM.checkFBPostsForUpdates()
        
        // Then
        XCTAssertEqual(result, .available)
    }

    /// VM с датой последней загрузки постов — проверка реально идёт в мок Firestore.
    ///
    /// `services` — опционально с `nil`, а не `= .make()`: выражение значения
    /// по умолчанию вычисляется в неизолированном контексте, а `make()`
    /// изолирован на MainActor. Вызов перенесён в тело метода.
    private func makeCheckVM(fbManager: MockFBPostsManager, services: AppServiceDependencies? = nil) -> PostsViewModel {
        let stateManager = MockAppSyncStateManager()
        stateManager.stubbedLastDateOfPostsLoaded = Date(timeIntervalSince1970: 1_000)
        return PostsViewModel(
            dataSource: MockPostsDataSource(posts: []),
            appStateManager: stateManager,
            fbPostsManager: fbManager,
            services: services ?? .make()
        )
    }

    func testCheckFBPostsForUpdates_WhenNewerPosts_ReturnsAvailable() async {
        // Given — пост новее даты последней загрузки
        let newer = FBPostModel.mock(date: Date(timeIntervalSince1970: 2_000))
        let testVM = makeCheckVM(fbManager: MockFBPostsManager.mockPosts([newer]))

        // When
        let result = await testVM.checkFBPostsForUpdates()

        // Then
        XCTAssertEqual(result, .available)
        XCTAssertTrue(testVM.hasPostsUpdate)
    }

    func testCheckFBPostsForUpdates_WhenNoNewerPosts_ReturnsUpToDate() async {
        // Given — пост старше даты последней загрузки
        let older = FBPostModel.mock(date: Date(timeIntervalSince1970: 500))
        let testVM = makeCheckVM(fbManager: MockFBPostsManager.mockPosts([older]))

        // When
        let result = await testVM.checkFBPostsForUpdates()

        // Then
        XCTAssertEqual(result, .upToDate)
        XCTAssertFalse(testVM.hasPostsUpdate)
    }

    func testCheckFBPostsForUpdates_WhenNetworkFails_ReturnsFailed() async {
        // Given
        let testVM = makeCheckVM(fbManager: MockFBPostsManager.mockNetworkError())

        // When
        let result = await testVM.checkFBPostsForUpdates()

        // Then
        XCTAssertEqual(result, .failed)
    }

    func testCheckFBPostsForUpdates_DoesNotDismissAlreadyShownError() async {
        // Given — на экране уже висит чужая ошибка (например, от импорта notices)
        let services = AppServiceDependencies.make()
        services.errorManager.handle(message: "Notices import failed")
        let testVM = makeCheckVM(fbManager: MockFBPostsManager.mockPosts([]), services: services)

        // When — успешная проверка без обновлений
        let result = await testVM.checkFBPostsForUpdates()

        // Then — чужой алерт не закрыт, а проверка не выглядит неудачной
        XCTAssertEqual(result, .upToDate)
        XCTAssertTrue(services.errorManager.showAlert)
        XCTAssertEqual(services.errorManager.errorMessage, "Notices import failed")
    }

    // MARK: - Save Result Tests
    // addPost/updatePost сообщают, прошло ли сохранение, — по этому
    // результату AddEditPostView показывает успех или ошибку.

    func testAddPost_WhenSaveSucceeds_ReturnsTrue() {
        // Given
        let post = Post(title: "New post")

        // When
        let isSaved = vm.addPost(post)

        // Then
        XCTAssertTrue(isSaved)
    }

    func testAddPost_WhenSaveFails_ReturnsFalse() {
        // Given
        dataSource.shouldThrowOnSave = true
        let post = Post(title: "New post")

        // When
        let isSaved = vm.addPost(post)

        // Then
        XCTAssertFalse(isSaved)
    }

    func testUpdatePost_WhenSaveSucceeds_ReturnsTrue() {
        // When
        let isSaved = vm.updatePost()

        // Then
        XCTAssertTrue(isSaved)
    }

    func testUpdatePost_WhenSaveFails_ReturnsFalse() {
        // Given
        dataSource.shouldThrowOnSave = true

        // When
        let isSaved = vm.updatePost()

        // Then
        XCTAssertFalse(isSaved)
    }

    // MARK: - Erase All Posts

    /// Стирание очищает сам источник данных, а не только список в VM:
    /// после перезагрузки посты не должны вернуться. Раньше для не-SwiftData
    /// источника обнулялся только allPosts.
    func testEraseAllPosts_ClearsDataSource() {
        // Given
        let stateManager = MockAppSyncStateManager()
        let testVM = PostsViewModel(
            dataSource: MockPostsDataSource(posts: [Post(title: "Post 1"), Post(title: "Post 2")]),
            appStateManager: stateManager,
            fbPostsManager: networkService,
            services: .make()
        )
        testVM.loadPostsFromSwiftData(removeDuplicates: false)
        XCTAssertEqual(testVM.allPosts.count, 2)

        // When
        let isErased = testVM.eraseAllPosts()
        testVM.loadPostsFromSwiftData(removeDuplicates: false)

        // Then
        XCTAssertTrue(isErased)
        XCTAssertTrue(testVM.allPosts.isEmpty)
        XCTAssertEqual(stateManager.resetLastDateOfPostsLoadedCallCount, 1)
    }

    // MARK: - Update Status Staleness & Sync Date

    func testRefreshPostsUpdateStatus_AppliesFreshResult() async {
        // Given — пост новее даты последней загрузки, дата во время запроса не меняется
        let stateManager = MockAppSyncStateManager()
        stateManager.stubbedLastDateOfPostsLoaded = Date(timeIntervalSince1970: 1_000)
        let newer = FBPostModel.mock(date: Date(timeIntervalSince1970: 2_000))
        let testVM = PostsViewModel(
            dataSource: MockPostsDataSource(posts: []),
            appStateManager: stateManager,
            fbPostsManager: MockFBPostsManager.mockPosts([newer]),
            services: .make()
        )

        // When
        await testVM.refreshPostsUpdateStatus()

        // Then
        XCTAssertTrue(testVM.hasPostsUpdate)
    }

    func testRefreshPostsUpdateStatus_WhenDateChangesDuringRequest_IgnoresStaleResult() async throws {
        // Given — запрос с задержкой, в Firestore есть пост новее старой даты
        let stateManager = MockAppSyncStateManager()
        stateManager.stubbedLastDateOfPostsLoaded = Date(timeIntervalSince1970: 1_000)
        let mockFB = MockFBPostsManager.mockPosts([FBPostModel.mock(date: Date(timeIntervalSince1970: 2_000))])
        mockFB.shouldSimulateDelay = true
        let testVM = PostsViewModel(
            dataSource: MockPostsDataSource(posts: []),
            appStateManager: stateManager,
            fbPostsManager: mockFB,
            services: .make()
        )

        // When — пока запрос идёт, дата сдвигается (как после импорта)
        let task = Task { await testVM.refreshPostsUpdateStatus() }
        try await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertTrue(testVM.isCheckingPostsForUpdates) // по нему PreferencesView гасит кнопки
        stateManager.stubbedLastDateOfPostsLoaded = Date(timeIntervalSince1970: 3_000)
        await task.value

        // Then — устаревший ответ "есть обновления" не применён
        XCTAssertFalse(testVM.hasPostsUpdate)
        XCTAssertFalse(testVM.isCheckingPostsForUpdates)
    }

    func testImport_AdvancesSyncDatePastAllReceivedPosts() async {
        // Given — в ответе новый пост и уже существующий локально, более поздний
        let stateManager = MockAppSyncStateManager()
        stateManager.stubbedLastDateOfPostsLoaded = Date(timeIntervalSince1970: 1_000)
        let newPost = FBPostModel.mock(title: "New", date: Date(timeIntervalSince1970: 1_500))
        let knownPost = FBPostModel.mock(title: "Known", date: Date(timeIntervalSince1970: 2_500))
        let testVM = PostsViewModel(
            dataSource: MockPostsDataSource(posts: [Post(title: "Known")]),
            appStateManager: stateManager,
            fbPostsManager: MockFBPostsManager.mockPosts([newPost, knownPost]),
            services: .make()
        )
        testVM.loadPostsFromSwiftData()

        // When
        let success = await testVM.importPostsFromFirebase()

        // Then — дата сдвинута за самый поздний пост ответа (+1 мс), а не за самый поздний новый
        XCTAssertTrue(success)
        XCTAssertEqual(
            stateManager.savedLastDateOfPostsLoaded?.timeIntervalSince1970 ?? 0,
            2_500.001,
            accuracy: 0.000_1
        )
    }

    func testImport_PostInSameSecondAfterImportedOne_IsStillNew() async throws {
        // Given — импортирован пост с датой 1500.3
        let stateManager = MockAppSyncStateManager()
        stateManager.stubbedLastDateOfPostsLoaded = Date(timeIntervalSince1970: 1_000)
        let imported = FBPostModel.mock(title: "Imported", date: Date(timeIntervalSince1970: 1_500.3))
        let importVM = PostsViewModel(
            dataSource: MockPostsDataSource(posts: []),
            appStateManager: stateManager,
            fbPostsManager: MockFBPostsManager.mockPosts([imported]),
            services: .make()
        )
        _ = await importVM.importPostsFromFirebase()
        let cursor = try XCTUnwrap(stateManager.savedLastDateOfPostsLoaded)

        // When — позже в облаке появился пост в ту же секунду (1500.8)
        stateManager.stubbedLastDateOfPostsLoaded = cursor
        let sameSecond = FBPostModel.mock(title: "Same second", date: Date(timeIntervalSince1970: 1_500.8))
        let checkVM = PostsViewModel(
            dataSource: MockPostsDataSource(posts: []),
            appStateManager: stateManager,
            fbPostsManager: MockFBPostsManager.mockPosts([imported, sameSecond]),
            services: .make()
        )
        let result = await checkVM.checkFBPostsForUpdates()

        // Then — он новый (со схемой "обрезка до секунд + 1 с" был бы пропущен навсегда)
        XCTAssertEqual(result, .available)
    }
}
