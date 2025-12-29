//
//  PostViewModel.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.08.2025.
//

import SwiftUI
import SwiftData
import Combine

@MainActor
class PostsViewModel: ObservableObject {
    
    // MARK: - Properties
    
    private let modelContext: ModelContext

    // Load static posts trigger - tied to AppStateManager, used only in Toggle in Preferences
    @AppStorage("shouldLoadStaticPosts") var shouldLoadStaticPosts: Bool = true {
        didSet {
            log("🔄 shouldLoadStaticPosts изменился: \(shouldLoadStaticPosts)", level: .info)
            let appStateManager = AppSyncStateManager(modelContext: modelContext)
            
            switch shouldLoadStaticPosts {
            case true:
                appStateManager.setShouldLoadStaticPostsOn()
            case false:
                appStateManager.setShouldLoadStaticPostsOff()
            }
        }
    }

    private let fileManager = JSONFileManager.shared
    private let hapticManager = HapticService.shared
    private let networkService: NetworkService
    
    @Published var allPosts: [Post] = []
    @Published var filteredPosts: [Post] = []
    @Published var selectedPostId: String? = nil
    @Published var searchText: String = ""
    @Published var isFiltersEmpty: Bool = true
    @Published var selectedRating: PostRating? = nil
    @Published var selectedStudyProgress: StudyProgress = .fresh
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var errorMessage: String?
    @Published var showErrorMessageAlert = false
    
    private var utcCalendar = Calendar.current
    
    var allYears: [String]? = nil
    var allCategories: [String]? = nil
    let mainCategory: String = "SwiftUI"
    var dispatchTime: DispatchTime { .now() + 1.5 }
    
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
    @AppStorage("storedSortOption") var storedSortOption: SortOption?
    @Published var selectedSortOption: SortOption? = nil {
        didSet { storedSortOption = selectedSortOption }}
    
    @Published var isTermsOfUseAccepted: Bool = false
    
    // Set Terms Of Use accepted
    func acceptTermsOfUse() {
        let appStateManager = AppSyncStateManager(modelContext: modelContext)
        appStateManager.acceptTermsOfUse()
        isTermsOfUseAccepted = true
        objectWillChange.send()
    }

    // MARK: - Init
    init(
        modelContext: ModelContext,
        networkService: NetworkService = NetworkService(baseURL: Constants.cloudPostsURL)
    ) {
        self.modelContext = modelContext
        self.networkService = networkService
        
        // Initializing filters
        self.selectedCategory = self.storedCategory
        self.selectedLevel = self.storedLevel
        self.selectedFavorite = self.storedFavorite
        self.selectedType = self.storedType
        self.selectedPlatform = self.storedPlatform
        self.selectedYear = self.storedYear
        self.selectedSortOption = self.storedSortOption
        
        self.isFiltersEmpty = checkIfAllFiltersAreEmpty()
        
        Task {
            let appStateManager = AppSyncStateManager(modelContext: modelContext)
            // Checking the TermsOfUseAccepted state
            if appStateManager.getTermsOfUseAcceptedStatus() {
                self.isTermsOfUseAccepted = true
            }
            // We check for new materials in the author's collection in the cloud
            let hasUpdates = await checkCloudCuratedPostsForUpdates()
            
            if hasUpdates {
                appStateManager.setCuratedPostsLoadStatusOn()
            }
        }

        // Setting the timezone
        if let utcTimeZone = TimeZone(secondsFromGMT: 0) {
            utcCalendar.timeZone = utcTimeZone
        }
        
        // Subscriptions for filtering
        setupSubscriptions()
    }

    // MARK: - Private Methods
    
