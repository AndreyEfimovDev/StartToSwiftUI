//
//  SnippetsViewModel.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 09.03.2026.
//

import SwiftUI
import Combine
import CoreData

@MainActor
final class SnippetsViewModel: ObservableObject {

    // MARK: - Dependencies
    private let favoritesStore: SnippetFavoritesStoreProtocol?
    private let hapticManager = HapticManager.shared
    let analyticsManager: FBAnalyticsManager

    // MARK: - Data
    @Published var allSnippets: [CodeSnippet] = SnippetsRepository.allDemoCodeSnippet
    @Published var filteredSnippets: [CodeSnippet] = []
    @Published var selectedSnippet: CodeSnippet? = nil
    @Published var searchText: String = ""

    /// Кэш избранного: isFavorite вызывается до 5 раз на строку списка при
    /// каждой перерисовке — читать базу на каждый вызов слишком дорого.
    /// Обновляется после переключения и при изменениях из iCloud.
    @Published private(set) var favoriteIDs: Set<String> = []

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(
        favoritesStore: SnippetFavoritesStoreProtocol? = nil,
        services: AppServiceDependencies
    ) {
        self.favoritesStore = favoritesStore
        self.analyticsManager = services.analyticsManager
        refreshFavorites()
        setupSubscriptions()
        setupSubscriptionForChangesInCloud()
    }

    // MARK: - Favorites
    func isFavorite(_ snippet: CodeSnippet) -> Bool {
        favoriteIDs.contains(snippet.id)
    }

    func favoriteToggle(_ snippet: CodeSnippet) {
        guard let favoritesStore else { return }
        favoritesStore.toggleSnippetFavorite(snippet.id)
        refreshFavorites()
        hapticManager.impact(style: .light)
    }

    /// Перечитывает избранное из хранилища в кэш `favoriteIDs`.
    func refreshFavorites() {
        favoriteIDs = favoritesStore?.getSnippetFavoriteIDs() ?? []
    }

    // MARK: - CloudKit Sync
    /// Отметки, поставленные на другом устройстве, приходят через iCloud —
    /// без этой подписки кэш избранного оставался бы устаревшим до перезапуска.
    private func setupSubscriptionForChangesInCloud() {
        NotificationCenter.default.publisher(for: Notification.Name.NSPersistentStoreRemoteChange)
            .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshFavorites()
            }
            .store(in: &cancellables)
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
