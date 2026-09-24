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
    let fileManager: JSONFileManager
    let hapticManager = HapticManager.shared
    let appStateManager: AppSyncStateManagerProtocol?
    let fbPostsManager: FBPostsManagerProtocol
    let errorManager: ErrorManager
    let crashManager: FBCrashManager
    let performanceManager: FBPerformanceManager
    let analyticsManager: FBAnalyticsManager

    @Published var allPosts: [Post] = []
    @Published var filteredPosts: [Post] = []
    @Published var selectedPost: Post? = nil
    @Published var searchText: String = ""
    @Published var isFiltersEmpty: Bool = true
    @Published var selectedRating: PostRating? = nil
    @Published var selectedStudyProgress: StudyProgress = .added
    @Published var reshuffleToken = UUID()
      
    var cancellables = Set<AnyCancellable>()
    var utcCalendar = Calendar.current
    
    var allYears: [String]? = nil
    var randomSortOrder: [String] = []
    var dispatchTime: DispatchTime { .now() + 1.5 }
    
    private var lastLoadTime: Date = Date(timeIntervalSince1970: 0)
    private let minLoadInterval: TimeInterval = 3
    private var pendingCloudUpdate = false
    private var isStarted = false

    // Защита от повторного входа: если запрос уже выполняется, пропускаем
    // новый — он всё равно спросит Firebase о том же диапазоне дат и не
    // найдёт ничего нового сверх уже идущего запроса.
    // Не `private`, т.к. методы, которые их используют, объявлены в
    // extension-файле PostsViewModel+FBImport.swift.
    var isImportingPosts = false
    var isCheckingPostsForUpdates = false
    
    // MARK: - Computed Properties
    var swiftDataSource: SwiftDataPostsDataSource? {
        dataSource as? SwiftDataPostsDataSource
    }
    var isSwiftData: Bool {
        swiftDataSource != nil
    }
    
    // MARK: - AppStorage
    @AppStorage("shimmerWaveEnabled") var shimmerWaveEnabled = true
    @AppStorage("selectedTheme") var selectedTheme: Theme = .system
    
    // Filters
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
        didSet {
            storedSortOption = selectedSortOption
            if selectedSortOption == .random {
                reshufflePosts()
            }
        }
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
    
    var hasDeleted: Bool {
        allPosts.contains { $0.status == .deleted }
    }
    
    var deletedCount: Int {
        allPosts.filter { $0.status == .deleted }.count
    }

    var cloudPostsCount: Int {
        allPosts.filter { $0.origin == .cloud || $0.origin == .cloudNew }.count
    }
    
    var hasCloudPosts: Bool {
        allPosts.contains { $0.origin == .cloud || $0.origin == .cloudNew}
    }
        
    var shouldShowImportFromCloud: Bool {
        !hasCloudPosts
    }
    
    // MARK: - Curated Posts State
    
    var lastDatePostsLoaded: Date? {
        appStateManager?.getLastDateOfPostsLoaded()
    }

    // MARK: - Init
    init(
        dataSource: PostsDataSourceProtocol,
        appStateManager: AppSyncStateManagerProtocol? = nil,
        fbPostsManager: FBPostsManagerProtocol,
        services: AppServiceDependencies
    ) {
        self.dataSource = dataSource
        self.appStateManager = appStateManager
        self.fbPostsManager = fbPostsManager
        self.errorManager = services.errorManager
        self.fileManager = services.fileManager
        self.crashManager = services.crashManager
        self.performanceManager = services.performanceManager
        self.analyticsManager = services.analyticsManager

        setupTimezone()
        restorePostFilters()
    }
    /// Convenience initialiser for backward compatibility
    convenience init(
        modelContext: ModelContext,
        appStateManager: AppSyncStateManagerProtocol? = nil,
        fbPostsManager: FBPostsManagerProtocol,
        services: AppServiceDependencies
    ) {
        self.init(
            dataSource: SwiftDataPostsDataSource(modelContext: modelContext),
            appStateManager: appStateManager,
            fbPostsManager: fbPostsManager,
            services: services
        )
    }
    
    // MARK: - Setup for Posts
    func start() {
        guard !isStarted else {
            log("⚠️ PostsViewModel.start() called again — skipped", level: .debug)
            return
        }
        isStarted = true
        setupSubscriptions()
        setupSubscriptionForChangesInCloud()
    }

    private func setupTimezone() {
        if let utcTimeZone = TimeZone(secondsFromGMT: 0) {
            utcCalendar.timeZone = utcTimeZone
        }
    }
    
    // MARK: - CloudKit Sync
    private func setupSubscriptionForChangesInCloud() {
        NotificationCenter.default.publisher(for: Notification.Name.NSPersistentStoreRemoteChange)
            .debounce(for: .seconds(2), scheduler: DispatchQueue.global(qos: .utility))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                let now = Date()
                
                guard now.timeIntervalSince(self.lastLoadTime) >= self.minLoadInterval else {
                    self.pendingCloudUpdate = true
                    log("Cloud sync skipped (too soon) — marked as pending", level: .debug)
                    
                    // ✅ Современный способ — Task вместо DispatchQueue
                    Task { [weak self] in
                        try? await Task.sleep(for: .seconds(self?.minLoadInterval ?? 3))
                        guard let self, self.pendingCloudUpdate else { return }
                        self.pendingCloudUpdate = false
                        self.loadPostsFromSwiftData(removeDuplicates: false)
                        log("Cloud sync: pending update executed", level: .info)
                    }
                    return
                }

                self.pendingCloudUpdate = false
                self.loadPostsFromSwiftData(removeDuplicates: false)
                log("Cloud posts sync subscription run", level: .info)
            }
            .store(in: &cancellables)
    }

    func restorePostFilters() {
        selectedLevel = storedLevel
        selectedFavorite = storedFavorite
        selectedType = storedType
        selectedPlatform = storedPlatform
        selectedYear = storedYear
        selectedSortOption = storedSortOption
        isFiltersEmpty = checkIfAllFiltersAreEmpty()
    }
                
    // MARK: - SwiftData Operations
    
    /// Load posts from SwiftData
    func loadPostsFromSwiftData(removeDuplicates: Bool = true) {
        let trace = performanceManager.startTrace(name: "load_posts_swiftdata")
        lastLoadTime = Date()
        
        do {
            allPosts = try dataSource.fetchPosts()
            crashManager.addLog("loadPostsFromSwiftData: loaded local posts: \(allPosts.count)")
            
            if removeDuplicates {
                removeDuplicatePosts()
            }
            
            // migrating post status scheem from active → hidden → deleted → erase to active → deleted → erase.
            migrateHiddenToDeleted(removeDuplicates: removeDuplicates)
            
            crashManager.addLog("loadPostsFromSwiftData: posts count after check for duplicates: \(allPosts.count)")
            allYears = getAllYears()
            crashManager.setUserContext(allPosts.count, hasCloudPosts)
            log("📊 Loaded \(allPosts.count) posts from SwiftData:", level: .debug)
        } catch {
            crashManager.sendNonFatal(error)
            handleError(error, message: "Error loading data")
        }
        performanceManager.stopTrace(trace)
    }

    /// Remove Duplicate Posts
    private func removeDuplicatePosts() {
        var postsToDelete: [Post] = []
        
        // Pass 1: duplicates by ID
        let idGroups = Dictionary(grouping: allPosts, by: \.id)
            .filter { $0.value.count > 1 }
        
        /* persistentModelID is a unique internal identifier of SwiftData, which each @Model object receives automatically. It is unique even if your id and title are the same */
        for (id, postsList) in idGroups {
            if let postToKeep = postsList.sorted(by: { $0.date > $1.date }).first {
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
        
        crashManager.addLog("removeDuplicatePosts: found \(postsToDelete.count) duplicates")

        for post in postsToDelete {
            dataSource.delete(post)
        }
        
        do {
            try dataSource.save()
            allPosts = try dataSource.fetchPosts()
            log("Removed \(postsToDelete.count) duplicate posts", level: .info)
        } catch {
            crashManager.sendNonFatal(error)
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
            log("Post with ID \(newPost.id) or title already exists", level: .error)
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
    
    /// Managing post.status
    func setPostActive(_ post: Post) {
        post.status = .active
        saveContextAndReload()
    }

    func setPostDeleted(_ post: Post) {
        post.status = .deleted
        saveContextAndReload()
    }

    /// Erase a post
    func erasePost(_ post: Post?) {
        guard let post else {
            log("Attempt to delete a nil post", level: .error)
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
                crashManager.sendNonFatal(error)
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
        if post.favoriteChoice == .yes {
            analyticsManager.logEvent(name: "post_favorited")
        }
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
        analyticsManager.logEvent(name: "study_progress_changed", params: ["progress": selectedStudyProgress.rawValue])
        saveContextAndReload()
    }
    
    // MARK: - Helper Methods
    
    func getPost(id: String) -> Post? {
        allPosts.first { $0.id == id }
    }
    
    /// Save context and reload UI
    func saveContextAndReload(removeDuplicates: Bool = true) {
        do {
            try dataSource.save()
            loadPostsFromSwiftData(removeDuplicates: removeDuplicates)
            updateWidgetData()
        } catch {
            crashManager.sendNonFatal(error)
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
    
    func filterUniquePosts(from fbResponse: [FBPostModel]) -> [FBPostModel] {
        let existingTitles = Set(allPosts.map { $0.title })
        let existingIds = Set(allPosts.map { $0.id })
        
        return fbResponse
            .filter { !existingTitles.contains($0.title) && !existingIds.contains($0.postId) }
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
    
    // MARK: - Handle Errors
    func clearError() {
        errorManager.clear()
    }

    func handleError(_ error: Error?, message: String) {
        hapticManager.notification(type: .error)
        errorManager.handle(error, message: message)
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
            let datePrefix = DateFormatter.yyyyMMdd.string(from: post.date)
            let trimmedUUID = String(post.id.suffix(from: post.id.index(post.id.startIndex, offsetBy: 11)))
            post.id = "\(datePrefix)_\(trimmedUUID)"
            dataSource.insert(post)
        }
        
        saveContextAndReload()
        log("✅ DevData: Loaded \(newPosts.count) posts from \(DevData.postsForCloud.count)", level: .info)
        
        return newPosts.count
    }
}
