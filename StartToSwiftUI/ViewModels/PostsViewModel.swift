//
//  PostViewModel.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.08.2025.
//

import SwiftUI
import SwiftData
import Combine
import WidgetKit
import CoreData

@MainActor
final class PostsViewModel: ObservableObject {
    
    // MARK: - Properties
    private let dataSource: PostsDataSourceProtocol
    private let fileManager = JSONFileManager.shared
    private let hapticManager = HapticService.shared
    private let networkService: NetworkServiceProtocol
    
    @Published var allPosts: [Post] = []
    @Published var filteredPosts: [Post] = []
    @Published var selectedPostId: String? = nil
    @Published var searchText: String = ""
    @Published var isFiltersEmpty: Bool = true
    @Published var selectedRating: PostRating? = nil
    @Published var selectedStudyProgress: StudyProgress = .added
    
    @Published var errorMessage: String?
    @Published var showErrorMessageAlert = false
    
    private var cancellables = Set<AnyCancellable>()
    private var utcCalendar = Calendar.current
    
    var allYears: [String]? = nil
    var allCategories: [String]? = nil
    let mainCategory: String = "SwiftUI"
    var dispatchTime: DispatchTime { .now() + 1.5 }
    
    // MARK: - Computed Properties
    
    private var swiftDataSource: SwiftDataPostsDataSource? {
        dataSource as? SwiftDataPostsDataSource
    }
    private var appStateManager: AppSyncStateManager? {
        swiftDataSource.map { AppSyncStateManager(modelContext: $0.modelContext) }
    }
    private var isSwiftData: Bool {
        swiftDataSource != nil
    }
    
    // MARK: - AppStorage
    @AppStorage("selectedTheme") var selectedTheme: Theme = .system
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    
    // Filters
    @AppStorage("storedCategory") var storedCategory: String?
    @Published var selectedCategory: String? = nil {
        didSet { storedCategory = selectedCategory }}
    
    @AppStorage("storedLevel") var storedLevel: StudyLevel?
    @Published var selectedLevel: StudyLevel? = nil {
        didSet { storedLevel = selectedLevel }}
    
    @AppStorage("storedFavorite") var storedFavorite: FavoriteChoice?
    @Published var selectedFavorite: FavoriteChoice? = nil {
        didSet { storedFavorite = selectedFavorite }}
    
    @AppStorage("storedType") var storedType: PostType?
    @Published var selectedType: PostType? = nil {
        didSet { storedType = selectedType }}
    
    @AppStorage("storedPlatform") var storedPlatform: Platform?
    @Published var selectedPlatform: Platform? = nil {
        didSet { storedPlatform = selectedPlatform }}
    
    @AppStorage("storedYear") var storedYear: String?
    @Published var selectedYear: String? = nil {
        didSet { storedYear = selectedYear }}
    
    @AppStorage("storedSortOption") var storedSortOption: SortOption?
    @Published var selectedSortOption: SortOption? = nil {
        didSet { storedSortOption = selectedSortOption }}
        
