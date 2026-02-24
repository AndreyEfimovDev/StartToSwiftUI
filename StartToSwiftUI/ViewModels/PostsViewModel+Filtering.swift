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
    
    func setupSubscriptions() {
        let filters = $selectedLevel
            .combineLatest($selectedFavorite, $selectedType, $selectedYear)
        
        let filtersWithPlatformAndSortOption = filters
            .combineLatest($selectedPlatform, $selectedSortOption, $selectedCategory)
        
        let debouncedSearchText = $searchText
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
        
        $allPosts
            .combineLatest(debouncedSearchText, filtersWithPlatformAndSortOption, $reshuffleToken)
            .map { [weak self] posts, searchText, data, _ -> [Post] in
                guard let self else { return posts }
                
                let ((level, favorite, type, year), platform, sortOption, category) = data
                
                let filtered = self.filterPosts(
                    allPosts: posts,
                    platform: platform,
                    level: level,
                    favorite: favorite,
                    type: type,
                    year: year,
                    category: category
                )
                
                let searchedPosts = self.searchPosts(posts: filtered)
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
        year: String?,
        category: String? = nil
    ) -> [Post] {
        
        guard platform != nil ||
                level != nil ||
                favorite != nil ||
                type != nil ||
                year != nil ||
                category != nil
        else {
            return allPosts
        }
        
        return allPosts.filter { post in
            let matchesLevel = level == nil || post.studyLevel == level
            let matchesFavorite = favorite == nil || post.favoriteChoice == favorite
            let matchesType = type == nil || post.postType == type
            let matchesPlatform = platform == nil || post.postPlatform == platform
            
            let postYear = String(utcCalendar.component(.year, from: post.postDate ?? Date.distantPast))
            let matchesYear = year == nil || postYear == year
            
            let matchesCategory = category == nil || post.category == category
            
            return matchesLevel && matchesFavorite && matchesType && matchesPlatform && matchesYear && matchesCategory
        }
    }
    
    func checkIfAllFiltersAreEmpty() -> Bool {
        selectedLevel == nil &&
        selectedFavorite == nil &&
        selectedType == nil &&
        selectedPlatform == nil &&
        selectedYear == nil &&
        selectedSortOption == .notSorted
    }
    
    private func searchPosts(posts: [Post]) -> [Post] {
        guard !searchText.isEmpty else { return posts }
        
        if searchText.count == 1 {
            FBAnalyticsManager.shared.logEvent(name: "search_used")
        }
        
        let query = searchText.lowercased()
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
            return posts.sorted { a, b in
                let indexA = randomSortOrder.firstIndex(of: a.id) ?? Int.max
                let indexB = randomSortOrder.firstIndex(of: b.id) ?? Int.max
                return indexA < indexB
            }
        }
    }
    
    func reshufflePosts() {
        randomSortOrder = allPosts.map { $0.id }.shuffled()
        reshuffleToken = UUID() // меняется → pipeline срабатывает
    }

}
