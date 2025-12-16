//
//  PostViewModel.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.08.2025.
//

import Foundation
import SwiftUI
import Combine
import Speech

class PostsViewModel: ObservableObject {
    
    // MARK: PROPERTIES
    
    // Services
    private let fileManager = JSONFileManager.shared
    private let hapticManager = HapticService.shared
    private let networkService: NetworkService
    
    @Published var allPosts: [Post] = [] {
        didSet {
            allYears = getAllYears()
            allCategories = getAllCategories()
        }
    }
    
    @Published var filteredPosts: [Post] = []
    @Published var searchText: String = ""
    @Published var isFiltersEmpty: Bool = true
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var errorMessage: String?
    @Published var showErrorMessageAlert = false
    
    private var utcCalendar = Calendar.current
    var allYears: [String]? = nil
    var allCategories: [String]? = nil
    let mainCategory: String = "SwiftUI"
    var dispatchTime: DispatchTime { .now() + 1.5 }
    @Published var selectedRating: PostRating? = nil
    @Published var selectedStudyProgress: StudyProgress = .fresh

    
    // MARK: Stored preferances
    
    @AppStorage("selectedTheme") var selectedTheme: Theme = .system
    @AppStorage("isTermsOfUseAccepted") var isTermsOfUseIsAccepted: Bool = false
    @AppStorage("isFirstImportPostsCompleted") var isFirstImportPostsCompleted: Bool = false {
        didSet {
            localLastUpdated = getLatestDateFromPosts(posts: allPosts) ?? .now
        }
    }
    
    // Stored the date of the Cloud posts last imported (ISO8601DateFormatter().date(from: "2000-01-15T00:00:00Z") ?? Date.distantPast)
    @AppStorage("localLastUpdated") var localLastUpdated: Date = Date.distantPast

    // Stored filters
    @AppStorage("storedCategory") var storedCategory: String?
    @AppStorage("storedLevel") var storedLevel: StudyLevel?
    @AppStorage("storedFavorite") var storedFavorite: FavoriteChoice?
    @AppStorage("storedType") var storedType: PostType?
    @AppStorage("storedPlatform") var storedPlatform: Platform?
    @AppStorage("storedYear") var storedYear: String?
    @AppStorage("storedSortOption") var storedSortOption: SortOption?

    // Setting filters
    @Published var selectedCategory: String? = nil {
        didSet { storedCategory = selectedCategory }}
    @Published var selectedLevel: StudyLevel? = nil {
        didSet { storedLevel = selectedLevel }}
    @Published var selectedFavorite: FavoriteChoice? = nil {
        didSet { storedFavorite = selectedFavorite }}
    @Published var selectedType: PostType? = nil {
        didSet { storedType = selectedType }}
    @Published var selectedYear: String? = nil {
        didSet { storedYear = selectedYear }}
    @Published var selectedSortOption: SortOption? = nil {
        didSet { storedSortOption = selectedSortOption }}
    @Published var selectedPostId: String? = nil
    
    // MARK: INIT() SECTION
    
    init(
        networkService: NetworkService = NetworkService(baseURL: Constants.cloudPostsURL)
    ) {
        self.networkService = networkService

        // Load local JSON file with notices and then
        if fileManager.checkIfFileExists(fileName: Constants.localPostsFileName) {
            fileManager.loadData(fileName: Constants.localPostsFileName) { [weak self] (result: Result<[Post], FileStorageError>) in
                
                self?.errorMessage = nil
                self?.showErrorMessageAlert = false
                
                DispatchQueue.main.async {
                    switch result {
                    case .success(let posts):
                        self?.allPosts = posts
                        print("🍓 VM(init): Successfully loaded \(posts.count) posts")
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                        self?.showErrorMessageAlert = true
                        print("🍓 ☑️ VM(init): Failed to load posts: \(error)")
                    }
                }
            }
        } else {
            print("🍓 ☑️ VM(init): File \(Constants.localPostsFileName) does not exist")
            allPosts = StaticPost.staticPosts
            savePosts()
            print("🍓 VM(init): Loaded static posts")
        }
        
        // Filters initilazation
        print("🍓 storedCategory is: \(String(describing: storedCategory?.description))")

//        if let category = self.storedCategory {
//            self.selectedCategory = category
//            print("🍓 storedCategory is NOT NIL, selectedCategory: \(String(describing: selectedCategory?.description))")
//        } else {
//            self.selectedCategory = self.mainCategory
//            print("🍓 storedCategory is NIL, selectedCategory: \(String(describing: selectedCategory?.description))")
//
//        }
        self.selectedCategory = self.storedCategory
        self.selectedLevel = self.storedLevel
        self.selectedFavorite = self.storedFavorite
        self.selectedType = self.storedType
        self.selectedYear = self.storedYear
        self.selectedSortOption = self.storedSortOption
        
        self.isFiltersEmpty = checkIfAllFiltersAreEmpty()
        
        // Set time zone
        if let utcTimeZone = TimeZone(secondsFromGMT: 0) {
            utcCalendar.timeZone = utcTimeZone
        } else {
            print("🍓❌ VM(init): TimeZone is not set")
        }
        
        // Initiating subscriptions
        addSubscribers()
        
    }
    
