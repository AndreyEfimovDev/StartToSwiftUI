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
    private let favoritesStore: SnippetFavoritesStoreProtocol?
    private let viewedStore: SnippetViewedStoreProtocol?
    private let cloudChangeObserver: CloudChangeObserving?
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

    /// Кэш открытых сниппетов — по той же причине, что и favoriteIDs:
    /// isNew вызывается на каждую строку при каждой перерисовке.
    @Published private(set) var viewedIDs: Set<String> = []

    // MARK: - Filters (AppStorage — сохраняются между запусками)
    /// Сортировка по умолчанию — от новых к старым: так список выглядел
    /// до появления фильтров, и к ней же возвращает "Reset All".
    static let defaultSortOption: SortOption = .newestFirst

    @AppStorage("storedSnippetMinOS") private var storedMinOS: CodeSnippet.MinOS?
    @Published var selectedMinOS: CodeSnippet.MinOS? = nil {
        didSet { storedMinOS = selectedMinOS }}

    @AppStorage("storedSnippetFavorite") private var storedFavorite: FavoriteChoice?
    @Published var selectedFavorite: FavoriteChoice? = nil {
        didSet { storedFavorite = selectedFavorite }}

    @AppStorage("storedSnippetSortOption") private var storedSortOption: SortOption = SnippetsViewModel.defaultSortOption
    @Published var selectedSortOption: SortOption = SnippetsViewModel.defaultSortOption {
        didSet {
            storedSortOption = selectedSortOption
            if selectedSortOption == .random {
                reshuffleSnippets()
            }
        }
    }

    /// Случайные ключи сортировки для `.random` — по id сниппета.
    private var randomSortKeys: [String: Double] = [:]
    /// Смена токена перезапускает пайплайн после перемешивания.
    @Published private var reshuffleToken = UUID()

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(
        favoritesStore: SnippetFavoritesStoreProtocol? = nil,
        viewedStore: SnippetViewedStoreProtocol? = nil,
        cloudChangeObserver: CloudChangeObserving? = nil,
        services: AppServiceDependencies
    ) {
        self.favoritesStore = favoritesStore
        self.viewedStore = viewedStore
        self.cloudChangeObserver = cloudChangeObserver
        self.analyticsManager = services.analyticsManager
        refreshFavorites()
        refreshViewed()
        restoreFilters()
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

    // MARK: - Viewed (new snippets)
    /// Сниппет новый, пока пользователь его не открыл.
    func isNew(_ snippet: CodeSnippet) -> Bool {
        !viewedIDs.contains(snippet.id)
    }

    /// Отмечает сниппет открытым; уже открытый не трогает хранилище.
    func markViewed(_ snippet: CodeSnippet) {
        guard let viewedStore, isNew(snippet) else { return }
        viewedStore.markSnippetViewed(snippet.id)
        refreshViewed()
    }

    /// Перечитывает открытые сниппеты из хранилища в кэш `viewedIDs`.
    func refreshViewed() {
        viewedIDs = viewedStore?.getSnippetViewedIDs() ?? []
    }

    // MARK: - CloudKit Sync
    /// Отметки, поставленные на другом устройстве, приходят через iCloud —
    /// без этой подписки кэш избранного оставался бы устаревшим до перезапуска.
    private func setupSubscriptionForChangesInCloud() {
        // Избранное и открытые сниппеты хранятся в AppSyncState.
        cloudChangeObserver?.changes
            .filter { $0.contains(.appSyncState) }
            .sink { [weak self] _ in
                self?.refreshFavorites()
                self?.refreshViewed()
            }
            .store(in: &cancellables)
    }

    // MARK: - Filters
    /// Не задан ни один фильтр и сортировка по умолчанию.
    var isFiltersEmpty: Bool {
        selectedMinOS == nil &&
        selectedFavorite == nil &&
        selectedSortOption == Self.defaultSortOption
    }

    /// Сбрасывает фильтры и сортировку к значениям по умолчанию.
    func resetAllFilters() {
        selectedMinOS = nil
        selectedFavorite = nil
        selectedSortOption = Self.defaultSortOption
    }

    /// Перемешивает список заново: старые ключи сбрасываются, новые
    /// раздаются при следующей сортировке.
    func reshuffleSnippets() {
        randomSortKeys.removeAll()
        reshuffleToken = UUID()
    }

    /// Восстанавливает фильтры, сохранённые в прошлом запуске.
    private func restoreFilters() {
        selectedMinOS = storedMinOS
        selectedFavorite = storedFavorite
        selectedSortOption = storedSortOption
    }

    // MARK: - Combine Pipeline
    private func setupSubscriptions() {
        let debouncedSearch = $searchText
            .debounce(for: .seconds(0.3), scheduler: RunLoop.main)

        let filters = $selectedMinOS
            .combineLatest($selectedFavorite, $selectedSortOption)

        // favoriteIDs — в пайплайне: при фильтре "Favourite: Yes" снятая
        // отметка сразу убирает строку из списка.
        let favoritesAndReshuffle = $favoriteIDs
            .combineLatest($reshuffleToken)

        $allSnippets
            .combineLatest(debouncedSearch, filters, favoritesAndReshuffle)
            .map { [weak self] snippets, query, filterData, favoritesData -> [CodeSnippet] in
                guard let self else { return snippets }
                let (minOS, favorite, sortOption) = filterData
                let (favoriteIDs, _) = favoritesData

                let filtered = Self.filter(
                    snippets,
                    query: query,
                    minOS: minOS,
                    favorite: favorite,
                    favoriteIDs: favoriteIDs
                )
                if sortOption == .random {
                    self.assignMissingRandomKeys(to: filtered)
                }
                return Self.sort(filtered, option: sortOption, randomKeys: self.randomSortKeys)
            }
            .assign(to: &$filteredSnippets)
    }

    // MARK: - Filtering, Searching & Sorting

    /// Оставляет сниппеты, подходящие под версию iOS и избранное, у которых
    /// название, описание или раздел содержат `query` (без учёта регистра).
    /// `nil` в фильтре и пустой запрос ничего не отсекают.
    static func filter(
        _ snippets: [CodeSnippet],
        query: String,
        minOS: CodeSnippet.MinOS?,
        favorite: FavoriteChoice?,
        favoriteIDs: Set<String>
    ) -> [CodeSnippet] {
        let q = query.lowercased()
        return snippets.filter { snippet in
            let matchesMinOS = minOS == nil || snippet.minOS == minOS
            let isFavorite = favoriteIDs.contains(snippet.id)
            let matchesFavorite = switch favorite {
            case nil: true
            case .yes: isFavorite
            case .no: !isFavorite
            }
            let matchesQuery = q.isEmpty ||
                snippet.title.lowercased().contains(q) ||
                snippet.intro.lowercased().contains(q) ||
                snippet.category.lowercased().contains(q)
            return matchesMinOS && matchesFavorite && matchesQuery
        }
    }

    /// Сортирует сниппеты. `.notSorted` — порядок из SnippetsRepository;
    /// `.random` — по `randomKeys`, сниппеты без ключа идут первыми (ключ 0).
    static func sort(
        _ snippets: [CodeSnippet],
        option: SortOption,
        randomKeys: [String: Double]
    ) -> [CodeSnippet] {
        switch option {
        case .notSorted:
            return snippets
        case .newestFirst:
            return snippets.sorted { $0.date > $1.date }
        case .oldestFirst:
            return snippets.sorted { $0.date < $1.date }
        case .random:
            return snippets.sorted { (randomKeys[$0.id] ?? 0) < (randomKeys[$1.id] ?? 0) }
        }
    }

    /// Раздаёт случайные ключи сниппетам, у которых их ещё нет: и после
    /// перезапуска с сохранённым "Random", и после reshuffleSnippets().
    private func assignMissingRandomKeys(to snippets: [CodeSnippet]) {
        for snippet in snippets where randomSortKeys[snippet.id] == nil {
            randomSortKeys[snippet.id] = Double.random(in: 0..<1)
        }
    }
}
