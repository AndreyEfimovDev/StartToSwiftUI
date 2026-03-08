//
//  SnippetsViewModel+Filtering.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.03.2026.
//

import SwiftUI
import Combine

// MARK: - Filtering, Searching & Sorting
extension SnippetsViewModel {

    func setupSubscriptions() {
        let filters = $selectedCategory
            .combineLatest($selectedYear, $selectedSortOption)

        let debouncedSearch = $searchText
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)

        $allSnippets
            .combineLatest(debouncedSearch, filters, $reshuffleToken)
            .map { [weak self] snippets, search, data, _ -> [CodeSnippet] in
                guard let self else { return snippets }
                let (category, year, sortOption) = data

                // Always show only .active snippets in the main list
                let active = snippets.filter { $0.status == .active }
                let filtered = self.filterSnippets(snippets: active, category: category, year: year)
                let searched = self.searchSnippets(snippets: filtered, query: search)
                let sorted = self.applySorting(snippets: searched, option: sortOption)

                log("Snippets subscription run", level: .info)
                return sorted
            }
            .sink { [weak self] result in
                guard let self else { return }
                self.filteredSnippets = result
                self.isFiltersEmpty = self.checkIfAllFiltersAreEmpty()
            }
            .store(in: &cancellables)
    }

    private func filterSnippets(
        snippets: [CodeSnippet],
        category: String?,
        year: String?
    ) -> [CodeSnippet] {
        guard category != nil || year != nil else { return snippets }

        return snippets.filter { snippet in
            let matchesCategory = category == nil || snippet.category == category
            let snippetYear = String(utcCalendar.component(.year, from: snippet.date))
            let matchesYear = year == nil || snippetYear == year
            return matchesCategory && matchesYear
        }
    }

    func checkIfAllFiltersAreEmpty() -> Bool {
        selectedCategory == nil &&
        selectedYear == nil &&
        selectedSortOption == .notSorted
    }

    func resetAllFilters() {
        selectedCategory = nil
        selectedYear = nil
        selectedSortOption = .notSorted
    }

    private func searchSnippets(snippets: [CodeSnippet], query: String) -> [CodeSnippet] {
        guard !query.isEmpty else { return snippets }
        let q = query.lowercased()
        return snippets.filter {
            $0.title.lowercased().contains(q) ||
            $0.intro.lowercased().contains(q) ||
            $0.codeSnippet.lowercased().contains(q) ||
            ($0.thanks?.lowercased().contains(q) ?? false)
        }
    }

    private func applySorting(snippets: [CodeSnippet], option: SortOption) -> [CodeSnippet] {
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

    func reshuffleSnippets() {
        randomSortOrder = allSnippets.map { $0.id }.shuffled()
        reshuffleToken = UUID()
    }
}
