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
    let dataSource: PostsDataSourceProtocol
    let fileManager = JSONFileManager.shared
    let hapticManager = HapticService.shared
    let networkService: NetworkServiceProtocol
    let appStateManager: AppSyncStateManager?

    @Published var allPosts: [Post] = []
    @Published var filteredPosts: [Post] = []
    @Published var selectedPostId: String? = nil
    @Published var searchText: String = ""
    @Published var isFiltersEmpty: Bool = true
    @Published var selectedRating: PostRating? = nil
    @Published var selectedStudyProgress: StudyProgress = .added
    
    @Published var errorMessage: String?
    @Published var showErrorMessageAlert = false
    
    let mainCategory: String = Constants.mainCategory
    
    var cancellables = Set<AnyCancellable>()
    var utcCalendar = Calendar.current
    var allYears: [String]? = nil
    var allCategories: [String]? = nil
    var dispatchTime: DispatchTime { .now() + 1.5 }
    var dispatchFor: Double = 1.5
    
    private var lastLoadTime: Date = .distantPast
    private let minLoadInterval: TimeInterval = 3

    // MARK: - Computed Properties
    var swiftDataSource: SwiftDataPostsDataSource? {
        dataSource as? SwiftDataPostsDataSource
    }
    var isSwiftData: Bool {
        swiftDataSource != nil
    }
    
    // MARK: - AppStorage
    @AppStorage("selectedTheme") var selectedTheme: Theme = .system
    
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
    
    @AppStorage("storedSortOption") var storedSortOption: SortOption = .notSorted
    @Published var selectedSortOption: SortOption = .notSorted {
        didSet { storedSortOption = selectedSortOption }}
        
    // MARK: - Init
    init(
        dataSource: PostsDataSourceProtocol,
        networkService: NetworkServiceProtocol = NetworkService(urlString: Constants.cloudPostsURL)
    ) {
        self.dataSource = dataSource
        self.networkService = networkService
        
        if let swiftDataSource = dataSource as? SwiftDataPostsDataSource {
            self.appStateManager = AppSyncStateManager(modelContext: swiftDataSource.modelContext)
        } else {
            self.appStateManager = nil
        }

        setupTimezone()
        restoreFilters()
    }
    /// Convenience initialiser for backward compatibility
    convenience init(
        modelContext: ModelContext,
        networkService: NetworkServiceProtocol = NetworkService(urlString: Constants.cloudPostsURL)
    ) {
        self.init(
            dataSource: SwiftDataPostsDataSource(modelContext: modelContext),
            networkService: networkService
        )
    }
    
    
    func start() {
        setupSubscriptions()
        setupSubscriptionForChangesInCloud()
        loadPostsFromSwiftData()

        Task { [weak self] in
            guard let self else { return }
            await self.initializeAppState()
        }
    }
    
    // MARK: - Setup
    private func setupTimezone() {
        if let utcTimeZone = TimeZone(secondsFromGMT: 0) {
            utcCalendar.timeZone = utcTimeZone
        }
    }
    
    // MARK: - CloudKit Sync
    private func setupSubscriptionForChangesInCloud() {
        NotificationCenter.default.publisher(for: Notification.Name.NSPersistentStoreRemoteChange)
            .receive(on: DispatchQueue.main)
            .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                let now = Date()
                guard now.timeIntervalSince(self.lastLoadTime) >= self.minLoadInterval else {
                    log("Cloud sync skipped (too soon)", level: .debug)
                    return
                }
                self.loadPostsFromSwiftData()
                log("Cloud posts sync subscription run", level: .info)
            }
            .store(in: &cancellables)
    }
    
    func restoreFilters() {
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
        // To folow the next order in important
        /* Step1:
        Ensure AppState exists (creates with appFirstLaunchDate if first launch).
        Search for AppSyncState in SwiftData - it guarantees the existence of the AppState:
        - The first launch will not find it, it will create a new one with appFirstLaunchDate = Date() and save it to the database.
        - Restart — it will find an existing one and return it.
        */
        _ = appStateManager.getOrCreateAppState()
        
        /* Step2:
        Clean dublicates if any. iCloud sync can create multiple appsyncstates on different devices.
        This function finds duplicates, merges their data into one (the oldest), and deletes the rest.
         */
        appStateManager.cleanupDuplicateAppStates()
        
        /* Step 3:
        Compare the dates of local and cloud posts.
        If there are new materials in the cloud, it sets the isNewCuratedPostsAvailable -> true
        */
        if await checkCloudCuratedPostsForUpdates() {
            appStateManager.setCuratedPostsLoadStatusOn()
        }
    }
        
    // MARK: - SwiftData Operations
    
    /// Load posts from SwiftData
    func loadPostsFromSwiftData() {
        
        lastLoadTime = Date()
        
        do {
            allPosts = try dataSource.fetchPosts()
            removeDuplicatePosts()
            allYears = getAllYears()
            allCategories = getAllCategories()
            log("📊 Loaded \(allPosts.count) posts from SwiftData:", level: .debug)
        } catch {
            handleError(error, message: "Error loading data")
        }
    }
    
    /// Remove Duplicate Posts
    private func removeDuplicatePosts() {
        var postsToDelete: [Post] = []
        
        // Pass 1: duplicates by ID
        let idGroups = Dictionary(grouping: allPosts, by: \.id)
            .filter { $0.value.count > 1 }
        
        /* persistentModelID is a unique internal identifier of SwiftData, which each @Model object receives automatically. It is unique even if your id and title are the same */
        for (id, postsList) in idGroups {
            if let postToKeep = postsList.sorted(by: { $0.date < $1.date }).first {
                for post in postsList where post.persistentModelID != postToKeep.persistentModelID {
                    postsToDelete.append(post)
                    log("🗑️ Duplicate by ID \(id): '\(post.title)'", level: .info)
                }
            }
        }
        
        // Pass 2: duplicates by title
        /* Avoid double processing of posts */
        let markedIDs = Set(postsToDelete.map { $0.persistentModelID })
        /* Leave only those posts that have not been marked for deletion in Pass 1. This is important, otherwise the deleted duplicate by ID could also end up in the duplicate group by title */
        let remainingPosts = allPosts.filter { !markedIDs.contains($0.persistentModelID) }
        /* Grouping the remaining ones by title */
        let titleGroups = Dictionary(grouping: remainingPosts, by: \.title)
            .filter { $0.value.count > 1 }
        /* Leave the oldest in each group: title is the key, postsList is an array of duplicates */
        for (title, postsList) in titleGroups {
            if let postToKeep = postsList.sorted(by: { $0.date < $1.date }).first {
                for post in postsList where post.persistentModelID != postToKeep.persistentModelID {
                    postsToDelete.append(post)
                    log("🗑️ Duplicate by title '\(title)'", level: .info)
                }
            }
        }
        
        guard !postsToDelete.isEmpty else { return }
        
        for post in postsToDelete {
            dataSource.delete(post)
        }
        
        do {
            try dataSource.save()
            allPosts = try dataSource.fetchPosts()
            log("✅ Removed \(postsToDelete.count) duplicate posts", level: .info)
        } catch {
            handleError(error, message: "Error removing duplicate posts")
        }
    }

    /// Add a new post
    func addPost(_ newPost: Post) {
        dataSource.insert(newPost)
        saveContextAndReload()
    }
    
    func addPostIfNotExists(_ newPost: Post) -> Bool {
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
    
    /// Delete a post
    func deletePost(_ post: Post?) {
        guard let post else {
            log("❌ Attempt to delete a nil post", level: .error)
            return
        }
        dataSource.delete(post)
        saveContextAndReload()
    }
    
    /// Delete all posts
    func eraseAllPosts(_ completion: @escaping () -> ()) {
        if let swiftDataSource {
            do {
                try swiftDataSource.modelContext.delete(model: Post.self)
                saveContextAndReload()
            } catch {
                handleError(error, message: "Error deleting data")
            }
        } else {
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
    
    /// Update post study progress
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
    
    // MARK: - Helper Methods
    
    func getPost(id: String) -> Post? {
        allPosts.first { $0.id == id }
    }
    
    /// Save context and reload UI
    func saveContextAndReload() {
        do {
            try dataSource.save()
            loadPostsFromSwiftData()
            updateWidgetData()
        } catch {
            handleError(error, message: "Error saving data")
        }
    }
    
    func checkNewPostForUniqueTitle(_ postTitle: String, editingPostId: String?) -> Bool {
        allPosts.contains(where: { $0.title == postTitle && $0.id != editingPostId })
    }
    
    func filterUniquePosts(from cloudResponse: [CodablePost]) -> [Post] {
        let existingTitles = Set(allPosts.map { $0.title })
        let existingIds = Set(allPosts.map { $0.id })
        
        return cloudResponse
            .filter { !existingTitles.contains($0.title) && !existingIds.contains($0.id) }
            .map { PostMigrationHelper.convertFromCodable($0) }
    }
    
    func filterUniquePosts(_ posts: [Post]) -> [Post] {
        let existingTitles = Set(allPosts.map { $0.title })
        let existingIds = Set(allPosts.map { $0.id })
        
        return posts.filter { !existingTitles.contains($0.title) && !existingIds.contains($0.id) }
    }
    
    func getLatestDateFromPosts(posts: [Post]) -> Date? {
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
    
    func clearError() {
        errorMessage = nil
        showErrorMessageAlert = false
    }
    
    func handleError(_ error: Error?, message: String) {
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
    
    func resetCuratedPostsStatus() {
        appStateManager?.setCuratedPostsLoadStatusOn()
    }
}
