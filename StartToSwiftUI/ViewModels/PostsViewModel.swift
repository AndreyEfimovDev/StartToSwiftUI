//
//  PostViewModel.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.08.2025.
//

import SwiftUI
import SwiftData
import Combine

class PostsViewModel: ObservableObject {
    
    // MARK: - Properties
    
    var modelContext: ModelContext? = nil {
        didSet {
            if modelContext != nil {
                loadPostsFromSwiftData()
            }
        }
    }
    @AppStorage("hasLoadedInitialData") var hasLoadedInitialData = false // 🔥 Флаг для однократной загрузки

    private let fileManager = JSONFileManager.shared
    private let hapticManager = HapticService.shared
    private let networkService: NetworkService
    
    @Published var allPosts: [Post] = []
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
    
    // MARK: - AppStorage
    
    @AppStorage("selectedTheme") var selectedTheme: Theme = .system
    @AppStorage("localLastUpdated") var localLastUpdated: Date = Date.distantPast
    @AppStorage("isFirstImportPostsCompleted") var isFirstImportPostsCompleted: Bool = false {
        didSet {
            localLastUpdated = getLatestDateFromPosts(posts: allPosts) ?? .now
        }
    }
    
    // Filters
    @AppStorage("storedCategory") var storedCategory: String?
    @AppStorage("storedLevel") var storedLevel: StudyLevel?
    @AppStorage("storedFavorite") var storedFavorite: FavoriteChoice?
    @AppStorage("storedType") var storedType: PostType?
    @AppStorage("storedPlatform") var storedPlatform: Platform?
    @AppStorage("storedYear") var storedYear: String?
    @AppStorage("storedSortOption") var storedSortOption: SortOption?
    
    @Published var selectedCategory: String? = nil {
        didSet { storedCategory = selectedCategory }
    }
    @Published var selectedLevel: StudyLevel? = nil {
        didSet { storedLevel = selectedLevel }
    }
    @Published var selectedFavorite: FavoriteChoice? = nil {
        didSet { storedFavorite = selectedFavorite }
    }
    @Published var selectedType: PostType? = nil {
        didSet { storedType = selectedType }
    }
    @Published var selectedPlatform: Platform? = nil {
        didSet { storedPlatform = selectedPlatform }
    }
    @Published var selectedYear: String? = nil {
        didSet { storedYear = selectedYear }
    }
    @Published var selectedSortOption: SortOption? = nil {
        didSet { storedSortOption = selectedSortOption }
    }
    @Published var selectedPostId: String? = nil
    
    // MARK: - Init
    
    init(
        modelContext: ModelContext? = nil,
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
        
        // Настройка timezone
        if let utcTimeZone = TimeZone(secondsFromGMT: 0) {
            utcCalendar.timeZone = utcTimeZone
        }
        
        // Подписки для фильтрации
        setupSubscriptions()
    }
    
    // MARK: - SwiftData Operations
    
    /// Загрузка постов из SwiftData
    func loadPostsFromSwiftData() {
        
        guard let context = modelContext/*, !hasLoadedInitialData*/ else {
            print("⏩ Context не установлен")
            return
        }

        
        let descriptor = FetchDescriptor<Post>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do {
            allPosts = try context.fetch(descriptor)
            allYears = getAllYears()
            allCategories = getAllCategories()
            print("✅ Загружено \(allPosts.count) постов из SwiftData")
        } catch {
            errorMessage = "Ошибка загрузки данных"
            showErrorMessageAlert = true
            print("❌ Ошибка загрузки из SwiftData: \(error)")
        }
    }
    
    
    private var safeContext: ModelContext {
        guard let context = modelContext else {
            fatalError("ModelContext не установлен")
        }
        return context
    }

    /// Добавление нового поста
    func addPost(_ newPost: Post) {
        print("➕ Добавление нового поста")
        safeContext.insert(newPost)
        saveContext()
        loadPostsFromSwiftData()
    }
    
    /// Обновление поста
    func updatePost(_ updatedPost: Post) {
        print("✏️ Обновление поста")
        saveContext()
        loadPostsFromSwiftData()
    }
    
    /// Удаление поста
    func deletePost(post: Post?) {
        guard let post = post else {
            print("❌ Попытка удалить nil пост")
            return
        }
        
        safeContext.delete(post)
        saveContext()
        loadPostsFromSwiftData()
    }
    
