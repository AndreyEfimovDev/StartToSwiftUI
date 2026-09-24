//
//  PostsViewModel+Filtering.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 11.02.2026.
//

import SwiftUI
import Combine

// MARK: - Filtering, Searching & Sorting
extension PostsViewModel {

    /// Посты, которые пользователь видит после фильтров и поиска: активные
    /// (не в корзине) и не черновики.
    ///
    /// Единое правило видимости для главного списка и статистики Study
    /// Progress — статистика считается ровно по тем постам, что видны в списке.
    var visiblePosts: [Post] {
        filteredPosts.filter { $0.status == .active && !$0.draft }
    }
    
    func setupSubscriptions() {
        let filters = $selectedLevel
            .combineLatest($selectedFavorite, $selectedType, $selectedYear)
        
        let filtersWithPlatformAndSortOption = filters
            .combineLatest($selectedPlatform, $selectedSortOption)
        
        // share() — один debounce на оба подписчика (фильтрация и аналитика).
        let debouncedSearchText = $searchText
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .share()

        // Аналитика поиска — отдельно от фильтрации: одно событие на "сеанс
        // поиска" (текст стал непустым), независимо от скорости набора и от
        // того, сколько раз пайплайн фильтрации перезапускается по другим
        // причинам (звёздочка, синк, смена фильтра).
        debouncedSearchText
            .map { !$0.isEmpty }
            .removeDuplicates()
            .filter { $0 }
            .sink { [weak self] _ in
                self?.analyticsManager.logEvent(name: "search_used")
            }
            .store(in: &cancellables)
        
        $allPosts
            .combineLatest(debouncedSearchText, filtersWithPlatformAndSortOption, $reshuffleToken)
            .map { [weak self] posts, searchText, data, _ -> [Post] in
                guard let self else { return posts }
                
                let ((level, favorite, type, year), platform, sortOption) = data

                let filtered = self.filterPosts(
                    allPosts: posts,
                    platform: platform,
                    level: level,
                    favorite: favorite,
                    type: type,
                    year: year
                )
                
                // Текст поиска — из пайплайна (после debounce), а не живое
                // self.searchText: иначе перезапуск по другой причине
                // фильтровал бы по тексту в обход задержки.
                let searchedPosts = self.searchPosts(posts: filtered, query: searchText)
                let sortedPosts = self.applySorting(posts: searchedPosts, option: sortOption)
                
                log("Values subscription run", level: .info)
                
                return sortedPosts
            }
            .sink { [weak self] selectedPosts in
                self?.filteredPosts = selectedPosts
            }
            .store(in: &cancellables)
    }
    
    private func filterPosts(
        allPosts: [Post],
        platform: Platform?,
        level: StudyLevel?,
        favorite: FavoriteChoice?,
        type: PostType?,
        year: String?
    ) -> [Post] {
        let categoryFiltered = allPosts.filter { $0.category == Constants.mainCategory }

        guard platform != nil ||
                level != nil ||
                favorite != nil ||
                type != nil ||
                year != nil
        else {
            return categoryFiltered
        }

        return categoryFiltered.filter { post in
            let matchesLevel = level == nil || post.studyLevel == level
            let matchesFavorite = favorite == nil || post.favoriteChoice == favorite
            let matchesType = type == nil || post.postType == type
            let matchesPlatform = platform == nil || post.postPlatform == platform

            // Локальный календарь, как в getAllYears() и при отображении даты.
            let postYear = String(Calendar.current.component(.year, from: post.postDate ?? Date(timeIntervalSince1970: 0)))
            let matchesYear = year == nil || postYear == year

            return matchesLevel && matchesFavorite && matchesType && matchesPlatform && matchesYear
        }
    }
    
    /// Не задан ни один фильтр и сортировка по умолчанию.
    /// Вычисляется, а не хранится: все фильтры `@Published`, так что вьюха
    /// перерисуется при любом их изменении, и ручная синхронизация не нужна.
    var isFiltersEmpty: Bool {
        selectedLevel == nil &&
        selectedFavorite == nil &&
        selectedType == nil &&
        selectedPlatform == nil &&
        selectedYear == nil &&
        selectedSortOption == .notSorted
    }

    /// Сбрасывает все фильтры и сортировку к значениям по умолчанию.
    func resetAllFilters() {
        selectedLevel = nil
        selectedFavorite = nil
        selectedType = nil
        selectedPlatform = nil
        selectedYear = nil
        selectedSortOption = .notSorted
    }
    
    /// Оставляет посты, у которых заголовок, вступление, автор или заметки
    /// содержат `query` (без учёта регистра). Пустой запрос — все посты.
    private func searchPosts(posts: [Post], query rawQuery: String) -> [Post] {
        guard !rawQuery.isEmpty else { return posts }

        let query = rawQuery.lowercased()
        return posts.filter {
            $0.title.lowercased().contains(query) ||
            $0.intro.lowercased().contains(query) ||
            $0.author.lowercased().contains(query) ||
            $0.notes.lowercased().contains(query)
        }
    }
    
    private func applySorting(posts: [Post], option: SortOption) -> [Post] {
        switch option {
        case .notSorted:
            return posts
        case .newestFirst:
            return posts.sorted {
                switch ($0.postDate, $1.postDate) {
                case (let date1?, let date2?): return date1 > date2
                case (nil, _): return false
                case (_, nil): return true
                }
            }
        case .oldestFirst:
            return posts.sorted {
                switch ($0.postDate, $1.postDate) {
                case (let date1?, let date2?): return date1 < date2
                case (nil, _): return false
                case (_, nil): return true
                }
            }
        case .random:
            // Посты без ключа получают случайный ключ прямо здесь: и после
            // перезапуска с сохранённым "Random" (reshufflePosts() тогда
            // срабатывает в init, до загрузки постов), и для постов,
            // добавленных после перемешивания, — они встают на случайное
            // место, а не в конец. Словарь вместо поиска индекса в массиве —
            // O(1) на сравнение вместо O(n).
            for post in posts where randomSortKeys[post.id] == nil {
                randomSortKeys[post.id] = Double.random(in: 0..<1)
            }
            return posts.sorted { (randomSortKeys[$0.id] ?? 0) < (randomSortKeys[$1.id] ?? 0) }
        }
    }
    
    /// Перемешивает список заново: старые ключи сбрасываются, новые
    /// раздаются при следующей сортировке.
    func reshufflePosts() {
        randomSortKeys.removeAll()
        reshuffleToken = UUID() // on change → Combine pipeline is triggered
    }

}
