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
    
    @Published var allPosts: [Post] = []
    @Published var filteredPosts: [Post] = []
    @Published var selectedPostId: String? = nil
    @Published var searchText: String = ""
    @Published var isFiltersEmpty: Bool = true
    @Published var selectedRating: PostRating? = nil
    @Published var selectedStudyProgress: StudyProgress = .added
    
    @Published var errorMessage: String?
    @Published var showErrorMessageAlert = false
    
    var cancellables = Set<AnyCancellable>()
    var utcCalendar = Calendar.current
    
    var allYears: [String]? = nil
    var allCategories: [String]? = nil
    let mainCategory: String = Constants.mainCategory
    var dispatchTime: DispatchTime { .now() + 1.5 }
    var dispatchFor: Double = 1.5

    
    // MARK: - Computed Properties
    var swiftDataSource: SwiftDataPostsDataSource? {
        dataSource as? SwiftDataPostsDataSource
    }
    var appStateManager: AppSyncStateManager? {
        swiftDataSource.map { AppSyncStateManager(modelContext: $0.modelContext) }
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
    
    @AppStorage("storedSortOption") var storedSortOption: SortOption = .newestFirst
    @Published var selectedSortOption: SortOption = .newestFirst {
        didSet { storedSortOption = selectedSortOption }}
        
    // MARK: - Init
    init(
        dataSource: PostsDataSourceProtocol,
        networkService: NetworkServiceProtocol = NetworkService(urlString: Constants.cloudPostsURL)
    ) {
        self.dataSource = dataSource
        self.networkService = networkService
        
        setupTimezone()
        restoreFilters()
        setupSubscriptions()
        setupSubscriptionForChangesInCloud()
        Task {
            await initializeAppState()
        }
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
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadPostsFromSwiftData()
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
        
        appStateManager.cleanupDuplicateAppStates()
        
        if await checkCloudCuratedPostsForUpdates() {
            appStateManager.setCuratedPostsLoadStatusOn()
        }
    }
        
    // MARK: - SwiftData Operations
    
    /// Loading posts from SwiftData
    func loadPostsFromSwiftData() {
        do {
            allPosts = try dataSource.fetchPosts()
            allYears = getAllYears()
            allCategories = getAllCategories()
            log("📊 Loaded \(allPosts.count) posts from SwiftData:", level: .debug)
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

    #warning("Delete this func loadDevData() before deployment to App Store")
    // MARK: - DevData Import (creating posts for cloud)
    func loadDevData() -> Int {
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
}
