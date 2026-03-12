//
//  SnippetsViewModel.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 09.03.2026.
//

import SwiftUI
import Combine

@MainActor
final class SnippetsViewModel: ObservableObject {

    // MARK: - Dependencies
    private let appStateManager: AppSyncStateManager?
    private let favoritesService = SnippetFavoritesService.shared
    private let hapticManager = HapticManager.shared

    // MARK: - Data
    @Published var allSnippets: [CodeSnippet] = SnippetsRepository.all
    @Published var filteredSnippets: [CodeSnippet] = []
    @Published var selectedSnippet: CodeSnippet? = nil
    @Published var searchText: String = ""
    @Published var isFiltersEmpty: Bool = true
    @Published var reshuffleToken = UUID()

    private var cancellables = Set<AnyCancellable>()
    private var randomSortOrder: [String] = []

    // MARK: - Filters (AppStorage — persisted between sessions)
    @AppStorage("snippet_storedCategory") private var storedCategory: String?
    @Published var selectedCategory: String? = nil {
        didSet { storedCategory = selectedCategory }
    }

    @AppStorage("snippet_storedSortOption") private var storedSortOption: SortOption = .notSorted
    
    @Published var selectedSortOption: SortOption = .notSorted {
        didSet {
            storedSortOption = selectedSortOption
            if selectedSortOption == .random { reshuffleSnippets() }
        }
    }

    // MARK: - Computed Properties
    var allCategories: [String]? {
        let cats = Array(Set(allSnippets.map { $0.category })).sorted()
        return cats.isEmpty ? nil : cats
    }

    var allYears: [String]? {
        let years = Array(Set(allSnippets.map {
            String(Calendar.current.component(.year, from: $0.date))
        })).sorted()
        return years.isEmpty ? nil : years
    }

    // MARK: - Init
    init(appStateManager: AppSyncStateManager? = nil) {
        self.appStateManager = appStateManager
        restoreFilters()
        setupSubscriptions()
        if let appStateManager {
            SnippetFavoritesService.shared.configure(with: appStateManager)
        }
    }

    // MARK: - Favorites
    func isFavorite(_ snippet: CodeSnippet) -> Bool {
        favoritesService.isFavorite(snippet.id)
    }

    func favoriteToggle(_ snippet: CodeSnippet) {
        favoritesService.toggle(snippet.id)
        hapticManager.impact(style: .light)
        objectWillChange.send()
    }

    // MARK: - Filters
    func checkIfAllFiltersAreEmpty() -> Bool {
        selectedCategory == nil &&
        selectedSortOption == .notSorted
    }

    func resetAllFilters() {
        selectedCategory = nil
        selectedSortOption = .notSorted
    }

    func reshuffleSnippets() {
        randomSortOrder = allSnippets.map { $0.id }.shuffled()
        reshuffleToken = UUID()
    }

    // MARK: - Restore
    private func restoreFilters() {
        selectedCategory = storedCategory
        selectedSortOption = storedSortOption
        isFiltersEmpty = checkIfAllFiltersAreEmpty()
    }

    // MARK: - Combine Pipeline
    private func setupSubscriptions() {
        let filters = $selectedCategory
            .combineLatest($selectedSortOption)

        let debouncedSearch = $searchText
            .debounce(for: .seconds(0.3), scheduler: RunLoop.main)

        $allSnippets
            .combineLatest(debouncedSearch, filters, $reshuffleToken)
            .map { [weak self] snippets, search, filterData, _ -> [CodeSnippet] in
                guard let self else { return snippets }
                let (category, sortOption) = filterData
                let filtered = self.applyFilters(snippets: snippets, category: category)
                let searched = self.applySearch(snippets: filtered, query: search)
                return self.applySort(snippets: searched, option: sortOption)
            }
            .sink { [weak self] result in
                guard let self else { return }
                self.filteredSnippets = result
                self.isFiltersEmpty = self.checkIfAllFiltersAreEmpty()
            }
            .store(in: &cancellables)
    }

    // MARK: - Private Helpers
    private func applyFilters(
        snippets: [CodeSnippet],
        category: String?
    ) -> [CodeSnippet] {
        guard category != nil else { return snippets }
        return snippets.filter { snippet in
            let matchesCategory = category == nil || snippet.category == category
            return matchesCategory
        }
    }

    private func applySearch(snippets: [CodeSnippet], query: String) -> [CodeSnippet] {
        guard !query.isEmpty else { return snippets }
        let q = query.lowercased()
        return snippets.filter {
            $0.title.lowercased().contains(q) ||
            $0.intro.lowercased().contains(q) ||
            $0.category.lowercased().contains(q)
        }
    }

    private func applySort(snippets: [CodeSnippet], option: SortOption) -> [CodeSnippet] {
        switch option {
        case .notSorted:   return snippets
        case .newestFirst: return snippets.sorted { $0.date > $1.date }
        case .oldestFirst: return snippets.sorted { $0.date < $1.date }
        case .random:
            return snippets.sorted { a, b in
                let ia = randomSortOrder.firstIndex(of: a.id) ?? Int.max
                let ib = randomSortOrder.firstIndex(of: b.id) ?? Int.max
                return ia < ib
            }
        }
    }
}
