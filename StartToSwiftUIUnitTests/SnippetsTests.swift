//
//  SnippetsTests.swift
//  StartToSwiftUITests
//
//  Created by Andrey Efimov on 12.03.2026.
//

import XCTest
import SwiftData
import Combine
@testable import StartToSwiftUI

/*
 27 tests in four groups:
  Repository — the data is correct, the ID is unique, and A001/A002 exists
  ViewModel initial state — filters are empty, filteredSnippets is the same as allSnippets
  Filtering & Search & Sorting — all combinations
  FavoritesService + ViewModel integration — toggle, idempotency, ID independence
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
        vm = SnippetsViewModel()
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
    
    func test_viewModel_initialState_filtersAreEmpty() {
        XCTAssertTrue(vm.isFiltersEmpty)
    }

    func test_viewModel_initialState_noSelectedSnippet() {
        XCTAssertNil(vm.selectedSnippet)
    }

    // MARK: - SnippetsViewModel — Filtering

    func test_filterByCategory_returnsCorrectSnippets() async throws {
        let category = "Indicators"
        vm.selectedCategory = category
        try await Task.sleep(nanoseconds: 400_000_000) // wait for debounce
        XCTAssertTrue(vm.filteredSnippets.allSatisfy { $0.category == category })
    }

    func test_filterByCategory_nonExistent_returnsEmpty() async throws {
        vm.selectedCategory = "NonExistentCategory"
        try await Task.sleep(nanoseconds: 400_000_000)
        XCTAssertTrue(vm.filteredSnippets.isEmpty)
    }

    func test_resetAllFilters_clearsCategory() async throws {
        vm.selectedCategory = "Indicators"
        try await Task.sleep(nanoseconds: 400_000_000)
        vm.resetAllFilters()
        try await Task.sleep(nanoseconds: 400_000_000)
        XCTAssertNil(vm.selectedCategory)
        XCTAssertTrue(vm.isFiltersEmpty)
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

    // MARK: - SnippetsViewModel — Sorting

    func test_sort_newestFirst_isDescending() async throws {
        vm.selectedSortOption = .newestFirst
        try await Task.sleep(nanoseconds: 400_000_000)
        let dates = vm.filteredSnippets.map { $0.date }
        XCTAssertEqual(dates, dates.sorted(by: >))
    }

    func test_sort_oldestFirst_isAscending() async throws {
        vm.selectedSortOption = .oldestFirst
        try await Task.sleep(nanoseconds: 400_000_000)
        let dates = vm.filteredSnippets.map { $0.date }
        XCTAssertEqual(dates, dates.sorted(by: <))
    }

    func test_sort_notSorted_matchesOriginalOrder() async throws {
        vm.selectedSortOption = .notSorted
        try await Task.sleep(nanoseconds: 400_000_000)
        XCTAssertEqual(vm.filteredSnippets.map { $0.id }, vm.allSnippets.map { $0.id })
    }

    func test_sort_random_sameCount() async throws {
        vm.selectedSortOption = .random
        try await Task.sleep(nanoseconds: 400_000_000)
        XCTAssertEqual(vm.filteredSnippets.count, vm.allSnippets.count)
    }

    // MARK: - SnippetFavoritesService

    func test_favorites_toggle_addsFavorite() {
        let service = SnippetFavouritesService.shared
        service.toggle("A001")
        XCTAssertTrue(service.isFavorite("A001"))
        service.toggle("A001") // cleanup
    }

    func test_favorites_toggle_removesFavorite() {
        let service = SnippetFavouritesService.shared
        service.toggle("A001")
        service.toggle("A001")
        XCTAssertFalse(service.isFavorite("A001"))
    }

    func test_favorites_toggle_idempotentMultipleTimes() {
        let service = SnippetFavouritesService.shared
        service.toggle("A002")
        service.toggle("A002")
        service.toggle("A002")
        XCTAssertTrue(service.isFavorite("A002"))
        service.toggle("A002") // cleanup
    }

    func test_favorites_differentIDs_independant() {
        let service = SnippetFavouritesService.shared
        service.toggle("A001")
        XCTAssertTrue(service.isFavorite("A001"))
        XCTAssertFalse(service.isFavorite("A002"))
        service.toggle("A001") // cleanup
    }

    // MARK: - SnippetsViewModel — Favorites Integration

    func test_viewModel_favoriteToggle_updatesState() {
        let snippet = SnippetsRepository.a001
        let before = vm.isFavorite(snippet)
        vm.favoriteToggle(snippet)
        XCTAssertNotEqual(vm.isFavorite(snippet), before)
        vm.favoriteToggle(snippet) // cleanup
    }
}
