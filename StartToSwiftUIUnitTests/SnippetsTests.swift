//
//  SnippetsTests.swift
//  StartToSwiftUITests
//
//  Created by Andrey Efimov on 12.03.2026.
//

import XCTest
import SwiftData
import Combine
import CoreData
@testable import StartToSwiftUI

/*
 Test groups:
  Repository — the data is correct, the ID is unique, and A001/A002 exists
  ViewModel initial state — filteredSnippets is the same as allSnippets, no selection
  Search — match, no match, empty restores all
  Favorites store (AppSyncStateManager) — toggle, idempotency, ID independence
  ViewModel favorites (mock store) — cache load, toggle, no store, refresh, iCloud change
  ViewModel + real store integration

 Category/platform filtering and sorting are intentionally not covered here —
 SnippetsViewModel no longer has selectedCategory/selectedSortOption/
 isFiltersEmpty/resetAllFilters (simplified to search + favorites only).
*/

@MainActor
final class SnippetsTests: XCTestCase {

    var vm: SnippetsViewModel!
    var cancellables = Set<AnyCancellable>()

    override func setUp() async throws {
        // Reset UserDefaults before each test
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        vm = SnippetsViewModel(services: .make())
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1s for Combine pipeline
    }

    override func tearDown() {
        vm = nil
        cancellables.removeAll()
    }

    // MARK: - SnippetsRepository

    func test_repository_notEmpty() {
        XCTAssertFalse(SnippetsRepository.allDemoCodeSnippet.isEmpty)
    }

    func test_repository_ids_areUnique() {
        let ids = SnippetsRepository.allDemoCodeSnippet.map { $0.id }
        XCTAssertEqual(ids.count, Set(ids).count, "Duplicate snippet IDs found")
    }

    func test_repository_allSnippets_haveNonEmptyTitles() {
        XCTAssertTrue(SnippetsRepository.allDemoCodeSnippet.allSatisfy { !$0.title.isEmpty })
    }

    func test_repository_a001_exists() {
        XCTAssertNotNil(SnippetsRepository.allDemoCodeSnippet.first { $0.id == "A001" })
    }

    func test_repository_a002_exists() {
        XCTAssertNotNil(SnippetsRepository.allDemoCodeSnippet.first { $0.id == "A002" })
    }

    // MARK: - SnippetsViewModel — Initial State

    func test_viewModel_initialState_filteredSnippetsMatchAll() async throws {
        try await Task.sleep(nanoseconds: 400_000_000)
        XCTAssertEqual(vm.filteredSnippets.count, vm.allSnippets.count)
    }
    
    func test_viewModel_initialState_noSelectedSnippet() {
        XCTAssertNil(vm.selectedSnippet)
    }

    // MARK: - SnippetsViewModel — Search

    func test_search_byTitle_returnsMatch() async throws {
        let title = SnippetsRepository.a001.title
        let firstWord = title.components(separatedBy: " ").first ?? title
        vm.searchText = firstWord
        try await Task.sleep(nanoseconds: 400_000_000)
        XCTAssertFalse(vm.filteredSnippets.isEmpty)
    }

    func test_search_noMatch_returnsEmpty() async throws {
        vm.searchText = "xyzzy_no_match_12345"
        try await Task.sleep(nanoseconds: 400_000_000)
        XCTAssertTrue(vm.filteredSnippets.isEmpty)
    }

    func test_search_empty_restoresAll() async throws {
        vm.searchText = "xyzzy_no_match"
        try await Task.sleep(nanoseconds: 400_000_000)
        vm.searchText = ""
        try await Task.sleep(nanoseconds: 400_000_000)
        XCTAssertEqual(vm.filteredSnippets.count, vm.allSnippets.count)
    }

    // MARK: - Favorites store (AppSyncStateManager)