    /// Удаление всех постов
    func eraseAllPosts(_ completion: @escaping () -> ()) {
        do {
            try safeContext.delete(model: Post.self)
            saveContext()
            loadPostsFromSwiftData()
            completion()
        } catch {
            errorMessage = "Ошибка удаления данных"
            showErrorMessageAlert = true
            print("❌ Ошибка удаления всех постов: \(error)")
        }
    }
    
    /// Переключение избранного
    func favoriteToggle(post: Post) {
        post.favoriteChoice = post.favoriteChoice == .yes ? .no : .yes
        saveContext()
        loadPostsFromSwiftData()
    }
    
    /// Оценка поста
    func ratePost(post: Post) {
        post.postRating = selectedRating
        saveContext()
        loadPostsFromSwiftData()
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
        
        saveContext()
        loadPostsFromSwiftData()
    }
    
    /// Сохранение контекста
    private func saveContext() {
        do {
            try safeContext.save()
            print("💾 SwiftData контекст сохранён")
            // 🌥️ iCloud автоматически синхронизирует изменения!
        } catch {
            errorMessage = "Ошибка сохранения данных"
            showErrorMessageAlert = true
            hapticManager.notification(type: .error)
            print("❌ Ошибка сохранения контекста: \(error)")
        }
    }
    
    // MARK: - Cloud Import (остаётся для импорта новых данных)
    
    func importPostsFromCloud(urlString: String = Constants.cloudPostsURL, completion: @escaping () -> Void) {
        errorMessage = nil
        showErrorMessageAlert = false
        
        // Явно указываем тип для generic параметра
        networkService.fetchDataFromURL { [weak self] (result: Result<[CodablePost], Error>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let cloudResponse):
                    print("☁️ Импортировано \(cloudResponse.count) постов из облака")
                    
                    // Фильтруем уникальные посты
                    let existingTitles = Set(self.allPosts.map { $0.title })
                    let existingIds = Set(self.allPosts.map { $0.id })
                    
                    let newPosts = cloudResponse
                        .filter { !existingTitles.contains($0.title) && !existingIds.contains($0.id) }
                        .map { PostMigrationHelper.convertFromCodable($0) }
                    
                    if !newPosts.isEmpty {
                        for post in newPosts {
                            self.safeContext.insert(post)
                        }
                        self.saveContext()
                        self.loadPostsFromSwiftData()
                        self.hapticManager.notification(type: .success)
                        print("✅ Добавлено \(newPosts.count) новых постов")
                    } else {
                        self.hapticManager.impact(style: .light)
                        print("ℹ️ Новых постов нет")
                    }
                    
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showErrorMessageAlert = true
                    self.hapticManager.notification(type: .error)
                    print("❌ Ошибка импорта: \(error)")
                }
                completion()
            }
        }
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
    
    func checkCloudForUpdates(completion: @escaping (Bool) -> Void) {
        networkService.fetchDataFromURL() { (result: Result<[CodablePost], Error>) in
            self.errorMessage = nil
            self.showErrorMessageAlert = false
            
            switch result {
            case .success(let cloudResponse):
                
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
                    
                    // 4. Конвертируем и добавляем только новые посты
//                    let existingIds = Set(localPosts.map { $0.id })
//                    
//                    let newCodablePosts = cloudPosts.filter { cloudPost in
//                        !existingIds.contains(cloudPost.id)
//                    }
//                    
//                    if !newCodablePosts.isEmpty {
//                        print("🍓 Importing \(newCodablePosts.count) new posts from cloud")
//                        
//                        // 5. Конвертируем CodablePost в Post (SwiftData)
//                        let newPosts = newCodablePosts.map { codablePost in
//                            PostMigrationHelper.convertFromCodable(codablePost)
//                        }
//                        
//                        // 6. Сохраняем в SwiftData
//                        for post in newPosts {
//                            self.modelContext.insert(post)
//                        }
//                        
//                        // 7. Сохраняем контекст и обновляем локальный список
//                        self.saveContext()
//                        self.loadPosts() // Если у вас есть такой метод
//                        
//                        print("🍓✅ Successfully imported \(newPosts.count) posts")
//                    } else {
//                        print("🍓☑️ No new posts to import (all already exist)")
//                    }
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
                    self.safeContext.insert(post)
                }
                // 6. Сохраняем контекст
                saveContext()
                // 7. Обновляем локальный список (если нужно)
                loadPostsFromSwiftData()
                
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
            let allPosts = try safeContext.fetch(descriptor)
            
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
    
    func checkIfAllFiltersAreEmpty() -> Bool {
        return selectedLevel == nil &&
               selectedFavorite == nil &&
               selectedType == nil &&
               selectedYear == nil &&
               selectedSortOption == nil
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
