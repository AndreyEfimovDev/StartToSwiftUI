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

  Filtering & sorting (pure functions) — iOS version, favourite, search, combined, sort options
  ViewModel filters — default sort, reset, persistence, favourite filter reacts to toggle, random
  Viewed (new snippets) — mock store: isNew, markViewed, no double write, iCloud change; real store: persist, merge duplicates
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

    // MARK: - SnippetsRepository — Series

    /// Серия A — примеры для iOS 18, серия B — только для iOS 26+:
    /// на этом соглашении держится фильтр по версии iOS.
    func test_repository_seriesMatchesMinOS() {
        for snippet in SnippetsRepository.allDemoCodeSnippet {
            if snippet.id.hasPrefix("A") {
                XCTAssertEqual(snippet.minOS, .ios18, snippet.id)
            } else if snippet.id.hasPrefix("B") {
                XCTAssertEqual(snippet.minOS, .ios26, snippet.id)
            } else {
                XCTFail("Unknown series: \(snippet.id)")
            }
        }
    }

    // MARK: - Filtering (pure function)

    /// Тестовый сниппет: дата — `day` дней от 1970, чтобы задавать порядок сортировки.
    private func makeSnippet(
        _ id: String,
        title: String = "Title",
        intro: String = "Intro",
        minOS: CodeSnippet.MinOS = .ios18,
        day: Int = 0
    ) -> CodeSnippet {
        CodeSnippet(
            id: id,
            title: title,
            intro: intro,
            thanks: nil,
            date: Date(timeIntervalSince1970: TimeInterval(day) * 86_400),
            codeSnippet: "",
            minOS: minOS
        )
    }

    private var fixture: [CodeSnippet] {
        [
            makeSnippet("A1", title: "Shimmer Wave", intro: "Loading placeholder", minOS: .ios18, day: 2),
            makeSnippet("A2", title: "Mask", intro: "Reveal with a GRADIENT", minOS: .ios18, day: 1),
            makeSnippet("B1", title: "Glass Composer", intro: "Liquid Glass bars", minOS: .ios26, day: 3),
            makeSnippet("B2", title: "Slider Ticks", intro: "Tick marks", minOS: .ios26, day: 0)
        ]
    }

    private func ids(_ snippets: [CodeSnippet]) -> [String] {
        snippets.map(\.id)
    }

    private func filter(
        query: String = "",
        minOS: CodeSnippet.MinOS? = nil,
        favorite: FavoriteChoice? = nil,
        favoriteIDs: Set<String> = []
    ) -> [String] {
        ids(SnippetsViewModel.filter(
            fixture, query: query, minOS: minOS, favorite: favorite, favoriteIDs: favoriteIDs
        ))
    }

    func test_filter_noFilters_keepsAllInOrder() {
        XCTAssertEqual(filter(), ["A1", "A2", "B1", "B2"])
    }

    func test_filter_minOS_ios26_keepsOnlyIOS26() {
        XCTAssertEqual(filter(minOS: .ios26), ["B1", "B2"])
    }

    func test_filter_minOS_ios18_keepsOnlyIOS18() {
        XCTAssertEqual(filter(minOS: .ios18), ["A1", "A2"])
    }

    func test_filter_favoriteYes_keepsOnlyFavorites() {
        XCTAssertEqual(filter(favorite: .yes, favoriteIDs: ["A2", "B1"]), ["A2", "B1"])
    }

    func test_filter_favoriteNo_keepsOnlyNonFavorites() {
        XCTAssertEqual(filter(favorite: .no, favoriteIDs: ["A2", "B1"]), ["A1", "B2"])
    }

    func test_filter_favoriteYes_withoutFavorites_returnsEmpty() {
        XCTAssertEqual(filter(favorite: .yes), [])
    }

    func test_filter_search_byTitle_caseInsensitive() {
        XCTAssertEqual(filter(query: "SLIDER"), ["B2"])
    }

    func test_filter_search_byIntro_caseInsensitive() {
        XCTAssertEqual(filter(query: "gradient"), ["A2"])
    }

    /// Раздел (category) у всех сниппетов — Constants.mainCategory.
    func test_filter_search_byCategory() {
        XCTAssertEqual(filter(query: Constants.mainCategory.lowercased()), ["A1", "A2", "B1", "B2"])
    }

    func test_filter_combined_minOSFavoriteAndQuery() {
        // "glass" есть только у B1; B1 — iOS 26 и в избранном.
        XCTAssertEqual(filter(query: "glass", minOS: .ios26, favorite: .yes, favoriteIDs: ["B1"]), ["B1"])
        XCTAssertEqual(filter(query: "glass", minOS: .ios18, favorite: .yes, favoriteIDs: ["B1"]), [])
        XCTAssertEqual(filter(query: "glass", minOS: .ios26, favorite: .no, favoriteIDs: ["B1"]), [])
    }

    // MARK: - Sorting (pure function)

    func test_sort_newestFirst() {
        let sorted = SnippetsViewModel.sort(fixture, option: .newestFirst, randomKeys: [:])
        XCTAssertEqual(ids(sorted), ["B1", "A1", "A2", "B2"])
    }

    func test_sort_oldestFirst() {
        let sorted = SnippetsViewModel.sort(fixture, option: .oldestFirst, randomKeys: [:])
        XCTAssertEqual(ids(sorted), ["B2", "A2", "A1", "B1"])
    }

    /// "Original" — порядок из SnippetsRepository.
    func test_sort_notSorted_keepsOriginalOrder() {
        let sorted = SnippetsViewModel.sort(fixture, option: .notSorted, randomKeys: [:])
        XCTAssertEqual(ids(sorted), ["A1", "A2", "B1", "B2"])
    }

    func test_sort_random_ordersByKeys() {
        let keys = ["A1": 0.9, "A2": 0.1, "B1": 0.5, "B2": 0.3]
        let sorted = SnippetsViewModel.sort(fixture, option: .random, randomKeys: keys)
        XCTAssertEqual(ids(sorted), ["A2", "B2", "B1", "A1"])
    }

    // MARK: - SnippetsViewModel — Filters

    func test_viewModel_defaultState_isNewestFirstAndFiltersEmpty() async throws {
        try await Task.sleep(nanoseconds: 400_000_000)
        XCTAssertEqual(vm.selectedSortOption, .newestFirst)
        XCTAssertTrue(vm.isFiltersEmpty)
        let dates = vm.filteredSnippets.map(\.date)
        XCTAssertEqual(dates, dates.sorted(by: >))
    }

    func test_viewModel_minOSFilter_appliesToList() async throws {
        vm.selectedMinOS = .ios26
        try await Task.sleep(nanoseconds: 400_000_000)
        XCTAssertFalse(vm.filteredSnippets.isEmpty)
        XCTAssertTrue(vm.filteredSnippets.allSatisfy { $0.minOS == .ios26 })
        XCTAssertFalse(vm.isFiltersEmpty)
    }

    func test_viewModel_resetAllFilters_restoresDefaults() {
        vm.selectedMinOS = .ios18
        vm.selectedFavorite = .yes
        vm.selectedSortOption = .oldestFirst

        vm.resetAllFilters()

        XCTAssertNil(vm.selectedMinOS)
        XCTAssertNil(vm.selectedFavorite)
        XCTAssertEqual(vm.selectedSortOption, .newestFirst)
        XCTAssertTrue(vm.isFiltersEmpty)
    }

    func test_viewModel_filters_persistBetweenInstances() {
        vm.selectedMinOS = .ios26
        vm.selectedFavorite = .no
        vm.selectedSortOption = .oldestFirst

        let restoredVM = SnippetsViewModel(services: .make())

        XCTAssertEqual(restoredVM.selectedMinOS, .ios26)
        XCTAssertEqual(restoredVM.selectedFavorite, .no)
        XCTAssertEqual(restoredVM.selectedSortOption, .oldestFirst)
    }

    /// При фильтре "Favourite: Yes" снятие отметки сразу убирает строку:
    /// favoriteIDs входит в пайплайн фильтрации.
    func test_viewModel_unmarkFavorite_underYesFilter_removesRow() async throws {
        let store = MockSnippetFavoritesStore()
        let snippet = SnippetsRepository.a001
        store.favoriteIDs = [snippet.id]
        let testVM = SnippetsViewModel(favoritesStore: store, services: .make())
        testVM.selectedFavorite = .yes
        try await Task.sleep(nanoseconds: 400_000_000)
        XCTAssertEqual(ids(testVM.filteredSnippets), [snippet.id])

        testVM.favoriteToggle(snippet)

        XCTAssertTrue(testVM.filteredSnippets.isEmpty)
    }

    func test_viewModel_randomSort_keepsSameSnippets() async throws {
        vm.selectedSortOption = .random
        try await Task.sleep(nanoseconds: 400_000_000)
        XCTAssertEqual(Set(ids(vm.filteredSnippets)), Set(ids(vm.allSnippets)))
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
        stateManager.getOrCreateAppState().snippetViewedIDs = []
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

    /// Изменение AppSyncState (в т.ч. из iCloud) обновляет кэш избранного.
    func test_viewModel_appSyncStateChange_refreshesFavorites() {
        let store = MockSnippetFavoritesStore()
        let observer = MockCloudChangeObserver()
        let testVM = SnippetsViewModel(favoritesStore: store, cloudChangeObserver: observer, services: .make())
        let snippet = SnippetsRepository.a001
        store.favoriteIDs = [snippet.id]

        observer.sendChange([.appSyncState])

        XCTAssertTrue(testVM.isFavorite(snippet))
    }

    /// Изменения других сущностей кэш избранного не трогают.
    func test_viewModel_otherEntityChange_doesNotRefreshFavorites() {
        let store = MockSnippetFavoritesStore()
        let observer = MockCloudChangeObserver()
        let testVM = SnippetsViewModel(favoritesStore: store, cloudChangeObserver: observer, services: .make())
        let snippet = SnippetsRepository.a001
        store.favoriteIDs = [snippet.id]

        observer.sendChange([.post, .notice])

        XCTAssertFalse(testVM.isFavorite(snippet))
    }

    // MARK: - SnippetsViewModel — Viewed (mock store)

    func test_viewed_unopenedSnippet_isNew() {
        let testVM = SnippetsViewModel(viewedStore: MockSnippetViewedStore(), services: .make())
        XCTAssertTrue(testVM.isNew(SnippetsRepository.a001))
    }

    func test_viewed_init_loadsViewedFromStore() {
        let store = MockSnippetViewedStore()
        store.viewedIDs = [SnippetsRepository.a001.id]

        let testVM = SnippetsViewModel(viewedStore: store, services: .make())

        XCTAssertFalse(testVM.isNew(SnippetsRepository.a001))
        XCTAssertTrue(testVM.isNew(SnippetsRepository.a002))
    }

    func test_viewed_markViewed_snippetIsNoLongerNew() {
        let store = MockSnippetViewedStore()
        let testVM = SnippetsViewModel(viewedStore: store, services: .make())
        let snippet = SnippetsRepository.a001

        testVM.markViewed(snippet)

        XCTAssertFalse(testVM.isNew(snippet))
        XCTAssertEqual(store.markedIDs, [snippet.id])
    }

    /// Повторное открытие не пишет в хранилище — лишняя запись ушла бы в iCloud.
    func test_viewed_markViewedTwice_writesOnce() {
        let store = MockSnippetViewedStore()
        let testVM = SnippetsViewModel(viewedStore: store, services: .make())
        let snippet = SnippetsRepository.a001

        testVM.markViewed(snippet)
        testVM.markViewed(snippet)

        XCTAssertEqual(store.markedIDs, [snippet.id])
    }

    /// Без хранилища (превью) все сниппеты новые, отметка — no-op.
    func test_viewed_withoutStore_allNewAndMarkIsNoOp() {
        let snippet = SnippetsRepository.a001

        vm.markViewed(snippet)

        XCTAssertTrue(vm.isNew(snippet))
    }

    /// Сниппет, открытый на другом устройстве, перестаёт быть новым
    /// после изменения AppSyncState из iCloud.
    func test_viewed_appSyncStateChange_refreshesViewed() {
        let store = MockSnippetViewedStore()
        let observer = MockCloudChangeObserver()
        let testVM = SnippetsViewModel(viewedStore: store, cloudChangeObserver: observer, services: .make())
        let snippet = SnippetsRepository.a001
        store.viewedIDs = [snippet.id]

        observer.sendChange([.appSyncState])

        XCTAssertFalse(testVM.isNew(snippet))
    }

    func test_viewed_otherEntityChange_doesNotRefreshViewed() {
        let store = MockSnippetViewedStore()
        let observer = MockCloudChangeObserver()
        let testVM = SnippetsViewModel(viewedStore: store, cloudChangeObserver: observer, services: .make())
        let snippet = SnippetsRepository.a001
        store.viewedIDs = [snippet.id]

        observer.sendChange([.post, .notice])

        XCTAssertTrue(testVM.isNew(snippet))
    }

    // MARK: - Viewed store (AppSyncStateManager)

    func test_viewedStore_markSnippetViewed_persistsOnce() async throws {
        let store = try await makeFavoritesStore()

        store.markSnippetViewed("A001")
        store.markSnippetViewed("A001")

        XCTAssertEqual(store.getOrCreateAppState().snippetViewedIDs, ["A001"])
        XCTAssertEqual(store.getSnippetViewedIDs(), ["A001"])
    }

    /// Дубли AppSyncState (например, после синка двух устройств) сливаются
    /// с объединением открытых сниппетов — открытый где-либо не станет новым.
    func test_viewedStore_mergeDuplicates_unionsViewedIDs() async throws {
        let store = try await makeFavoritesStore()
        let container = try await Self.sharedFavouritesContainer.value
        store.getOrCreateAppState().snippetViewedIDs = ["A001"]
        let duplicate = AppSyncState()
        duplicate.snippetViewedIDs = ["B007"]
        container.mainContext.insert(duplicate)

        XCTAssertEqual(store.getSnippetViewedIDs(), ["A001", "B007"])
        let states = try container.mainContext.fetch(FetchDescriptor<AppSyncState>())
        XCTAssertEqual(states.count, 1, "дубль должен быть удалён")
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