    // MARK: PRIVATE FUNCTIONS
    
    private func addSubscribers() {
        
        
        let filters = $selectedLevel
            .combineLatest($selectedFavorite, $selectedType, $selectedYear)

        let filtersWithCategoryAndSort = filters
            .combineLatest(/*$selectedCategory, */$selectedSortOption)
            .map { filters, /*category, */sortOption -> (filters: (StudyLevel?, FavoriteChoice?, PostType?, String?), /*category: String?,*/ sortOption: SortOption?) in
                return (filters, /*category,*/ sortOption)
            }

        let debouncedSearchText = $searchText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)

        $allPosts
            .combineLatest(debouncedSearchText, filtersWithCategoryAndSort)
            .map { posts, searchText, data -> [Post] in
                let (filters, /*category, */sortOption) = data
                let (level, favorite, type, year) = filters
                
                let filtered = self.filterPosts(
                    allPosts: posts,
//                    category: category,
                    level: level,
                    favorite: favorite,
                    type: type,
                    year: year
                )
                
                let serachedPosts = self.searchPosts(posts: filtered)
                
                return self.applySorting(posts: serachedPosts, option: sortOption)
            }
            .sink { [weak self] selectedPosts in
                self?.filteredPosts = selectedPosts
            }
            .store(in: &cancellables)
    }
        
    private func filterPosts(
        allPosts: [Post],
//        category: String?,
        level: StudyLevel?,
        favorite: FavoriteChoice?,
        type: PostType?,
        year: String?) -> [Post] {
            
            if level == nil &&
                favorite == nil &&
                type == nil &&
                year == nil {
                return allPosts
            }
            let filteredPosts = allPosts.filter { post in
                let matchesLevel = level == nil || post.studyLevel == level
                let matchesFavorite = favorite == nil || post.favoriteChoice == favorite
                let matchesType = type == nil || post.postType == type
                let postYear = String(utcCalendar.component(.year, from: post.postDate ?? Date.distantPast))
                let matchesYear = year == nil || postYear == year
                
                return matchesLevel && matchesFavorite && matchesType && matchesYear
            }
            
//            if let category = category {
//                return filteredPosts.filter { $0.category == category }
//            } else {
                return filteredPosts
//            }
            
        }
    
    private func searchPosts(posts: [Post]) -> [Post] {
        guard !searchText.isEmpty else {
            return posts
        }
        return posts.filter( {
            $0.title.lowercased().contains(searchText.lowercased()) ||
            $0.intro.lowercased().contains(searchText.lowercased())  ||
            $0.author.lowercased().contains(searchText.lowercased()) ||
            $0.notes.lowercased().contains(searchText.lowercased())
        })
    }
    
    private func applySorting(posts: [Post], option: SortOption?) -> [Post] {
        guard let option = option else {
            // If nil - return unsorded (original order in array)
            return posts
        }
        
        // posts with postDate = nil are always at the end
        switch option {
        case .random:
            return posts.shuffled() // random shuffle
        case .newestFirst:
            return posts.sorted {
                switch ($0.postDate, $1.postDate) {
                case (let date1?, let date2?): return date1 > date2 // Newest first
                case (nil, _): return false // postDate = nil are always at the end
                case (_, nil): return true // postDate ≠ nil are always before nil
                }
            }
        case .oldestFirst:
            return posts.sorted {
                switch ($0.postDate, $1.postDate) {
                case (let date1?, let date2?): return date1 < date2 // Oldest first
                case (nil, _): return false // postDate = nil are always at the end
                case (_, nil): return true // postDate ≠ nil are always before nil
                }
            }
        }
    }

    // MARK: PUBLIC FUNCTIONS
    
    func addPost(_ newPost: Post) {
        print("🍓 VM(addPost): Adding a new post")
        allPosts.append(newPost)
        savePosts()
    }
    
    func updatePost(_ updatedPost: Post) {
        if let index = allPosts.firstIndex(where: { $0.id == updatedPost.id }) {
            print("🍓 VM(updatePost): Updating a current edited post")
            allPosts[index] = updatedPost
            savePosts()
        } else {
            print("🍓❌ VM(updatePost): Can't find the index")
        }
    }
    
    func deletePost(post: Post?) {
        if let validPost = post {
            if let index = allPosts.firstIndex(of: validPost) {
                allPosts.remove(at: index)
                savePosts()
            }
        } else {
            print("🍓VM.deletePost: passed post is nil")
        }
    }
    
    func eraseAllPosts(_ completion: @escaping () -> ()) {
        allPosts = []
        savePosts()
        completion()
    }
    
    func favoriteToggle(post: Post) {
        
        if let index = allPosts.firstIndex(of: post) {
            switch allPosts[index].favoriteChoice {
            case .no:
                allPosts[index].favoriteChoice = .yes
            case .yes:
                allPosts[index].favoriteChoice = .no
            }
            savePosts()
        }
    }
    
    func ratePost(post: Post) {
        
        if let index = allPosts.firstIndex(of: post) {
            allPosts[index].postRating = selectedRating
            savePosts()
        }
    }
    
    func updatePostStudyProgress(post: Post) {
        
        if let index = allPosts.firstIndex(of: post) {
            allPosts[index].progress = selectedStudyProgress
            switch selectedStudyProgress {
            case .fresh:
                allPosts[index].startedDateStamp = nil
                allPosts[index].studiedDateStamp = nil
                allPosts[index].practicedDateStamp = nil
            case .started:
                allPosts[index].startedDateStamp = .now
                allPosts[index].studiedDateStamp = nil
                allPosts[index].practicedDateStamp = nil
            case .studied:
                allPosts[index].studiedDateStamp = .now
                allPosts[index].practicedDateStamp = nil
            case .practiced:
                allPosts[index].practicedDateStamp = .now
            }
            savePosts()
        }
    }

    private func savePosts() {
        
        fileManager.saveData(allPosts, fileName: Constants.localPostsFileName) { [weak self] result in
            
            self?.errorMessage = nil
            self?.showErrorMessageAlert = false
            
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("🍓 VM(savePosts): Posts saved successfully")
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.showErrorMessageAlert = true
                    self?.hapticManager.notification(type: .error)
                    print("🍓❌ VM(savePosts): Failed to save posts: \(error)")
                }
            }
        }
    }
    
    /// Import manually collected links to study materials for the educational purpose.
    ///
    /// Manually collected links to educational materials are used to create a curated collection for deployment in the cloud.
    ///
    /// ```
    /// loadPersistentPosts() -> Void
    /// ```
    ///
    /// - Warning: This application is intended for self-study.
    /// - Returns: Returns a boolean result or error within completion handler.
    
    func loadPersistentPosts(posts: [Post], _ completion: @escaping () -> ()) {
        
        // Skipping posts with the same title - make posts unique by title
        let newPosts = posts.filter { newPost in
            !allPosts.contains(where: { $0.title == newPost.title })
        }
        
        if !newPosts.isEmpty {
            allPosts.append(contentsOf: newPosts)
            savePosts()
        }
        completion()
    }
    
    func getFilePath(fileName: String) -> Result<URL, FileStorageError> {
        
        print("🍓FM(getFilePath): Getting url.")
        
        let urlResult = fileManager.getFileURL(fileName: fileName)
        
        switch urlResult {
        case .success(let url):
            print("🍓FM(getFilePath): Successfully got file url: \(url).")
            return .success(url)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    
    /// Import posts from the Cloud using the specified URL string.
    ///
    /// Imported posts from the Cloud are processed as follows:
    ///  - Only posts with unique titles are selected.
    ///  - Only posts with unique ID are selected (check just in case).
    ///  - The selected posts are added to the current posts.
    ///  - The latest date from posts is saved for subsequent checking.
    ///
    ///
    /// ```
    /// checkCloudForUpdates() -> Void
    /// ```
    ///
    /// - Warning: This application is intended for self-study.
    /// - Returns: Returns a boolean result or error within completion handler.
    
    func importPostsFromCloud(urlString: String = Constants.cloudPostsURL, completion: @escaping () -> Void) {
        
        self.errorMessage = nil
        self.showErrorMessageAlert = false
        
        networkService.fetchDataFromURL() { [weak self] (result: Result<[Post], Error>) in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let cloudResponse):
                    print("🍓 Successfully imported \(cloudResponse.count) posts from the cloud")
                    // Selecting Cloud posts with unique Titles only -  - do not append such posts from Cloud
                    let cloudPostsAfterCheckForUniqueTitle = cloudResponse.filter { postFromCloud in
                        !(self?.allPosts.contains(where: { $0.title == postFromCloud.title }) ?? false)
                    }
                    // Checking Cloud posts with the same ID to local App posts - do not append such posts from Cloud
                    let cloudPostsAfterCheckForUniqueID = cloudPostsAfterCheckForUniqueTitle.filter { postFromCloud in
                        !(self?.allPosts.contains(where: { $0.id == postFromCloud.id }) ?? false)
                    }
                    if !cloudPostsAfterCheckForUniqueID.isEmpty {
                        // Updating App posts
                        self?.allPosts.append(contentsOf: cloudPostsAfterCheckForUniqueID)
                        self?.savePosts()
                        self?.hapticManager.notification(type: .success)
                        self?.localLastUpdated = self?.getLatestDateFromPosts(posts: cloudPostsAfterCheckForUniqueID) ?? .now
                        
                        print("🍓 Successfully appended \(cloudPostsAfterCheckForUniqueID.count) posts from the cloud")
                    } else {
                        self?.hapticManager.impact(style: .light)
                        print("🍓☑️ No new posts from the cloud.")
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.showErrorMessageAlert = true
                    self?.hapticManager.notification(type: .error)
                    print("🍓❌ Cloud import error: \(error.localizedDescription)")
                }
                completion()
            }
        }
    }
    
    func getPostsFromBackup(url: URL, completion: @escaping (Int) -> Void) {
        
        self.errorMessage = nil
        self.showErrorMessageAlert = false
        var postsCount: Int = 0
        
        do {
            let jsonData = try Data(contentsOf: url)
            let posts = try JSONDecoder.appDecoder.decode([Post].self, from: jsonData)
            
            let postsCheckedForUnique = self.checkAndReturnUniquePosts(posts: posts)
            postsCount = postsCheckedForUnique.count
            self.allPosts.append(contentsOf: postsCheckedForUnique)
            self.hapticManager.notification(type: .success)
            print("🍓 Restore: Restored \(postsCount) posts from \(url.lastPathComponent)")
            
        } catch {
            self.errorMessage = error.localizedDescription
            self.showErrorMessageAlert = true
            self.hapticManager.notification(type: .error)
            print("🍓❌ Restore:Failed to load posts: \(error)")
        }
        
        completion(postsCount)
    }
    
    
    private func checkAndReturnUniquePosts(posts: [Post]) -> [Post] {
        
        // Checking posts with the same Title to local posts - do not append such posts from BackUp
        let existingTitlesInLocalPosts = Set(allPosts.map { $0.title })
        let postsAfterCheckForUniqueTitle = posts.filter { !existingTitlesInLocalPosts.contains($0.title) }
        
        // Checking posts with the same ID to local posts - do not append such posts from BackUp
        let existingIdInLocalPosts = Set(allPosts.map { $0.id })
        let postsAfterCheckForUniqueID = postsAfterCheckForUniqueTitle.filter { !existingIdInLocalPosts.contains($0.id) }
        
        return postsAfterCheckForUniqueID
    }
    
    /// Check for updates to available posts in the cloud.
    ///
    /// The resulting result is used to check and subsequently notify the user about the presence of posts updates in the cloud.
    ///
    /// ```
    /// checkCloudForUpdates() -> Void
    /// ```
    ///
    /// - Warning: This application is intended for self-study.
    /// - Returns: Returns a boolean result or error within completion handler.
    
    func checkCloudForUpdates(completion: @escaping (Bool) -> Void) {
        networkService.fetchDataFromURL() { (result: Result<[Post], Error>) in
            self.errorMessage = nil
            self.showErrorMessageAlert = false
            
            switch result {
            case .success(let cloudResponse):
                
                var hasUpdates = false
                let localPosts = self.allPosts.filter { $0.origin == .cloud }
                let cloudPosts = cloudResponse.filter { $0.origin == .cloud }
                
                if let theLatestDateInLocalPosts = self.getLatestDateFromPosts(posts: localPosts),
                   let theLatestDateInCloudPosts = self.getLatestDateFromPosts(posts: cloudPosts) {
                    hasUpdates = theLatestDateInLocalPosts < theLatestDateInCloudPosts
                }
                if hasUpdates {
                    print("🍓 checkCloudForUpdates: Posts update is available")
                    
                } else {
                    print("🍓☑️ checkCloudForUpdates: No Updates available")
                }
                DispatchQueue.main.async {
                    completion(hasUpdates)
                }
            case .failure (let error):
                self.errorMessage = error.localizedDescription
                self.showErrorMessageAlert = true
                self.hapticManager.notification(type: .error)
                
                DispatchQueue.main.async {
                    print("🍓❌ checkCloudForUpdates: Error \(error.localizedDescription)")
                    completion(false)
                }
            }
        }
    }
    
    private func getLatestDateFromPosts(posts: [Post]) -> Date? {
        
        guard !posts.isEmpty else { return nil }
        
        return posts.max(by: { $0.date < $1.date })?.date
        
    }
    
    /// Checking if a title of a new/editing post is unique not presenting in the current local posts.
    ///
    /// The result is used to avoid doublied titles in posts.
    ///
    /// ```
    /// checkNewPostForUniqueTitle() -> Bool
    /// ```
    ///
    /// - Warning: This application is intended for self-study.
    /// - Returns: Returns a boolean, true if a title of a post is unique and false if not.
    
    func checkNewPostForUniqueTitle(_ postTitle: String, editingPostId: String?) -> Bool {
        //        If there is a post with the same title and its id is not equal to excludingPostId, then the title is not unique
        return allPosts.contains(where: { $0.title == postTitle && $0.id != editingPostId })
        
        //        if allPosts.contains(where: { $0.title == postTitle && $0.id != excludingPostId }) {
        //            return true
        //        } else {
        //            return false
        //        }
        //        return allPosts.contains { post in
        //            post.title == postTitle && post.id != excludingPostId
        //        }
    }
    
    /// Checks all filters for their values.
    ///
    /// The result is used in different snip codes: in FilterButton to change its apearance in its parent UI, when filtering posts, etc.
    ///
    /// ```
    /// checkIfAllFilterAreEmpty() -> Bool
    /// ```
    ///
    /// - Warning: This application is intended for self-study.
    /// - Returns: Returns a boolean, true if all listed filters are set as not nil.
    ///
    func checkIfAllFiltersAreEmpty() -> Bool {
        // check if all filters are empty
        if /*selectedCategory == nil &&*/
            selectedLevel == nil &&
            selectedFavorite == nil &&
            selectedType == nil &&
            selectedYear == nil &&
            selectedSortOption == nil
        {
            return true
        } else {
            return false
        }
    }
    
    /// Gets a list of years presented in the local posts.
    ///
    /// The result is used in the FilterSheetView for selecting a year for the filter.
    ///
    /// ```
    /// getAllYears() -> [String]?
    /// ```
    ///
    /// - Warning: This application is intended for self-study.
    /// - Returns: Returns an array of strings with the values of years available in the current local posts.
    ///
    
    private func getAllYears() -> [String]? {
        
        let list = allPosts.compactMap({ (post) -> String? in
            if let date = post.postDate {
                let year = String(utcCalendar.component(.year, from: date))
                return year
            }
            return nil
        })
        
        let result = Array(Set(list)).sorted(by: {$0 < $1})
        print("🍓 VM(getAllYears): Final years list: \(result)")
        return result
    }
    
    // get a list of categories presented in the local posts
    
    private func getAllCategories() -> [String]? {
        
        let result = Array(Set(allPosts.map { $0.category })).sorted()
        print("🍓 VM(getAllCategories): Categories' list: \(result)")
        return result.isEmpty ? nil : result
    }
    
    
    func getPost(id: String) -> Post? {
        allPosts.first(where: {$0.id == id})
    }
    
}
