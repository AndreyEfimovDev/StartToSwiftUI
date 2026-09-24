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
    private let cloudChangeObserver: CloudChangeObserving?

    @Published var allPosts: [Post] = [] {
        // Единая точка для всех путей удаления: свайп Delete, Erase, Erase all,
        // удаление дублей, синк CloudKit — все они заканчиваются
        // переприсваиванием allPosts.
        didSet { clearSelectedPostIfRemoved() }
    }
    @Published var filteredPosts: [Post] = []
    @Published var selectedPost: Post? = nil
    @Published var searchText: String = ""
    @Published var selectedRating: PostRating? = nil
    @Published var selectedStudyProgress: StudyProgress = .added
    @Published var reshuffleToken = UUID()
    /// Есть ли в Firestore новые посты — единый источник правды для кнопки
    /// "Check for materials update" в Preferences. Обновляется только при
    /// запуске, pull-to-refresh и принудительной проверке в модалке — не при
    /// каждом открытии Preferences (экономия запросов в Firestore).
    @Published var hasPostsUpdate = false
      
    var cancellables = Set<AnyCancellable>()
    
    var allYears: [String]? = nil
    /// Случайный ключ сортировки для каждого поста (id → ключ) при
    /// сортировке "Random". Ключи раздаются лениво при сортировке и
    /// сбрасываются только явным reshufflePosts().
    var randomSortKeys: [String: Double] = [:]
    /// Счётчики этапов, последними записанные в виджет (added, started,
    /// studied, practiced). Не `private` — используется в
    /// PostsViewModel+Widget.swift, чтобы не перезаписывать виджет без изменений.
    var lastWidgetCounts: [Int]?
    
    private var isStarted = false

    // Защита от повторного входа: если запрос уже выполняется, пропускаем
    // новый — он всё равно спросит Firebase о том же диапазоне дат и не
    // найдёт ничего нового сверх уже идущего запроса.
    // Не `private`, т.к. методы, которые их используют, объявлены в
    // extension-файле PostsViewModel+FBImport.swift.
    // @Published — PreferencesView блокирует по ним кнопки импорта/проверки,
    // пока запрос в Firestore ещё идёт.
    @Published var isImportingPosts = false
    @Published var isCheckingPostsForUpdates = false
    
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
        cloudChangeObserver: CloudChangeObserving? = nil,
        services: AppServiceDependencies
    ) {
        self.dataSource = dataSource
        self.appStateManager = appStateManager
        self.fbPostsManager = fbPostsManager
        self.cloudChangeObserver = cloudChangeObserver
        self.errorManager = services.errorManager
        self.fileManager = services.fileManager
        self.crashManager = services.crashManager
        self.performanceManager = services.performanceManager
        self.analyticsManager = services.analyticsManager

        restorePostFilters()
    }
    /// Convenience initialiser for backward compatibility
    convenience init(
        modelContext: ModelContext,
        appStateManager: AppSyncStateManagerProtocol? = nil,
        fbPostsManager: FBPostsManagerProtocol,
        cloudChangeObserver: CloudChangeObserving? = nil,
        services: AppServiceDependencies
    ) {
        self.init(
            dataSource: SwiftDataPostsDataSource(modelContext: modelContext),
            appStateManager: appStateManager,
            fbPostsManager: fbPostsManager,
            cloudChangeObserver: cloudChangeObserver,
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

    // MARK: - CloudKit Sync
    /// Перезагрузка постов при изменениях хранилища (в т.ч. из iCloud).
    /// Дубли здесь не чистятся: если два устройства одновременно удалят друг
    /// у друга разные копии, после синка пост пропадёт совсем.
    private func setupSubscriptionForChangesInCloud() {
        cloudChangeObserver?.changes
            .filter { $0.contains(.post) }
            .sink { [weak self] _ in
                self?.loadPostsFromSwiftData(removeDuplicates: false)
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
    }
                
    // MARK: - SwiftData Operations
    
    /// Load posts from SwiftData
    func loadPostsFromSwiftData(removeDuplicates: Bool = true) {
        let trace = performanceManager.startTrace(name: "load_posts_swiftdata")
        
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
            // Единая точка обновления виджета: любая перезагрузка постов —
            // локальное сохранение, запуск, refresh, синк CloudKit.
            updateWidgetData()
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
                    // Прогресс, избранное, рейтинг и заметки удаляемой копии
                    // переносятся в остающуюся — иначе они потеряются на всех устройствах.
                    postToKeep.mergeUserState(from: post)
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
                    postToKeep.mergeUserState(from: post)
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
    ///
    /// - Returns: `true`, если пост сохранён; `false` при ошибке сохранения
    ///   (ошибка уже отправлена в `ErrorManager`).
    @discardableResult
    func addPost(_ newPost: Post) -> Bool {
        dataSource.insert(newPost)
        return saveContextAndReload()
    }
    
    /// If necessary, update post.origin .cloudNew with .cloud
    func updatePostOrigin(_ post: Post) {
        post.origin = .cloud
        saveContextAndReload()
    }
    
    /// Post update
    ///
    /// - Returns: `true`, если изменения сохранены; `false` при ошибке
    ///   сохранения (ошибка уже отправлена в `ErrorManager`).
    @discardableResult
    func updatePost() -> Bool {
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
    ///
    /// При успехе сбрасывает дату последней загрузки постов из облака — чтобы
    /// коллекцию можно было скачать заново. При ошибке дата не трогается.
    ///
    /// - Returns: `true`, если посты удалены и сохранение прошло; `false` при
    ///   ошибке (ошибка уже отправлена в `ErrorManager`).
    @discardableResult
    func eraseAllPosts() -> Bool {
        let isErased: Bool
        do {
            try dataSource.deleteAll()
            isErased = saveContextAndReload()
        } catch {
            crashManager.sendNonFatal(error)
            handleError(error, message: "Error deleting data")
            isErased = false
        }

        if isErased {
            appStateManager?.resetLastDateOfPostsLoaded()
        }
        return isErased
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
        // Правила меток дат этапов — в модели (Post.applyStudyProgress).
        post.applyStudyProgress(selectedStudyProgress)
        analyticsManager.logEvent(name: "study_progress_changed", params: ["progress": selectedStudyProgress.rawValue])
        saveContextAndReload()
    }
    
    // MARK: - Helper Methods

    /// Сбрасывает `selectedPost`, если выбранный пост удалён из базы или
    /// больше не показывается в списке (в корзине / стал черновиком).
    ///
    /// Нужно для iPad: детальная колонка берёт пост из `selectedPost` и
    /// видна одновременно со списком, поэтому иначе продолжала бы показывать
    /// уже удалённый пост. Условие `active && !draft` совпадает с фильтром
    /// списка в MaterialsHomeView.
    private func clearSelectedPostIfRemoved() {
        guard let selected = selectedPost else { return }
        // Сверяем по persistentModelID, а не по id: обычные поля модели,
        // удалённой из SwiftData, читать небезопасно.
        guard let current = allPosts.first(where: { $0.persistentModelID == selected.persistentModelID }),
              current.status == .active,
              !current.draft else {
            selectedPost = nil
            return
        }
    }
    
    /// Save context and reload UI
    /// Сохраняет контекст и перезагружает посты.
    ///
    /// - Returns: `true`, если сохранение прошло; `false` при ошибке (она
    ///   уже отправлена в `ErrorManager`). Результат нужен экранам, которые
    ///   показывают пользователю итог операции, остальные его игнорируют.
    @discardableResult
    func saveContextAndReload(removeDuplicates: Bool = true) -> Bool {
        do {
            try dataSource.save()
            loadPostsFromSwiftData(removeDuplicates: removeDuplicates)
            return true
        } catch {
            crashManager.sendNonFatal(error)
            handleError(error, message: "Error saving data")
            return false
        }
    }
    
    func checkNewPostForUniqueTitle(_ postTitle: String, editingPostId: String?) -> Bool {
        allPosts.contains(where: { $0.title == postTitle && $0.id != editingPostId })
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
    
    private func getAllYears() -> [String]? {
        // Локальный календарь — тот же, что при создании (DatePicker,
        // Date.from) и отображении даты в строке: год в списке фильтра
        // совпадает с тем, что пользователь видит у поста.
        let years = allPosts.compactMap { post -> String? in
            post.postDate.map { String(Calendar.current.component(.year, from: $0)) }
        }
        let unique = Array(Set(years)).sorted()
        return unique.isEmpty ? nil : unique
    }
    
    // MARK: - Handle Errors
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