    // MARK: - Funcrtions for Static Posts
    /// Loads static posts on first launch
    func loadStaticPostsIfNeeded() async {
        
        // Using global values ​​in AppStateManager to check
        let appStateManager = AppSyncStateManager(modelContext: modelContext)
        let globalShouldLoadStaticPostsStatus = appStateManager.getStaticPostsLoadToggleStatus()
        let globalCheckIfStaticPostsHasLoaded = appStateManager.checkIfStaticPostsHasLoaded()
        
        // Проверяем совпадение локального значения статуса shouldLoadStaticPosts с AppStateManager
        // If they don't match, we adjust the local one - the global one takes priority
        if shouldLoadStaticPosts != globalShouldLoadStaticPostsStatus {
            shouldLoadStaticPosts = globalShouldLoadStaticPostsStatus
        }
        // STEP 0: Check the status of shouldLoadStaticPosts in AppStateManager. If it is disabled, exit.
        guard globalShouldLoadStaticPostsStatus else {
            return
        }
        
        // STEP 1: Wait for iCloud syncing
        // Give time to receive data from another device
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 секунды

        // STEP 2: Check the hasLoadedStaticPosts status in AppStateManager. If they have already been loaded, exit
        if globalCheckIfStaticPostsHasLoaded {
            // STEP 3: MANDATORY CLEANING of duplicates after synchronization (SwiftUI + CloudKit duplicate identical static and author posts
            await removeDuplicateStaticPosts()
            return
        }
        
        // STEP 4: Check if there are already posts with the same ID in the static posts database
        let allStaticIds = Set(StaticPost.staticPosts.map { $0.id })
        
        let descriptor = FetchDescriptor<Post>(
            predicate: #Predicate { post in
                // We filter only those posts whose ID is contained in the set of static IDs
                allStaticIds.contains(post.id)
            }
        )
        
