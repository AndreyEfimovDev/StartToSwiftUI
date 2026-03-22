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
    private let favoritesService = SnippetFavouritesService.shared
    private let hapticManager = HapticManager.shared

    // MARK: - Data
    @Published var allSnippets: [CodeSnippet] = SnippetsRepository.allDemoCodeSnippet
    @Published var filteredSnippets: [CodeSnippet] = []
    @Published var selectedSnippet: CodeSnippet? = nil
    @Published var searchText: String = ""

    // MARK: - Init
    init(appStateManager: AppSyncStateManager? = nil) {
        self.appStateManager = appStateManager
        setupSubscriptions()
        if let appStateManager {
            SnippetFavouritesService.shared.configure(with: appStateManager)
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

    // MARK: - Combine Pipeline
    private func setupSubscriptions() {
        $allSnippets
            .combineLatest($searchText
                .debounce(for: .seconds(0.3), scheduler: RunLoop.main))
            .map { [weak self] snippets, query -> [CodeSnippet] in
                guard let self else { return snippets }
                return self.applySearch(snippets: snippets, query: query)
            }
            .assign(to: &$filteredSnippets)
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
}