    // MARK: - Init
    init(
        dataSource: PostsDataSourceProtocol,
        networkService: NetworkServiceProtocol = NetworkService(baseURL: Constants.cloudPostsURL)
    ) {
        self.dataSource = dataSource
        self.networkService = networkService
        
        setupTimezone()
        restoreFilters()
        loadPostsFromSwiftData()
        setupSubscriptions()
        updateWidgetData()
        
        Task {
            await initializeAppState()
        }
        
        // Subscribing to changes from CloudKit
        NotificationCenter.default.publisher(for: Notification.Name.NSPersistentStoreRemoteChange)
            .receive(on: DispatchQueue.main)
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main) // avoiding frequent updates
            .sink { [weak self] _ in
                self?.loadPostsFromSwiftData()
            }
            .store(in: &cancellables)
    }
    
    /// Convenience initialiser for backward compatibility
    convenience init(
        modelContext: ModelContext,
        networkService: NetworkServiceProtocol = NetworkService(baseURL: Constants.cloudPostsURL)
    ) {
        self.init(
            dataSource: SwiftDataPostsDataSource(modelContext: modelContext),
            networkService: networkService
        )
    }
    
    // MARK: - Setup
    
    private func setupTimezone() {
        if let utcTimeZone = TimeZone(secondsFromGMT: 0) {
            utcCalendar.timeZone = utcTimeZone
        }
    }
    
    private func restoreFilters() {
                
        selectedCategory = storedCategory
        selectedLevel = storedLevel
        selectedFavorite = storedFavorite
        selectedType = storedType
        selectedPlatform = storedPlatform
        selectedYear = storedYear
        selectedSortOption = storedSortOption
        isFiltersEmpty = checkIfAllFiltersAreEmpty()
    }
        
    private func initializeAppState() async {
        guard let appStateManager else {
            log("⚠️ init PostViewModel: dataSource is not SwiftData", level: .info)
            return
        }
        
        appStateManager.cleanupDuplicateAppStates()
        
        if await checkCloudCuratedPostsForUpdates() {
            appStateManager.setCuratedPostsLoadStatusOn()
        }
    }
        
    // MARK: - SwiftData Operations
    
    /// Loading posts from SwiftData
    func loadPostsFromSwiftData() {
        
        //        let callStack = Thread.callStackSymbols.joined(separator: "\n")
        //        log("📊 [CALL STACK] loadPostsFromSwiftData called from:\n\(callStack)", level: .debug)
        
        do {
            allPosts = try dataSource.fetchPosts()
            allYears = getAllYears()
            allCategories = getAllCategories()
            log("📊 Loaded \(allPosts.count) posts from SwiftData:", level: .debug)
            // DEBUG: Display all posts with ID
            //            for (index, post) in allPosts.enumerated() {
            //                log("📊 \(index + 1). ID: \(post.id), Title: \(post.title)", level: .debug)
            //            }
        } catch {
            handleError(error, message: "Error loading data")
        }
    }
    
    /// Adding a new post
    func addPost(_ newPost: Post) {
        dataSource.insert(newPost)
        saveContextAndReload()
    }
    
    func addPostIfNotExists(_ newPost: Post) -> Bool {
        // Check by ID
        if allPosts.contains(where: { $0.id == newPost.id || $0.title == newPost.title }) {
            log("❌ Post with ID \(newPost.id) or title already exists", level: .info)
            return false
        }
        
        dataSource.insert(newPost)
        saveContextAndReload()
        return true
    }
    
    /// If necessary, update post.origin .cloudNew with .cloud
    func updatePostOrigin(_ post: Post) {
        post.origin = .cloud
        saveContextAndReload()
    }
    /// Post update
    func updatePost() {
        saveContextAndReload()
    }
    
    /// Deleting a post
    func deletePost(_ post: Post?) {
        guard let post else {
            log("❌ Attempt to delete a nil post", level: .error)
            return
        }
        dataSource.delete(post)
        saveContextAndReload()
    }
    
    /// Deleting all posts
    func eraseAllPosts(_ completion: @escaping () -> ()) {
        if let swiftDataSource {
            do {
                // Deleting all posts
                try swiftDataSource.modelContext.delete(model: Post.self)
                saveContextAndReload()
            } catch {
                handleError(error, message: "Error deleting data")
            }
        } else {
            // For Mock simply clear the array
            allPosts = []
        }
        completion()
    }
    
    /// Toggle favorite flag
    func favoriteToggle(_ post: Post) {
        post.favoriteChoice = post.favoriteChoice == .yes ? .no : .yes
        saveContextAndReload()
    }
    
    /// Post rate
    func ratePost(_ post: Post) {
        post.postRating = selectedRating
        saveContextAndReload()
    }
    
    /// Udate post study progress
    func updatePostStudyProgress(_ post: Post) {
        post.progress = selectedStudyProgress
        
        switch selectedStudyProgress {
        case .added:
            post.startedDateStamp = nil
            post.studiedDateStamp = nil
            post.practicedDateStamp = nil
        case .started:
            post.startedDateStamp = .now
            post.studiedDateStamp = nil
            post.practicedDateStamp = nil
        case .studied:
            post.studiedDateStamp = .now
            post.practicedDateStamp = nil
        case .practiced:
            post.practicedDateStamp = .now
        }
        saveContextAndReload()
    }
    
    
    // MARK: - Cloud import of curated study materials
    
    func importPostsFromCloud(completion: @escaping () -> Void) async {
        
        clearError()
        
        let sourceName = isSwiftData ? "SwiftData" : "(Mock)"
        
        do {
            let cloudResponse: [CodablePost] = try await networkService.fetchDataFromURLAsync()
            log("☁️ Imported \(cloudResponse.count) posts from \(sourceName))", level: .info)
            
            // Filter unique posts by ID and title
            
            let newPosts = filterUniquePosts(from: cloudResponse)
            
            guard !newPosts.isEmpty else {
                hapticManager.impact(style: .light)
                log("ℹ️ No new posts from \(sourceName)", level: .info)
                completion()
                return
            }
            // Add new posts
            for post in newPosts {
                post.addedDateStamp = .now
                dataSource.insert(post)
            }
            saveContextAndReload()
            
            // SwiftData-specific logic (только для SwiftData)
            if let appStateManager {
                // Update the date of the last import of curated posts
                let latestDate = getLatestDateFromPosts(posts: allPosts) ?? .now
                appStateManager.setLastDateOfCuaratedPostsLoaded(latestDate)
                // As a result of importing curated posts - no new materials -> false
                appStateManager.setCuratedPostsLoadStatusOff()
            }
            
            hapticManager.notification(type: .success)
            log("✅ Added \(newPosts.count) new posts from \(sourceName)", level: .info)
            
        } catch {
            handleError(error, message: "Import error from \(sourceName)")
        }
        completion()
    }
    
    /// Check for updates to available posts in the cloud.
    ///
    /// The resulting result is used to check and subsequently notify the user about the presence of posts updates in the cloud.
    ///
    /// ```
    /// checkCloudCuratedPostsForUpdates(completion: @escaping (Bool) -> Void)
    /// ```
    ///
    /// - Warning: This application is intended for self-study.
    /// - Returns: Returns a boolean result or error within completion handler.
    ///
    func checkCloudCuratedPostsForUpdates() async -> Bool {
        
        clearError()
        
        do {
            let cloudResponse: [CodablePost] = try await networkService.fetchDataFromURLAsync()
            let localPosts = self.allPosts.filter { $0.origin == .cloud || $0.origin == .cloudNew }
            let cloudPosts = cloudResponse
                .filter { $0.origin == .cloudNew }
                .map { PostMigrationHelper.convertFromCodable($0) }
            
            var hasUpdates: Bool
            
            if let latestLocalDate = self.getLatestDateFromPosts(posts: localPosts),
               let latestCloudDate = self.getLatestDateFromPosts(posts: cloudPosts) {
                hasUpdates = latestLocalDate < latestCloudDate
            } else {
                hasUpdates = localPosts.isEmpty && !cloudPosts.isEmpty
            }
            log("🍓 checkCloudForUpdates: \(hasUpdates ? "Updates available" : "No updates")", level: .debug)
            return hasUpdates
            
        } catch {
            handleError(error, message: "checkCloudForUpdates error")
            return false
        }
    }
    
    // MARK: - Backup & Restore
    
    func getFilePath(fileName: String) -> Result<URL, FileStorageError> {
        guard fileName == Constants.localPostsFileName else {
            return .failure(.fileNotFound)
        }
        
        log("🍓FM(getFilePath): Exporting from SwiftData...", level: .info)
        
        switch exportPostsToJSON() {
        case .success(let url):
            log("🍓FM(getFilePath): Successfully got file url: \(url).", level: .info)
            return .success(url)
        case .failure(let error):
            return .failure(.exportError(error.localizedDescription))
        }
    }
    
    func getPostsFromBackup(url: URL, completion: @escaping (Int) -> Void) {
        
        clearError()
        
        do {
            // 1. Reading JSON data
            let jsonData = try Data(contentsOf: url)
            // 2. Decode to [CodablePost] (not [Post])
            let codablePosts = try JSONDecoder.appDecoder.decode([CodablePost].self, from: jsonData)
            // 3. Convert to SwiftData Post via PostMigrationHelper
            let posts = codablePosts.map { PostMigrationHelper.convertFromCodable($0) }
            // 4. Check for uniqueness and add it to SwiftData
            let uniquePosts = filterUniquePosts(posts)
            
            guard !uniquePosts.isEmpty else {
                completion(0)
                return
            }
            // 5. Save into SwiftData
            for post in uniquePosts {
                dataSource.insert(post)
            }
            // 6. Save the context and update the UI
            saveContextAndReload()
            
            hapticManager.notification(type: .success)
            log("🍓 Restore: Restored \(uniquePosts.count) posts from \(url.lastPathComponent)", level: .info)
            completion(uniquePosts.count)
            
        } catch {
            handleError(error, message: "Failed to load posts")
            completion(0)
        }
    }
    
    func exportPostsToJSON() -> Result<URL, Error> {
        log("🍓 Exporting \(allPosts.count) posts from SwiftData", level: .info)
        
        // Convert Post to CodablePost
        let codablePosts = allPosts.map { CodablePost(from: $0) }
        
        // Create a unique file name with the date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm"
        let fileName = "StartToSwiftUI_backup_\(dateFormatter.string(from: Date())).json"
        
        // Use fileManager to export
        let result = fileManager.exportToTemporary(codablePosts, fileName: fileName)
        
        switch result {
        case .success(let url):
            log("🍓✅ Exported to: \(url.lastPathComponent)", level: .info)
            return .success(url)
        case .failure(let error):
            handleError(error, message: "Export failed")
            return .failure(error)
        }
    }

    // MARK: - Filtering & Searching
    
    private func setupSubscriptions() {
        
        let filters = $selectedLevel
            .combineLatest($selectedFavorite, $selectedType, $selectedYear)
        
        let filtersWithPlatformAndSortOption = filters
            .combineLatest($selectedPlatform, $selectedSortOption, $selectedCategory)
        
        let debouncedSearchText = $searchText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
        
        $allPosts
            .combineLatest(debouncedSearchText, filtersWithPlatformAndSortOption)
            .map { [weak self] posts, searchText, data -> [Post] in
                
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
                
                return self.searchPosts(posts: filtered)
                
//                return self.applySorting(posts: searchedPosts, option: sortOption)
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
        selectedYear == nil
//        selectedSortOption == nil
//        selectedCategory == nil
    }
    
    private func searchPosts(posts: [Post]) -> [Post] {
        guard !searchText.isEmpty else { return posts}
        
        let query = searchText.lowercased()
        return posts.filter {
            $0.title.lowercased().contains(query) ||
            $0.intro.lowercased().contains(query) ||
            $0.author.lowercased().contains(query) ||
            $0.notes.lowercased().contains(query)
        }
    }
    
//    private func applySorting(posts: [Post], option: SortOption?) -> [Post] {
//        
//        // If nil - return unsorded (original order in array)
//        guard let option else { return posts}
//        
//        // posts with postDate = nil are always at the end
//        switch option {
//        case .random:
//            return posts.shuffled() // random shuffle
//        case .newestFirst:
//            return posts.sorted {
//                switch ($0.postDate, $1.postDate) {
//                case (let date1?, let date2?): return date1 > date2 // Newest first
//                case (nil, _): return false // postDate = nil are always at the end
//                case (_, nil): return true // postDate ≠ nil are always before nil
//                }
//            }
//        case .oldestFirst:
//            return posts.sorted {
//                switch ($0.postDate, $1.postDate) {
//                case (let date1?, let date2?): return date1 < date2 // Oldest first
//                case (nil, _): return false // postDate = nil are always at the end
//                case (_, nil): return true // postDate ≠ nil are always before nil
//                }
//            }
//        }
//    }
    
    // MARK: - Helper Methods
    
    func getPost(id: String) -> Post? {
        allPosts.first { $0.id == id }
    }
    
    /// Save context and reload UI
    private func saveContextAndReload() {
        do {
            try dataSource.save()
            // Updating data for the UI
            loadPostsFromSwiftData()
            // Update widget data
            updateWidgetData()
        } catch {
            handleError(error, message: "Error saving data")
        }
    }
    
    /// Checking if a title of a new/editing post is unique not presenting in the current local posts.
    ///
    /// The result is used to avoid doublied titles in posts.
    ///
    /// ```
    /// checkNewPostForUniqueTitle(_ postTitle: String, editingPostId: String?) -> Bool
    /// ```
    ///
    /// - Warning: This application is intended for self-study.
    /// - Returns: Returns a boolean, true if a title of a post is unique and false if not.
    
    func checkNewPostForUniqueTitle(_ postTitle: String, editingPostId: String?) -> Bool {
        // If there is a post with the same title and its id is not equal to excludingPostId, then the title is not unique
        allPosts.contains(where: { $0.title == postTitle && $0.id != editingPostId })
    }
    
    private func filterUniquePosts(from cloudResponse: [CodablePost]) -> [Post] {
        let existingTitles = Set(allPosts.map { $0.title })
        let existingIds = Set(allPosts.map { $0.id })
        
        return cloudResponse
            .filter { !existingTitles.contains($0.title) && !existingIds.contains($0.id) }
            .map { PostMigrationHelper.convertFromCodable($0) }
    }
    
    private func filterUniquePosts(_ posts: [Post]) -> [Post] {
        let existingTitles = Set(allPosts.map { $0.title })
        let existingIds = Set(allPosts.map { $0.id })
        
        return posts.filter { !existingTitles.contains($0.title) && !existingIds.contains($0.id) }
    }
    
    private func getLatestDateFromPosts(posts: [Post]) -> Date? {
        posts.max { $0.date < $1.date }?.date
    }
    
    private func getAllYears() -> [String]? {
        let years = allPosts.compactMap { post -> String? in
            post.postDate.map { String(utcCalendar.component(.year, from: $0)) }
        }
        let unique = Array(Set(years)).sorted()
        return unique.isEmpty ? nil : unique
    }
    
    private func getAllCategories() -> [String]? {
        let categories = Array(Set(allPosts.map { $0.category })).sorted()
        return categories.isEmpty ? nil : categories
    }
    
    private func clearError() {
        errorMessage = nil
        showErrorMessageAlert = false
    }
    
    private func handleError(_ error: Error?, message: String) {
        let description = error?.localizedDescription ?? message
        errorMessage = description
        showErrorMessageAlert = true
        hapticManager.notification(type: .error)
        log("❌ \(message): \(description)", level: .error)
    }
    
    // MARK: - Computed Properties for Preferences
    
    var drafts: [Post] {
        allPosts.filter { $0.draft == true }
    }
    
    var draftsCount: Int {
        allPosts.filter { $0.draft }.count
    }
    
    var hasDrafts: Bool {
        allPosts.contains { $0.draft }
    }
    
    var cloudPostsCount: Int {
        allPosts.filter { $0.origin == .cloud || $0.origin == .cloudNew }.count
    }
    
    var hasCloudPosts: Bool {
        allPosts.contains { $0.origin == .cloud || $0.origin == .cloudNew}
    }
    
    var hasAvailableCuratedPostsUpdate: Bool {
        guard let appStateManager else { return false }
        return appStateManager.getAvailableNewCuratedPostsStatus() && hasCloudPosts
    }
    
    var shouldShowImportFromCloud: Bool {
        !hasCloudPosts
    }
    
    // MARK: - Curated Posts State
    
    var lastCuratedPostsLoadedDate: Date? {
        appStateManager?.getLastDateOfCuaratedPostsLoaded()
    }
    
    // MARK: - DevData Import (creating posts for cloud)
    /// Loading DevData to generate JSON (for internal use)
    func loadDevData() async -> Int {
        let newPosts = filterUniquePosts(DevData.postsForCloud)
        
        guard !newPosts.isEmpty else {
            log("⚠️ DevData: No new unique posts to add", level: .info)
            return 0
        }
        
        for post in newPosts {
            dataSource.insert(post)
        }
        
        saveContextAndReload()
        log("✅ DevData: Loaded \(newPosts.count) posts from \(DevData.postsForCloud.count)", level: .info)
        
        return newPosts.count
    }
    
    func resetCuratedPostsStatus() {
        appStateManager?.setCuratedPostsLoadStatusOn()
    }
    
    // MARK: MARK: - Widget Data Update
    /// Updates widget with current study progress data
    /// Call this method when posts are added, deleted, or progress changes
    func updateWidgetData() {
        let posts = allPosts.filter { !$0.draft }
        
        let added = posts.filter { $0.addedDateStamp != nil }.count
        let started = posts.filter { $0.startedDateStamp != nil }.count
        let studied = posts.filter { $0.studiedDateStamp != nil }.count
        let practiced = posts.filter { $0.practicedDateStamp != nil }.count
        
        let data = StudyProgressData(
            freshCount: added,
            startedCount: started,
            studiedCount: studied,
            practicedCount: practiced,
            lastUpdated: Date()
        )

        WidgetDataManager.shared.saveProgressData(data)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