    /// Гонка инициализации свежесозданного in-memory ModelContainer (первый
    /// fetch падал с SIGILL внутри самого SwiftData) воспроизводится на
    /// связке Intel Mac + iOS 26.5 Simulator даже с паузой-прогревом —
    /// одна попытка на тест давала 4-5 шансов словить гонку на класс.
    /// Вместо этого контейнер создаётся и прогревается ОДИН раз на весь
    /// test case (`static let` с `Task`, вычисляется лениво и потокобезопасно
    /// при первом обращении, дальше отдаёт закешированный результат) —
    /// гонка теперь возможна только один раз вместо пяти.
    /// Изоляция между тестами обеспечивается вручную — сбросом
    /// snippetFavoriteIDs перед каждым использованием, раз контейнер общий.
    private static let sharedFavouritesContainer: Task<ModelContainer, Error> = Task { @MainActor in
        let container = try ModelContainer(
            for: Post.self, Notice.self, AppSyncState.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        try await Task.sleep(nanoseconds: 100_000_000)
        return container
    }

    /// Настоящий AppSyncStateManager на общем in-memory контейнере
    /// с очищенным избранным.
    private func makeFavoritesStore() async throws -> AppSyncStateManager {
        let container = try await Self.sharedFavouritesContainer.value
        let stateManager = AppSyncStateManager(modelContext: container.mainContext)
        stateManager.getOrCreateAppState().snippetFavoriteIDs = []
        return stateManager
    }

    func test_favorites_toggle_addsFavorite() async throws {
        let store = try await makeFavoritesStore()
        store.toggleSnippetFavorite("A001")
        XCTAssertTrue(store.getSnippetFavoriteIDs().contains("A001"))
    }

    func test_favorites_toggle_removesFavorite() async throws {
        let store = try await makeFavoritesStore()
        store.toggleSnippetFavorite("A001")
        store.toggleSnippetFavorite("A001")
        XCTAssertFalse(store.getSnippetFavoriteIDs().contains("A001"))
    }

    func test_favorites_toggle_idempotentMultipleTimes() async throws {
        let store = try await makeFavoritesStore()
        store.toggleSnippetFavorite("A002")
        store.toggleSnippetFavorite("A002")
        store.toggleSnippetFavorite("A002")
        XCTAssertTrue(store.getSnippetFavoriteIDs().contains("A002"))
    }

    func test_favorites_differentIDs_independant() async throws {
        let store = try await makeFavoritesStore()
        store.toggleSnippetFavorite("A001")
        XCTAssertEqual(store.getSnippetFavoriteIDs(), ["A001"])
    }

    // MARK: - SnippetsViewModel — Favorites (mock store)

    func test_viewModel_init_loadsFavoritesFromStore() {
        let store = MockSnippetFavoritesStore()
        store.favoriteIDs = [SnippetsRepository.a001.id]

        let testVM = SnippetsViewModel(favoritesStore: store, services: .make())

        XCTAssertTrue(testVM.isFavorite(SnippetsRepository.a001))
    }

    func test_viewModel_favoriteToggle_updatesCacheAndStore() {
        let store = MockSnippetFavoritesStore()
        let testVM = SnippetsViewModel(favoritesStore: store, services: .make())
        let snippet = SnippetsRepository.a001

        testVM.favoriteToggle(snippet)

        XCTAssertEqual(store.toggledIDs, [snippet.id])
        XCTAssertTrue(testVM.isFavorite(snippet))
    }

    /// Без хранилища (превью) избранного нет, переключение ничего не делает.
    func test_viewModel_withoutStore_favoritesAreNoOp() {
        let snippet = SnippetsRepository.a001

        vm.favoriteToggle(snippet)

        XCTAssertFalse(vm.isFavorite(snippet))
    }

    /// Изменение в хранилище в обход VM (например, с другого устройства)
    /// попадает в кэш после refreshFavorites().
    func test_viewModel_refreshFavorites_picksUpStoreChanges() {
        let store = MockSnippetFavoritesStore()
        let testVM = SnippetsViewModel(favoritesStore: store, services: .make())
        let snippet = SnippetsRepository.a001

        store.favoriteIDs = [snippet.id]
        XCTAssertFalse(testVM.isFavorite(snippet), "кэш ещё не обновлён")

        testVM.refreshFavorites()

        XCTAssertTrue(testVM.isFavorite(snippet))
    }

    /// Событие об изменении хранилища (в т.ч. из iCloud) обновляет кэш избранного.
    func test_viewModel_storeChange_refreshesFavorites() {
        let store = MockSnippetFavoritesStore()
        let observer = MockCloudChangeObserver()
        let testVM = SnippetsViewModel(favoritesStore: store, cloudChangeObserver: observer, services: .make())
        let snippet = SnippetsRepository.a001
        store.favoriteIDs = [snippet.id]

        observer.sendChange()

        XCTAssertTrue(testVM.isFavorite(snippet))
    }

    // MARK: - SnippetsViewModel — Favorites Integration

    /// vm из setUp() строится без хранилища (nil по умолчанию) —
    /// favoriteToggle/isFavorite там no-op. Для этого теста нужен свой vm
    /// с настоящим AppSyncStateManager.
    func test_viewModel_favoriteToggle_updatesState() async throws {
        let stateManager = try await makeFavoritesStore()
        let testVM = SnippetsViewModel(favoritesStore: stateManager, services: .make())

        let snippet = SnippetsRepository.a001
        let before = testVM.isFavorite(snippet)
        testVM.favoriteToggle(snippet)
        XCTAssertNotEqual(testVM.isFavorite(snippet), before)
    }
}
