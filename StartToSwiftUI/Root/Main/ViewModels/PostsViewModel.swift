//
//  PostViewModel.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.08.2025.
//

import Foundation
import SwiftUI
import Combine

class PostsViewModel: ObservableObject {
    
    // MARK: PROPERTIES
    
    @Published var allPosts: [Post] = []
    @Published var filteredPosts: [Post] = []
    @Published var searchText: String = ""
    @Published var isFiltersEmpty: Bool = true

    // stored folters
    @AppStorage("storedLevel") var storedLevel: StudyLevel?
    @AppStorage("storedFavorite") var storedFavorite: FavoriteChoice?
    @AppStorage("storedLanguage") var storedLanguage: LanguageOptions?
    @AppStorage("storedPlatform") var storedPlatform: Platform?
    @AppStorage("storedYear") var storedYear: String?
    
    // stored preferances
    @AppStorage("isNotification") var isNotification: Bool = false

    
    @Published var selectedLevel: StudyLevel? = nil {
        didSet { storedLevel = selectedLevel } }
    @Published var selectedFavorite: FavoriteChoice? = nil {
        didSet { storedFavorite = selectedFavorite }
    }
    @Published var selectedLanguage: LanguageOptions? = nil {
        didSet { storedLanguage = selectedLanguage }
    }
    @Published var selectedPlatform: Platform? = nil {
        didSet { storedPlatform = selectedPlatform }
    }
    @Published var selectedYear: String? = nil {
        didSet { storedYear = selectedYear }
    }
    
    var listOfYearsInPosts: [String]? = nil
    

    private var cancellables = Set<AnyCancellable>()
    private let fileManager = FileStorageManager.shared
    
    
    // MARK: INIT() SECTION
    
    init() {
        
        self.allPosts = fileManager.loadPosts()
                
        self.filteredPosts = self.allPosts
        
        // get list of years of posts
        self.listOfYearsInPosts = getListOfPostedYearsOfPosts() // get list of years of posts
        
        // filters initilazation
        self.selectedLevel = self.storedLevel
        self.selectedFavorite = self.storedFavorite
        self.selectedLanguage = self.storedLanguage
        self.selectedPlatform = self.storedPlatform
        self.selectedYear = self.storedYear
        self.isFiltersEmpty = checkIfAllFiltersAreEmpty()
        
        // subscription
        addSubscribers()
    }
    
    // MARK: PRIVATE FUNCTIONS
    
    private func addSubscribers() {
        
        let filters = $selectedLevel
            .combineLatest($selectedFavorite, $selectedLanguage, $selectedPlatform)
        
        $selectedYear
            .combineLatest(filters)
            .map {year, filters -> [Post] in
                let (level, favorite, language, platform) = filters
                return self.filterPosts(
                    allPosts: self.allPosts,
                    level: level,
                    favorite: favorite,
                    language: language,
                    platform: platform,
                    year: year
                )
            }
            .sink { [weak self] filtered in
                self?.filteredPosts = filtered
            }
            .store(in: &cancellables)
        
        $allPosts
            .map { posts -> [Post] in
                return self.filterPosts(
                    allPosts: posts,
                    level: self.selectedLevel,
                    favorite: self.selectedFavorite,
                    language: self.selectedLanguage,
                    platform: self.selectedPlatform,
                    year: self.selectedYear
                )
            }
            .sink { [weak self] posts in
                guard let self = self else { return }
                if !posts.isEmpty {
                    self.filteredPosts.removeAll()
                    self.filteredPosts = posts
                    
                }
            }
            .store(in: &cancellables)
    }
    
    private func filterPosts(
        allPosts: [Post],
        level: StudyLevel?,
        favorite: FavoriteChoice?,
        language: LanguageOptions?,
        platform: Platform?,
        year: String?) -> [Post] {
            
//            if checkIfAllFiltersAreEmpty() {
//                return allPosts
//            }
                    if level == nil &&
                        favorite == nil &&
                        language == nil &&
                        platform == nil &&
                        year == nil {
                        return allPosts
                    }
            return allPosts.filter { post in
                let matchesLevel = level == nil || post.studyLevel == level
                let matchesFavorite = favorite == nil || post.favoriteChoice == favorite
                let matchesLanguage = language == nil || post.postLanguage == language
                let matchesPlatform = platform == nil || post.postPlatform == platform
                
                let postYear = String(Calendar.current.component(.year, from: post.postDate ?? Date()))
                let matchesYear = year == nil || postYear == year
                
                return matchesLevel && matchesFavorite && matchesLanguage && matchesPlatform && matchesYear
            }
        }


    // MARK: PUBLIC FUNCTIONS
    
    func addPost(_ newPost: Post) {
//        
//        if !checkNewPostForUniqueTitle(newPost.title) {
            print("FUNC: Adding a new post")
            allPosts.append(newPost)
            fileManager.savePosts(allPosts)
//        } else {
//            print("❌ A post with this title already exists")
//        }
    }
    