        do {
            // Loading posts whose IDs are contained in a set of static IDs
            let existingStaticPosts = try modelContext.fetch(descriptor)
            
            // STEP 5: If there is already at least one post, DO NOT create new ones.
            if !existingStaticPosts.isEmpty {
                log("⚠️⚠️ Обнаружены существующие статические посты: \(existingStaticPosts.count) шт.", level: .info)
                log("⚠️⚠️ Вероятно, они синхронизированы с другого устройства", level: .info)
                
                // Removing duplicates
                await removeDuplicateStaticPosts()

                // Mark as downloaded
                appStateManager.markStaticPostsAsLoaded()
                
                loadPostsFromSwiftData()
                return
            }
            
            for staticPost in StaticPost.staticPosts {
                    let newPost = Post(
                        id: staticPost.id,
                        category: staticPost.category,
                        title: staticPost.title,
                        intro: staticPost.intro,
                        author: staticPost.author,
                        postType: staticPost.postType,
                        urlString: staticPost.urlString,
                        postPlatform: staticPost.postPlatform,
                        postDate: staticPost.postDate,
                        studyLevel: staticPost.studyLevel,
                        progress: staticPost.progress,
                        favoriteChoice: staticPost.favoriteChoice,
                        postRating: staticPost.postRating,
                        notes: staticPost.notes,
                        origin: staticPost.origin,
                        draft: staticPost.draft,
                        date: staticPost.date,
                        startedDateStamp: staticPost.startedDateStamp,
                        studiedDateStamp: staticPost.studiedDateStamp,
                        practicedDateStamp: staticPost.practicedDateStamp
                    )
                    modelContext.insert(newPost)
            }

            try modelContext.save()
            // Mark as downloaded
            appStateManager.markStaticPostsAsLoaded()
            loadPostsFromSwiftData()

        } catch {
            log("❌ Ошибка при загрузке статических постов: \(error)", level: .error)
        }
    }

    // MARK: - Remove Duplicates
    /// Removes duplicate static posts, leaving only one instance of each ID
    private func removeDuplicateStaticPosts() async {
        
        let allStaticIds = Set(StaticPost.staticPosts.map { $0.id })
        
        let descriptor = FetchDescriptor<Post>(
            predicate: #Predicate { post in
                allStaticIds.contains(post.id)
            }
        )
        
        do {
            let existingStaticPosts = try modelContext.fetch(descriptor)
            
            guard existingStaticPosts.count > StaticPost.staticPosts.count else {
                return
            }
            
            log("🗑️ Обнаружены дубликаты! Всего: \(existingStaticPosts.count), ожидалось: \(StaticPost.staticPosts.count)", level: .info)
            
            // Group by ID
            let groupedById = Dictionary(grouping: existingStaticPosts, by: { $0.id })
            
            var deletedCount = 0
            
            // For each ID, we leave only the first post and delete the rest.
            for (id, posts) in groupedById where posts.count > 1 {
                log("  🔍 ID \(id): найдено \(posts.count) дубликатов", level: .info)
                
                // Sort by creation date and leave the oldest one
                let sortedPosts = posts.sorted { $0.date < $1.date }
                
                // We delete everything except the first one.
                for duplicatePost in sortedPosts.dropFirst() {
                    modelContext.delete(duplicatePost)
                    deletedCount += 1
                    log("    ✗ Удалён дубликат: \(duplicatePost.title)", level: .info)
                }
            }
            
            if deletedCount > 0 {
                try modelContext.save()
                log("✅ Removed \(deletedCount) duplicates", level: .info)
                loadPostsFromSwiftData()
            }
        } catch {
            log("❌ Error removing duplicates: \(error)", level: .error)

        }
    }
                
    private func removeStaticPosts() {
        
        let staticIds = Set(StaticPost.staticPosts.map { $0.id })
        
        let descriptor = FetchDescriptor<Post>(
            predicate: #Predicate { post in
                staticIds.contains(post.id)
            }
        )
        
        do {
            let staticPosts = try modelContext.fetch(descriptor)
            
            for post in staticPosts {
                modelContext.delete(post)
            }
            
            try modelContext.save()
            
            // Reset the flaf
            let appStateManager = AppSyncStateManager(modelContext: modelContext)
            appStateManager.markStaticPostsAsNotLoaded()
            
            // Update UI
            loadPostsFromSwiftData()
            
        } catch {
            log("❌ Error deleting static posts: \(error)", level: .error)
        }
    }
    
    // MARK: - SwiftData Operations
    
    /// Loading posts from SwiftData
    func loadPostsFromSwiftData() {
        
        let descriptor = FetchDescriptor<Post>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do {
            allPosts = try modelContext.fetch(descriptor)
            // DEBUG: Display all posts with ID
            log("📊 Loaded \(allPosts.count) posts from SwiftData:", level: .debug)
//            for (index, post) in allPosts.enumerated() {
//                log("📊 \(index + 1). ID: \(post.id), Title: \(post.title)", level: .debug)
//            }
            allYears = getAllYears()
            allCategories = getAllCategories()
        } catch {
            errorMessage = "Error loading data"
            showErrorMessageAlert = true
        }
    }
    
    func addPostIfNotExists(_ newPost: Post) -> Bool {
        // Check by ID
        if allPosts.contains(where: { $0.id == newPost.id }) {
            log("❌ Post with ID \(newPost.id) already exists", level: .info)
            return false
        }
        
        // Check by Title
        if allPosts.contains(where: { $0.title == newPost.title }) {
            log("❌ Post with the title '(newPost.title)' already exists", level: .info)
            return false
        }
        
        modelContext.insert(newPost)
        saveContextAndReload()
        return true
    }
    
    /// Adding a new post
    func addPost(_ newPost: Post) {
        modelContext.insert(newPost)
        saveContextAndReload()
    }
    
    /// Post update
    func updatePost() {
        saveContextAndReload()
    }
    
    /// Deleting a post
    func deletePost(post: Post?) {
        guard let post = post else {
            log("❌ Attempt to delete a nil post", level: .error)
            return
        }
        
        modelContext.delete(post)
        saveContextAndReload()
        
        // All posts have been deleted and the hasLoadedStaticPosts flag has been reset.
        if allPosts.isEmpty {
            let appStateManager = AppSyncStateManager(modelContext: modelContext)
            appStateManager.markStaticPostsAsNotLoaded()
        }

    }
    
    /// Deleting all posts
    func eraseAllPosts(_ completion: @escaping () -> ()) {
        do {
            // Deleting all posts
            try modelContext.delete(model: Post.self)
            
            // We're resetting the flag because ALL posts (including static ones) have been deleted.
            let appStateManager = AppSyncStateManager(modelContext: modelContext)
            appStateManager.markStaticPostsAsNotLoaded()
            
            saveContextAndReload()
            completion()
        } catch {
            errorMessage = "Error deleting data"
            showErrorMessageAlert = true
        }
    }
    
    /// Toggle favorite flag
    func favoriteToggle(post: Post) {
        post.favoriteChoice = post.favoriteChoice == .yes ? .no : .yes
        saveContextAndReload()
    }
    
    /// Post rate
    func ratePost(post: Post) {
        post.postRating = selectedRating
        saveContextAndReload()
    }
    
    /// Udate post study progress
    func updatePostStudyProgress(post: Post) {
        post.progress = selectedStudyProgress
        
        switch selectedStudyProgress {
        case .fresh:
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
    
    /// Save context and reload UI
    private func saveContextAndReload() {
        do {
            try modelContext.save()
            // Updating data for the UI
            loadPostsFromSwiftData()
        } catch {
            errorMessage = "Error saving data"
            showErrorMessageAlert = true
            hapticManager.notification(type: .error)
        }
    }
    
    // MARK: - Cloud import of curated study materials
    
    func importPostsFromCloud(urlString: String = Constants.cloudPostsURL, completion: @escaping () -> Void) async {
        
        errorMessage = nil
        showErrorMessageAlert = false
        
        do {
            let cloudResponse: [CodablePost] = try await networkService.fetchDataFromURLAsync()
            log("☁️ Imported \(cloudResponse.count) posts from the cloud", level: .info)
            
            // Filter unique post by ID and title and convert them to the model data format in SwiftData
            let existingTitles = Set(self.allPosts.map { $0.title })
            let existingIds = Set(self.allPosts.map { $0.id })
            
            let newPosts = cloudResponse
                .filter { !existingTitles.contains($0.title) && !existingIds.contains($0.id) }
                .map { PostMigrationHelper.convertFromCodable($0) }
            
            // Checking for new curated posts
            if !newPosts.isEmpty {
                for post in newPosts {
                    self.modelContext.insert(post)
                }
                let appStateManager = AppSyncStateManager(modelContext: modelContext)

                // Update the date of the last import of curated posts - we take the oldest date of the post creation
                let latestDateOfCuaratedPosts = getLatestDateFromPosts(posts: allPosts) ?? .now
                appStateManager.setLastDateOfCuaratedPostsLoaded(latestDateOfCuaratedPosts)

                // As a result of importing curated posts - no new materials -> false
                appStateManager.setCuratedPostsLoadStatusOff()

                self.saveContextAndReload()
                self.hapticManager.notification(type: .success)
                log("✅ Added \(newPosts.count) new posts", level: .info)
            } else {
                self.hapticManager.impact(style: .light)
                log("ℹ️ No new posts", level: .info)
            }

        } catch {
            self.errorMessage = error.localizedDescription
            self.showErrorMessageAlert = true
            self.hapticManager.notification(type: .error)
            log("❌ Import error: \(error)", level: .error)
        }
        
        completion()

    }
    
    // MARK: - Filtering & Searching (без изменений)
    
    private func setupSubscriptions() {
        
        let filters = $selectedLevel
            .combineLatest($selectedFavorite, $selectedType, $selectedYear)
        
        let filtersWithCategoryAndSort = filters
            .combineLatest($selectedPlatform, $selectedSortOption)
            .map { filters, platform, sortOption -> (filters: (StudyLevel?, FavoriteChoice?, PostType?, String?), platform: Platform?, sortOption: SortOption?) in
                return (filters, platform, sortOption)
            }
        
        let debouncedSearchText = $searchText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
        
        $allPosts
            .combineLatest(debouncedSearchText, filtersWithCategoryAndSort)
            .map { posts, searchText, data -> [Post] in
                let (filters, platform, sortOption) = data
                let (level, favorite, type, year) = filters
                
                let filtered = self.filterPosts(
                    allPosts: posts,
                    platform: platform,
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
        platform: Platform?,
        level: StudyLevel?,
        favorite: FavoriteChoice?,
        type: PostType?,
        year: String?
    ) -> [Post] {
        if platform == nil &&
            level == nil &&
            favorite == nil &&
            type == nil &&
            year == nil {
            return allPosts
        }
        let filteredPosts = allPosts.filter { post in
            let matchesLevel = level == nil || post.studyLevel == level
            let matchesFavorite = favorite == nil || post.favoriteChoice == favorite
            let matchesType = type == nil || post.postType == type
            let matchesPlatform = platform == nil || post.postPlatform == platform
            
            let postYear = String(utcCalendar.component(.year, from: post.postDate ?? Date.distantPast))
            let matchesYear = year == nil || postYear == year
            
            return matchesLevel && matchesFavorite && matchesType && matchesPlatform && matchesYear
        }
        
        //            if let category = category {
        //                return filteredPosts.filter { $0.category == category }
        //            } else {
        return filteredPosts
        //            }
    }
    
    func checkIfAllFiltersAreEmpty() -> Bool {
        return selectedLevel == nil &&
        selectedFavorite == nil &&
        selectedType == nil &&
        selectedPlatform == nil &&
        selectedYear == nil &&
        selectedSortOption == nil
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
    
    // MARK: - Helper Methods
    
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
        //        If there is a post with the same title and its id is not equal to excludingPostId, then the title is not unique
        return allPosts.contains(where: { $0.title == postTitle && $0.id != editingPostId })
    }
    
    /// Check for updates to available posts in the cloud.
    ///
    /// The resulting result is used to check and subsequently notify the user about the presence of posts updates in the cloud.
    ///
    /// ```
    /// checkCloudForUpdates(completion: @escaping (Bool) -> Void)
    /// ```
    ///
    /// - Warning: This application is intended for self-study.
    /// - Returns: Returns a boolean result or error within completion handler.
    
    func checkCloudCuratedPostsForUpdates() async -> Bool {
        do {
            let cloudResponse: [CodablePost] = try await networkService.fetchDataFromURLAsync()
            
            self.errorMessage = nil
            self.showErrorMessageAlert = false
            
            let localPosts = self.allPosts.filter { $0.origin == .cloud }
            let cloudPostsConverted = cloudResponse
                .filter { $0.origin == .cloud }
                .map { PostMigrationHelper.convertFromCodable($0) }
            
            var hasUpdates = false
            
            if let latestLocalDate = self.getLatestDateFromPosts(posts: localPosts),
               let latestCloudDate = self.getLatestDateFromPosts(posts: cloudPostsConverted) {
                hasUpdates = latestLocalDate < latestCloudDate
            } else if localPosts.isEmpty && !cloudPostsConverted.isEmpty {
                // If there are no cloud posts locally, but there are in the cloud, this is also for update
                hasUpdates = true
            }
            
            // If any updates
            if hasUpdates {
                log("🍓 checkCloudForUpdates: Posts update is available", level: .debug)
            } else {
                log("🍓☑️ checkCloudForUpdates: No Updates available", level: .debug)
            }
            
            return hasUpdates
            
        } catch {
            self.errorMessage = error.localizedDescription
            self.showErrorMessageAlert = true
            self.hapticManager.notification(type: .error)
            
            log("🍓❌ checkCloudForUpdates: Error \(error.localizedDescription)", level: .error)
            return false
        }
    }
    
    func getFilePath(fileName: String) -> Result<URL, FileStorageError> {
        log("🍓FM(getFilePath): Exporting from SwiftData...", level: .info)
        log("🍓FM(getFilePath): Getting url...", level: .info)
        
        guard fileName == Constants.localPostsFileName else {
            return .failure(.fileNotFound)
        }
        
        // Просто вызываем новый метод экспорта
        switch exportPostsToJSON() {
        case .success(let url):
            log("🍓FM(getFilePath): Successfully got file url: \(url).", level: .info)
            return .success(url)
        case .failure(let error):
            return .failure(.exportError(error.localizedDescription))
        }
    }
    
    func getPostsFromBackup(url: URL, completion: @escaping (Int) -> Void) {
        
        self.errorMessage = nil
        self.showErrorMessageAlert = false
        var postsCount: Int = 0
        
        do {
            // 1. Reading JSON data
            let jsonData = try Data(contentsOf: url)
            // 2. Decode to [CodablePost] (not [Post])
            let codablePosts = try JSONDecoder.appDecoder.decode([CodablePost].self, from: jsonData)
            // 3. Convert to SwiftData Post via PostMigrationHelper
            let posts = codablePosts.map { PostMigrationHelper.convertFromCodable($0) }
            // 4. We check for uniqueness and add it to SwiftData
            let postsCheckedForUnique = self.checkAndReturnUniquePosts(posts: posts)
            postsCount = postsCheckedForUnique.count
            
            if !postsCheckedForUnique.isEmpty {
                // 5. Save into SwiftData
                for post in postsCheckedForUnique {
                    self.modelContext.insert(post)
                }
                // 6. Save the context and update the UI
                saveContextAndReload()
                
                self.hapticManager.notification(type: .success)
                log("🍓 Restore: Restored \(postsCount) posts from \(url.lastPathComponent)", level: .info)
            }
            
        } catch {
            self.errorMessage = error.localizedDescription
            self.showErrorMessageAlert = true
            self.hapticManager.notification(type: .error)
            log("🍓❌ Restore:Failed to load posts: \(error)", level: .error)
        }
        
        completion(postsCount)
    }
    
    func exportPostsToJSON() -> Result<URL, Error> {
        do {
            // Получаем все посты из SwiftData
            let descriptor = FetchDescriptor<Post>(sortBy: [SortDescriptor(\.date, order: .reverse)])
            let allPosts = try modelContext.fetch(descriptor)
            
            log("🍓 Exporting \(allPosts.count) posts from SwiftData", level: .info)
            
            // Конвертируем Post -> CodablePost
            let codablePosts = allPosts.map { post in
                CodablePost(
                    id: post.id,
                    category: post.category,
                    title: post.title,
                    intro: post.intro,
                    author: post.author,
                    postType: post.postType,
                    urlString: post.urlString,
                    postPlatform: post.postPlatform,
                    postDate: post.postDate,
                    studyLevel: post.studyLevel,
                    progress: post.progress,
                    favoriteChoice: post.favoriteChoice,
                    postRating: post.postRating,
                    notes: post.notes,
                    origin: post.origin,
                    draft: post.draft,
                    date: post.date,
                    startedDateStamp: post.startedDateStamp,
                    studiedDateStamp: post.studiedDateStamp,
                    practicedDateStamp: post.practicedDateStamp
                )
            }
            
            // Кодируем в JSON
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            
            let jsonData = try encoder.encode(codablePosts)
            
            // Создаем уникальное имя файла с датой
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm"
            let dateString = dateFormatter.string(from: Date())
            
            let fileName = "StartToSwiftUI_backup_\(dateString).json"
            let tempFileURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(fileName)
            
            try jsonData.write(to: tempFileURL)
            
            log("🍓✅ Exported to: \(tempFileURL.lastPathComponent)", level: .info)
            return .success(tempFileURL)
            
        } catch {
            log("🍓❌ Export failed: \(error)", level: .error)
            return .failure(error)
        }
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
    
    private func getLatestDateFromPosts(posts: [Post]) -> Date? {
        
        guard !posts.isEmpty else { return nil }
        
        return posts.max(by: { $0.date < $1.date })?.date
        
    }
    
    private func getAllYears() -> [String]? {
        let years = allPosts.compactMap { post -> String? in
            guard let date = post.postDate else { return nil }
            return String(utcCalendar.component(.year, from: date))
        }
        return Array(Set(years)).sorted()
    }
    
    private func getAllCategories() -> [String]? {
        let categories = Array(Set(allPosts.map { $0.category })).sorted()
        return categories.isEmpty ? nil : categories
    }
    
    func getPost(id: String) -> Post? {
        allPosts.first(where: { $0.id == id })
    }
}
