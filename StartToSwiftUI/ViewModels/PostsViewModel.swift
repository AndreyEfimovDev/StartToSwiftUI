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

    // Загружать ли статические посты - привязано к AppStateManager, используем только в Toggle в Preferences
    @AppStorage("shouldLoadStaticPosts") var shouldLoadStaticPosts: Bool = true {
        didSet {
            print("🔄 shouldLoadStaticPosts изменился: \(shouldLoadStaticPosts)")
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
    
    // Метод для принятия условий
    func acceptTermsOfUse() {
        let appStateManager = AppSyncStateManager(modelContext: modelContext)
        appStateManager.acceptTermsOfUse()
        objectWillChange.send()
    }

    
    // MARK: - Init
    
    init(
        modelContext: ModelContext,
        networkService: NetworkService = NetworkService(baseURL: Constants.cloudPostsURL)
    ) {
        self.modelContext = modelContext
        self.networkService = networkService
        
        // Инициализация фильтров
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
            // Проверяем стостояние TermsOfUseAccepted
            self.isTermsOfUseAccepted = appStateManager.getTermsOfUseAcceptedStatus()

            // Проверяем наличие новых материалов в авторской коллекции в облаке
            let hasUpdates = await checkCloudCuratedPostsForUpdates()
            
            if hasUpdates {
                appStateManager.setCuratedPostsLoadStatusOn()
            }
        }

        // Настройка timezone
        if let utcTimeZone = TimeZone(secondsFromGMT: 0) {
            utcCalendar.timeZone = utcTimeZone
        }
        
        // Подписки для фильтрации
        setupSubscriptions()
    }

    // MARK: - Private Methods
    
    // MARK: - Funcrtions for Static Posts
    /// Загружает статические посты при первом запуске
    func loadStaticPostsIfNeeded() async {
//        print("🔍 Проверка необходимости загрузки статических постов...")
        
        // Используем глобальные значения в AppStateManager для проверки
        let appStateManager = AppSyncStateManager(modelContext: modelContext)
        let globalShouldLoadStaticPostsStatus = appStateManager.getStaticPostsLoadToggleStatus()
        let globalCheckIfStaticPostsHasLoaded = appStateManager.checkIfStaticPostsHasLoaded()
        
//        print("⚠️⚠️ Переключатель загрузки стат. постов shouldLoadStaticPosts: \(globalShouldLoadStaticPostsStatus)")
//        print("⚠️⚠️ Статус загрузки стат. постов hasLoadedStaticPosts: \(globalCheckIfStaticPostsHasLoaded)")


        // Проверяем совпадение локального значения статуса shouldLoadStaticPosts с AppStateManager
        // Если не совпадают, корректируем локальный - глобальный в приоритете
        if shouldLoadStaticPosts != globalShouldLoadStaticPostsStatus {
            shouldLoadStaticPosts = globalShouldLoadStaticPostsStatus
        }
        // ШАГ 0: проверяем статус shouldLoadStaticPosts в AppStateManager, если оключена, выходим
        guard globalShouldLoadStaticPostsStatus else {
//            print("⚠️⚠️ Загрузка статических постов отключена пользователем")
            return
        }
        
        // ШАГ 1: Ждём синхронизацию с iCloud
        // Даём время на получение данных с другого устройства
        print("⚠️⚠️ ⏳ Ожидание синхронизации iCloud (2 секунды)...")
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 секунды

        // ШАГ 2: Проверяем флаг из SwiftData (синхронизируется через iCloud!)
        // ШАГ 2: Проверяем статус hasLoadedStaticPosts в AppStateManager, если уже загружали, выходим
        if globalCheckIfStaticPostsHasLoaded {
//            print("⚠️⚠️ Статические посты уже были загружены ранее (проверка через iCloud)")
//            print("⚠️⚠️ appStateManager.hasLoadedStaticPosts: \(String(describing: appStateManager.checkIfStaticPostsHasLoaded()))")
            
            // ШАГ 3: ОБЯЗАТЕЛЬНАЯ ОЧИСТКА дубликатов после синхронизации (SwiftUI + CloudKit задваивают одинаковые статические и авторские посты
            await removeDuplicateStaticPosts()
            return
        }
        
//        print("⚠️⚠️ 📦 Статические посты ещё не загружены, начинаем загрузку...")
        
        // ШАГ 4: Проверяем, нет ли уже постов с такими же ID в базе статических постов
        let allStaticIds = Set(StaticPost.staticPosts.map { $0.id })
        
        let descriptor = FetchDescriptor<Post>(
            predicate: #Predicate { post in
                // Фильтруем только те посты, чьи ID содержится в наборе статических ID
                allStaticIds.contains(post.id)
            }
        )
        
        do {
            // Загружаем посты, чьи ID содержится в наборе статических ID
            let existingStaticPosts = try modelContext.fetch(descriptor)
            
            // 🔥 ШАГ 5: Если уже есть хотя бы один пост - НЕ создаём новые
            if !existingStaticPosts.isEmpty {
//                print("⚠️⚠️ Обнаружены существующие статические посты: \(existingStaticPosts.count) шт.")
//                print("⚠️⚠️ Вероятно, они синхронизированы с другого устройства")
                
                // Удаляем дубликаты
                await removeDuplicateStaticPosts()
//                print("⚠️⚠️ Удаляем дубликаты")

                // Отмечаем как загруженные
                appStateManager.markStaticPostsAsLoaded()
//                print("⚠️⚠️ Отмечаем как загруженные hasLoadedStaticPosts: \(appStateManager.markStaticPostsAsLoaded())")

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
//                    print("⚠️⚠️  ✓ Добавлен: \(staticPost.title)")
            }

            try modelContext.save()
//            print("⚠️⚠️ 💾 Статические посты сохранены в SwiftData")
            
            // Отмечаем как загруженные
//            print("⚠️⚠️ Отмечаем ФЛАГ - статические посты как загруженные")
            
            appStateManager.markStaticPostsAsLoaded()
            
//            print("⚠️⚠️ appStateManager.hasLoadedStaticPosts: \(String(describing: appStateManager.checkIfStaticPostsHasLoaded()))")

            loadPostsFromSwiftData()

//            print("⚠️⚠️ ✅ Загрузка статических постов завершена")
        } catch {
//            print("❌ Ошибка при загрузке статических постов: \(error)")
        }
    }

    // MARK: - Remove Duplicates
    /// Удаляет дубликаты статических постов, оставляя только один экземпляр каждого ID
    private func removeDuplicateStaticPosts() async {
//        print("🔍 Проверка дубликатов статических постов...")
        
        let allStaticIds = Set(StaticPost.staticPosts.map { $0.id })
        
        let descriptor = FetchDescriptor<Post>(
            predicate: #Predicate { post in
                allStaticIds.contains(post.id)
            }
        )
        
        do {
            let existingStaticPosts = try modelContext.fetch(descriptor)
            
            guard existingStaticPosts.count > StaticPost.staticPosts.count else {
//                print("✅ Дубликатов не обнаружено (\(existingStaticPosts.count) постов)")
                return
            }
            
//            print("🗑️ Обнаружены дубликаты! Всего: \(existingStaticPosts.count), ожидалось: \(StaticPost.staticPosts.count)")
            
            // Группируем по ID
            let groupedById = Dictionary(grouping: existingStaticPosts, by: { $0.id })
            
            var deletedCount = 0
            
            // Для каждого ID оставляем только первый пост, остальные удаляем
            for (id, posts) in groupedById where posts.count > 1 {
                print("  🔍 ID \(id): найдено \(posts.count) дубликатов")
                
                // Сортируем по дате создания и оставляем самый старый
                let sortedPosts = posts.sorted { $0.date < $1.date }
                
                // Удаляем все кроме первого
                for duplicatePost in sortedPosts.dropFirst() {
                    modelContext.delete(duplicatePost)
                    deletedCount += 1
                    print("    ✗ Удалён дубликат: \(duplicatePost.title)")
                }
            }
            
            if deletedCount > 0 {
                try modelContext.save()
//                print("✅ Удалено \(deletedCount) дубликатов")
                loadPostsFromSwiftData()
            }
        } catch {
            print("❌ Ошибка при удалении дубликатов: \(error)")
        }
    }
                
    private func removeStaticPosts() {
        print("🗑️ Удаление статических постов...")
        
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
            print("✅ Удалено \(staticPosts.count) статических постов")
            
            // Сбрасываем флаг
            let appStateManager = AppSyncStateManager(modelContext: modelContext)
            appStateManager.markStaticPostsAsNotLoaded()
            
            // Обновляем UI
            loadPostsFromSwiftData()
            
        } catch {
            print("❌ Ошибка удаления статических постов: \(error)")
        }
    }
    

    
    // MARK: - SwiftData Operations
    
    /// Загрузка постов из SwiftData
    func loadPostsFromSwiftData() {
        
        let descriptor = FetchDescriptor<Post>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do {
            allPosts = try modelContext.fetch(descriptor)
            // 🔍 ДЕБАГ: Выводим все посты с ID
//            print("📊 Загружено \(allPosts.count) постов из SwiftData:")
//            for (index, post) in allPosts.enumerated() {
//                print("📊 \(index + 1). ID: \(post.id), Title: \(post.title)")
//            }
            allYears = getAllYears()
            allCategories = getAllCategories()
        } catch {
            errorMessage = "Ошибка загрузки данных"
            showErrorMessageAlert = true
//            print("📊 ❌ Ошибка загрузки из SwiftData: \(error)")
        }
    }
    
    func addPostIfNotExists(_ newPost: Post) -> Bool {
        // Проверяем по ID
        if allPosts.contains(where: { $0.id == newPost.id }) {
            print("❌ Пост с ID \(newPost.id) уже существует")
            return false
        }
        
        // Проверяем по заголовку
        if allPosts.contains(where: { $0.title == newPost.title }) {
            print("❌ Пост с заголовком '\(newPost.title)' уже существует")
            return false
        }
        
        modelContext.insert(newPost)
        saveContextAndReload()
        return true
    }
    
    /// Добавление нового поста
    func addPost(_ newPost: Post) {
        modelContext.insert(newPost)
        saveContextAndReload()
    }
    
    /// Обновление поста
    func updatePost(_ updatedPost: Post) {
        saveContextAndReload()
    }
    
    /// Удаление поста
    func deletePost(post: Post?) {
        guard let post = post else {
            print("❌ Попытка удалить nil пост")
            return
        }
        
        modelContext.delete(post)
        saveContextAndReload()
        
        // Все посты удалены, флаг hasLoadedStaticPosts сброшен
        if allPosts.isEmpty {
            let appStateManager = AppSyncStateManager(modelContext: modelContext)
            appStateManager.markStaticPostsAsNotLoaded()
        }

    }
    
    /// Удаление всех постов
    func eraseAllPosts(_ completion: @escaping () -> ()) {
        do {
            // Удаляем все посты
            try modelContext.delete(model: Post.self)
            
            // Сбрасываем флаг, так как удалены ВСЕ посты (включая статические)
            let appStateManager = AppSyncStateManager(modelContext: modelContext)
            appStateManager.markStaticPostsAsNotLoaded()
            
            saveContextAndReload()
            completion()
        } catch {
            errorMessage = "Ошибка удаления данных"
            showErrorMessageAlert = true
        }
    }
    
    /// Переключение избранного
    func favoriteToggle(post: Post) {
        post.favoriteChoice = post.favoriteChoice == .yes ? .no : .yes
        saveContextAndReload()
    }
    
    /// Оценка поста
    func ratePost(post: Post) {
        post.postRating = selectedRating
        saveContextAndReload()
    }
    
    /// Обновление прогресса изучения
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
    
    /// Сохранение контекста
    private func saveContextAndReload() {
        do {
            try modelContext.save()
            // Обновляем данные для UI
            loadPostsFromSwiftData()
        } catch {
            errorMessage = "Ошибка сохранения данных"
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
            print("☁️ Импортировано \(cloudResponse.count) постов из облака")
            
            // Фильтруем уникальные посты по ID и Title и конвертируем в формат модели данных в SwiftData
            let existingTitles = Set(self.allPosts.map { $0.title })
            let existingIds = Set(self.allPosts.map { $0.id })
            
            let newPosts = cloudResponse
                .filter { !existingTitles.contains($0.title) && !existingIds.contains($0.id) }
                .map { PostMigrationHelper.convertFromCodable($0) }
            
            // Проверка на наличие новых авторских постов
            if !newPosts.isEmpty {
                for post in newPosts {
                    self.modelContext.insert(post)
                }
                let appStateManager = AppSyncStateManager(modelContext: modelContext)

                // Обновляем дату последнего импорта автосрких постов - берем старщую дату создания записи поста
                let latestDateOfCuaratedPosts = getLatestDateFromPosts(posts: allPosts) ?? .now
                appStateManager.setLastDateOfCuaratedPostsLoaded(latestDateOfCuaratedPosts)

                // Как результат импорта авторских ссылок на материалы - новых материалов нет -> false
                appStateManager.setCuratedPostsLoadStatusOff()

                self.saveContextAndReload()
                self.hapticManager.notification(type: .success)
                print("✅ Добавлено \(newPosts.count) новых постов")
            } else {
                self.hapticManager.impact(style: .light)
                print("ℹ️ Новых постов нет")
            }

        } catch {
            self.errorMessage = error.localizedDescription
            self.showErrorMessageAlert = true
            self.hapticManager.notification(type: .error)
            print("❌ Ошибка импорта: \(error)")
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
                // Если локально нет cloud-постов, а в облаке есть — это тоже обновление
                hasUpdates = true
            }
            
            // 3. Если есть обновления
            if hasUpdates {
                print("🍓 checkCloudForUpdates: Posts update is available")
            } else {
                print("🍓☑️ checkCloudForUpdates: No Updates available")
            }
            
            return hasUpdates
            
        } catch {
            self.errorMessage = error.localizedDescription
            self.showErrorMessageAlert = true
            self.hapticManager.notification(type: .error)
            
            print("🍓❌ checkCloudForUpdates: Error \(error.localizedDescription)")
            return false
        }
    }
    
    func getFilePath(fileName: String) -> Result<URL, FileStorageError> {
        print("🍓FM(getFilePath): Exporting from SwiftData...")
        print("🍓FM(getFilePath): Getting url...")
        
        guard fileName == Constants.localPostsFileName else {
            return .failure(.fileNotFound)
        }
        
        // Просто вызываем новый метод экспорта
        switch exportPostsToJSON() {
        case .success(let url):
            print("🍓FM(getFilePath): Successfully got file url: \(url).")
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
            // 1. Читаем JSON-данные
            let jsonData = try Data(contentsOf: url)
            // 2. Декодируем в [CodablePost] (а не [Post])
            let codablePosts = try JSONDecoder.appDecoder.decode([CodablePost].self, from: jsonData)
            // 3. Конвертируем в SwiftData Post через PostMigrationHelper
            let posts = codablePosts.map { PostMigrationHelper.convertFromCodable($0) }
            // 4. Проверяем уникальность и добавляем в SwiftData
            let postsCheckedForUnique = self.checkAndReturnUniquePosts(posts: posts)
            postsCount = postsCheckedForUnique.count
            
            if !postsCheckedForUnique.isEmpty {
                // 5. Вставляем в SwiftData
                for post in postsCheckedForUnique {
                    self.modelContext.insert(post)
                }
                // 6. Сохраняем контекст и обновляем локальный список
                saveContextAndReload()
                
                self.hapticManager.notification(type: .success)
                print("🍓 Restore: Restored \(postsCount) posts from \(url.lastPathComponent)")
            }
            
        } catch {
            self.errorMessage = error.localizedDescription
            self.showErrorMessageAlert = true
            self.hapticManager.notification(type: .error)
            print("🍓❌ Restore:Failed to load posts: \(error)")
        }
        
        completion(postsCount)
    }
    
    func exportPostsToJSON() -> Result<URL, Error> {
        do {
            // Получаем все посты из SwiftData
            let descriptor = FetchDescriptor<Post>(sortBy: [SortDescriptor(\.date, order: .reverse)])
            let allPosts = try modelContext.fetch(descriptor)
            
            print("🍓 Exporting \(allPosts.count) posts from SwiftData")
            
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
            
            print("🍓✅ Exported to: \(tempFileURL.lastPathComponent)")
            return .success(tempFileURL)
            
        } catch {
            print("🍓❌ Export failed: \(error)")
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