    func updatePost(_ updatedPost: Post) {
        if let index = allPosts.firstIndex(where: { $0.id == updatedPost.id }) {
            print("FUNC: Updating a current post")
        allPosts[index] = updatedPost
        listOfYearsInPosts = getListOfPostedYearsOfPosts()
        fileManager.savePosts(allPosts)
        } else {
            print("❌ Can't find the index")
        }
    }
    
    
    func deletePost(post: Post) {
        
        if let index = allPosts.firstIndex(of: post) {
            allPosts.remove(at: index)
            listOfYearsInPosts = getListOfPostedYearsOfPosts()
            fileManager.savePosts(allPosts)
        }
    }
        
    func eraseAllPosts(_ completion: @escaping () -> ()) {
        
        filteredPosts = []
        allPosts = []
        listOfYearsInPosts = getListOfPostedYearsOfPosts()
        fileManager.savePosts(allPosts)
        completion()
    }
    
    func loadPersistentPosts(_ completion: @escaping () -> ()) {
        
        let receivedPosts: [Post] = DevPreview.samplePosts // load MockData - to change to Networking later to load from cloud
        
        // skip posts with the same title - make posts unique by title
        let newPosts = receivedPosts.filter { newPost in
            !allPosts.contains(where: { $0.title == newPost.title })
        }
        allPosts.append(contentsOf: newPosts)
        fileManager.savePosts(allPosts)
        completion()
    }
    
    func importPostsFromURL(_ url: URL, completion: @escaping () -> ()) {
        do {
            let data = try Data(contentsOf: url)
            let posts = try JSONDecoder().decode([Post].self, from: data)
            allPosts = posts
            fileManager.savePosts(posts)
            print("✅ Imported \(posts.count) posts from \(url.lastPathComponent)")
            completion()
        } catch {
            print("❌ Error import: \(error.localizedDescription)")
        }
    }
    
    /// Checks if a title of a post is unique.
    ///
    /// The result is used to avoid doublied posts with the same titles.
    ///
    /// ```
    /// checkIfAllFilterAreEmpty() -> Bool
    /// ```
    ///
    /// - Warning: This app is made for self study learning purpose only.
    /// - Returns: Returns a boolean, true if a title of a post is unique and false if not unique.

//    func checkNewPostForUniqueTitle(_ newPostTitle: String) -> Bool {
//        
//        if allPosts.contains(where: { $0.title == newPostTitle }) {
//            return true // yes, post with the same newTitle already exists in allPosts
//        } else {
//            return false // no, newTitle is an unique title
//        }
//    }
    
    func checkNewPostForUniqueTitle(_ postTitle: String, excludingPostId: UUID?) -> Bool {
//        If there is a post with the same title and its id is not equal to excludingPostId, then the title is not unique
        return allPosts.contains(where: { $0.title == postTitle && $0.id != excludingPostId })

//        if allPosts.contains(where: { $0.title == postTitle && $0.id != excludingPostId }) {
//            return true
//        } else {
//            return false
//        }
//        return allPosts.contains { post in
//            post.title == postTitle && post.id != excludingPostId
//        }
    }
    
    func favoriteToggle(post: Post) {
        
        if let index = allPosts.firstIndex(of: post) {
            switch allPosts[index].favoriteChoice {
            case .no:
                allPosts[index].favoriteChoice = .yes
            case .yes:
                allPosts[index].favoriteChoice = .no
            }
        }
    }
            
    /// Checks all filters for their values.
    ///
    /// The result is used in different snip codes: in FilterButton to change its apearance in its parent UI, also when filtering posts, etc.
    ///
    /// ```
    /// checkIfAllFilterAreEmpty() -> Bool
    /// ```
    ///
    /// - Warning: This app is made for self study learning purpose only.
    /// - Returns: Returns a boolean, true if all filters are not set (nil) and false if at least one is set.
    func checkIfAllFiltersAreEmpty() -> Bool {
        // check if all filters are empty
        if selectedLevel == nil &&
            selectedFavorite == nil &&
            selectedLanguage == nil &&
            selectedPlatform == nil &&
            selectedYear == nil {
            return true
        } else {
            return false
        }
    }
    
    /// Gets a list of unique years presented in posts .
    ///
    /// The result is used in the FilterSheetView for selecting a year for the filter.
    ///
    /// ```
    /// getListOfPostedYearsOfPosts() -> [String]?
    /// ```
    ///
    /// - Warning: This app is made for self study learning purpose only.
    /// - Returns: Returns an array of strings with the unique values of years.
    ///
   
    private func getListOfPostedYearsOfPosts() -> [String]? {
        
        let list = allPosts.compactMap({ (post) -> String? in
            if let date = post.postDate {
                let year = String(Calendar.current.component(.year, from: date))
                return year
            }
            return nil
        })
        return Array(Set(list)).sorted(by: {$0 < $1})
    }
    
}
