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
    
    private let fileManager = JSONFileManager.shared
    private let hapticManager = HapticService.shared
    private let networkService: NetworkService
    private let noticeService = NoticeViewModel()
    
    @Published var allPosts: [Post] = [] {
        didSet {
            fileManager.saveData(
                allPosts,
                fileName: Constants.localPostsFileName
            ) { [weak self] result in
                
                self?.errorMessage = nil
                self?.showErrorMessageAlert = false

                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        print("✅ VM(allPosts - didSet): Posts saved successfully")
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                        self?.showErrorMessageAlert = true
                        self?.hapticManager.notification(type: .error)
                        print("❌ VM(allPosts - didSet): Failed to save posts: \(error)")
                    }
                }
            }
            allYears = getAllYears()
            allCategories = getAllCategories()
        }
    }
    
    @Published var filteredPosts: [Post] = []
    @Published var searchText: String = ""
    @Published var isFiltersEmpty: Bool = true
    @Published var isPostsUpdateAvailable: Bool = false
    
    // MARK: Stored preferances
    
    @AppStorage("homeTitleName") var homeTitleName: String = "SwiftUI materials"
    //    @AppStorage("isFirstAppLaunch") var isFirstAppLaunch: Bool = true
    @AppStorage("isFirstPostsLoad") var isFirstImportPostsCompleted: Bool = false {
        didSet { localLastUpdated = getLatestDateFromPosts(posts: allPosts) ?? .now }
    }
    @AppStorage("isTermsOfUseAccepted") var isTermsOfUseAccepted: Bool = false
    @AppStorage("isNotification") var isNotification: Bool = false
    
    // stored filters
    @AppStorage("storedCategory") var storedCategory: String?
    @AppStorage("storedLevel") var storedLevel: StudyLevel?
    @AppStorage("storedFavorite") var storedFavorite: FavoriteChoice?
    @AppStorage("storedType") var storedType: PostType?
    @AppStorage("storedPlatform") var storedPlatform: Platform?
    @AppStorage("storedYear") var storedYear: String?

    // stored the date of the Cloud posts last imported
    @AppStorage("localLastUpdated") var localLastUpdated: Date = (ISO8601DateFormatter().date(from: "2000-01-15T00:00:00Z") ?? Date())
    
    // setting filters
    @Published var selectedLevel: StudyLevel? = nil {
        didSet { storedLevel = selectedLevel }}
    @Published var selectedFavorite: FavoriteChoice? = nil {
        didSet { storedFavorite = selectedFavorite }}
    @Published var selectedType: PostType? = nil {
        didSet { storedType = selectedType }}
    @Published var selectedYear: String? = nil {
        didSet { storedYear = selectedYear }}
    @Published var selectedCategory: String? = nil {
        didSet {
            storedCategory = selectedCategory
            //            homeTitleName = selectedCategory ?? "Study materials"
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var errorMessage: String?
    @Published var showErrorMessageAlert = false
    
    private var utcCalendar = Calendar.current
    var allYears: [String]? = nil
    var allCategories: [String]? = nil
    var dispatchTime: DispatchTime { .now() + 2 }
    
    // MARK: INIT() SECTION
    
    init(
        networkService: NetworkService = NetworkService(baseURL: Constants.cloudPostsURL)
    ) {
        self.networkService = networkService

        print("🍓VM(init): Last update date: \(localLastUpdated.formatted(date: .abbreviated, time: .shortened))")
        
        // checking if the local JSON file with posts exists
        if fileManager.checkIfFileExists(fileName: Constants.localPostsFileName) {
            fileManager.loadData(
                fileName: Constants.localPostsFileName
            ) { [weak self] (result: Result<[Post], FileStorageError>) in
                
                self?.errorMessage = nil
                self?.showErrorMessageAlert = false

                DispatchQueue.main.async {
                    switch result {
                    case .success(let posts):
                        self?.allPosts = posts
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                        self?.showErrorMessageAlert = true
                        print("🍓VM(init): Failed to load posts: \(error)")
                    }
                }
            }
                    
            if !self.allPosts.isEmpty {
                checkCloudForUpdates { hasUpdates in
                    if hasUpdates {
                        self.isPostsUpdateAvailable = true
                        print(self.isPostsUpdateAvailable.description)
                    }
                }
            }
            
            self.filteredPosts = self.allPosts
        }
        
        // filters initilazation
        self.selectedCategory = self.storedCategory
        self.selectedLevel = self.storedLevel
        self.selectedFavorite = self.storedFavorite
        self.selectedType = self.storedType
        self.selectedYear = self.storedYear
        self.isFiltersEmpty = checkIfAllFiltersAreEmpty()
        
        if let utcTimeZone = TimeZone(secondsFromGMT: 0) {
            utcCalendar.timeZone = utcTimeZone
            print("🍓 VM(init): TimeZone is set successfully")
        } else {
            print("🍓❌ VM(init): TimeZone is not set")
        }
                
        // initiating subscriptions
        addSubscribers()
        
    }
    
    // MARK: PRIVATE FUNCTIONS
    
    private func addSubscribers() {
        
        let filters = $selectedLevel
            .combineLatest($selectedFavorite, $selectedType, $selectedYear)
        
        // Subscribe on change of seach text and filters
        $searchText
            .combineLatest(filters, $selectedCategory)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map { searchText, filters, category -> [Post] in
                let (level, favorite, type, year) = filters
                // Getting posts filtered
                let filtered = self.filterPosts(
                    allPosts: self.allPosts,
                    category: category,
                    level: level,
                    favorite: favorite,
                    type: type,
                    year: year,
                )
                // Applying search text
                return self.searchPosts(posts: filtered)
            }
            .sink { [weak self] searchedPosts in
                self?.filteredPosts = searchedPosts
            }
            .store(in: &cancellables)
        
        // Subscribe on change of posts
        $allPosts
            .combineLatest($searchText, filters, $selectedCategory)
            .map { posts, searchText, filters, category -> [Post] in
                let (level, favorite, type, year) = filters
                // Getting posts filtered
                let filtered = self.filterPosts(
                    allPosts: posts,
                    category: category,
                    level: level,
                    favorite: favorite,
                    type: type,
                    year: year
                )
                
                // Applying search text
                return self.searchPosts(posts: filtered)
            }
            .sink { [weak self] posts in
                self?.filteredPosts = posts
                
                //                guard let self = self else { return }
                //                if !posts.isEmpty {
                //                    self.filteredPosts.removeAll()
                //                    self.filteredPosts = posts
                //
                //                }
            }
            .store(in: &cancellables)
    }
    
    private func filterPosts(
        allPosts: [Post],
        category: String?,
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
                let postYear = String(utcCalendar.component(.year, from: post.postDate ?? Date()))
                let matchesYear = year == nil || postYear == year
                
                return matchesLevel && matchesFavorite && matchesType && matchesYear
            }
            
            if let category = category {
                return filteredPosts.filter { $0.category == category }
            } else {
                return filteredPosts
            }
            
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
    
    
    // MARK: PUBLIC FUNCTIONS
    
    func addPost(_ newPost: Post) {
        print("🍓 VM(addPost): Adding a new post")
        allPosts.append(newPost)
    }
    
    func updatePost(_ updatedPost: Post) {
        if let index = allPosts.firstIndex(where: { $0.id == updatedPost.id }) {
            print("🍓 VM(updatePost): Updating a current edited post")
            allPosts[index] = updatedPost
        } else {
            print("🍓❌ VM(updatePost): Can't find the index")
        }
    }
    
    func deletePost(post: Post?) {
        if let validPost = post {
            if let index = allPosts.firstIndex(of: validPost) {
                allPosts.remove(at: index)
            }
        } else {
            print("🍓VM.deletePost: passed post is nil")
        }
    }
    
    func eraseAllPosts(_ completion: @escaping () -> ()) {
        //        filteredPosts = []
        allPosts = []
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
            //            fileManager.savePosts(allPosts)
        }
    }
    
    /// Import manually collected posts for the development purpose.
    ///
    /// Manually collected posts are also used for creating curated posts in the Cloud .
    ///
    /// ```
    /// loadPersistentPosts() -> Void
    /// ```
    ///
    /// - Warning: This app is made for self study purpose only.
    /// - Returns: Returns a boolean result or error within completion handler.
    
    func loadPersistentPosts(_ completion: @escaping () -> ()) {
        
        let receivedPosts: [Post] = DevData.postsForCloud
        
        // Skipping posts with the same title - make posts unique by title
        let newPosts = receivedPosts.filter { newPost in
            !allPosts.contains(where: { $0.title == newPost.title })
        }
        
        if !newPosts.isEmpty {
            allPosts.append(contentsOf: newPosts)
        }
        completion()
    }
    
    func getFilePath(fileName: String) -> Result<URL, FileStorageError> {
        
        let urlResult = fileManager.getFileURL(fileName: fileName)
        
        switch urlResult {
        case .success(let url):
            print("✅ FM(getFileURL): Successfully got file url: \(url).")
            return .success(url)
        case .failure(let error):
            return .failure(error)
        }
    }

    
    /// Import posts from the Cloud using the specified URL string.
    ///
    /// Imported posts from the Cloud are processed as follows:
    ///  - Only posts with unique titles are selected.
    ///  - Only posts with unique ID are selected (just in case).
    ///  - The selected posts are added to the current posts.
    ///  - The date of new posts is saved for subsequent checking.
    ///
    ///
    /// ```
    /// checkCloudForUpdates() -> Void
    /// ```
    ///
    /// - Warning: This app is made for self study purpose only.
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
    
//    @State private var errorMessage = ""
    
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

//            let postsAfterCheckForUniqueTitle = posts.filter { post in
//                !vm.allPosts.contains(where: { $0.title == post.title })
//            }
//
//            let postsAfterCheckForUniqueID = postsAfterCheckForUniqueTitle.filter { post in
//                !vm.allPosts.contains(where: { $0.id == post.id })
//            }
        return postsAfterCheckForUniqueID
    }
    
//    private func showError(_ message: String) {
//        errorMessage = message
//        showErrorMessageAlert = true
//        hapticManager.notification(type: .error)
//    }
    
    
    
    /// Checking for available posts update in the Cloud.
    ///
    /// The result is used to check and then warn an user about an available posts update in the Cloud.
    ///
    /// ```
    /// checkCloudForUpdates() -> Void
    /// ```
    ///
    /// - Warning: This app is made for self study purpose only.
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
    
    /// Checking if a title of a new/editing post is not in the array of existing posts.
    ///
    /// The result is used to avoid doublied posts with the same titles.
    ///
    /// ```
    /// checkNewPostForUniqueTitle() -> Bool
    /// ```
    ///
    /// - Warning: This app is made for self study purpose only.
    /// - Returns: Returns a boolean, true if a title of a post is unique and false if not unique.
    
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
    /// The result is used in different snip codes: in FilterButton to change its apearance in its parent UI, also when filtering posts, etc.
    ///
    /// ```
    /// checkIfAllFilterAreEmpty() -> Bool
    /// ```
    ///
    /// - Warning: This app is made for self study purpose only.
    /// - Returns: Returns a boolean, true if all filters are not set (nil) and false if at least one is set.
    ///
    func checkIfAllFiltersAreEmpty() -> Bool {
        // check if all filters are empty
        if selectedLevel == nil &&
            selectedFavorite == nil &&
            selectedType == nil &&
            selectedYear == nil {
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
    /// - Warning: This app is made for self study purpose only.
    /// - Returns: Returns an array of strings with the values of years available in the current posts.
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
        print("✅ VM: Final years list: \(result)")
        return result
    }
    
    // get a list of categories presented in the local posts
    
    private func getAllCategories() -> [String]? {
        
        return Array(Set(allPosts.map { $0.category })).sorted()
    }
    
}



//        print("VM(init): start the TEST testDetailedDecoding()")
//        testDetailedDecoding()
//        print("VM(init): end the TEST testDetailedDecoding()")
//
//        print("VM(init): start the TEST validateJSONFile()")
//        validateJSONFile()
//        print("VM(init): end the TEST validateJSONFile()")




//    func testDetailedDecoding() {
//        let testJSON = """
//        [
//          {
//            "postType" : "post",
//            "notes" : "",
//            "title" : "Styling SwiftUI Text Views",
//            "urlString" : "https://www.youtube.com/watch?v=rbtIcKKxQ38",
//            "category" : "SwiftUI",
//            "postPlatform" : "youtube",
//            "favoriteChoice" : "no",
//            "origin" : "cloud",
//            "postDate" : "2021-05-07T00:00:00Z",
//            "intro" : "Test intro",
//            "author" : "Stewart Lynch",
//            "studyLevel" : "middle",
//            "date" : "2025-11-08T13:45:07Z",
//            "id" : "F9E12A88-0E62-402D-B6AD-1A1F895F5421"
//          }
//        ]
//        """
//
//        do {
//            let data = testJSON.data(using: .utf8)!
//            print("🍓 JSON data length: \(data.count) bytes")
//
//            // Try decode as generil type
//            let anyObject = try JSONSerialization.jsonObject(with: data, options: [])
//            print("✅ JSONSerialization success: \(anyObject)")
//
//            // Try decode as generil type [Post]
//            let posts = try JSONDecoder.appDecoder.decode([Post].self, from: data)
//            print("✅ Post decoding SUCCESS: \(posts.count) posts")
//
//        } catch {
//            print("❌ FAILED: \(error)")
//
//            // Detailed information about the decoding error
//            if let decodingError = error as? DecodingError {
//                switch decodingError {
//                case .typeMismatch(let type, let context):
//                    print("🔍 Type mismatch:")
//                    print("   - Expected type: \(type)")
//                    print("   - Coding path: \(context.codingPath)")
//                    print("   - Debug: \(context.debugDescription)")
//                case .valueNotFound(let type, let context):
//                    print("🔍 Value not found:")
//                    print("   - Type: \(type)")
//                    print("   - Coding path: \(context.codingPath)")
//                case .keyNotFound(let key, let context):
//                    print("🔍 Key not found:")
//                    print("   - Missing key: \(key)")
//                    print("   - Coding path: \(context.codingPath)")
//                    print("   - Available keys in container")
//                case .dataCorrupted(let context):
//                    print("🔍 Data corrupted:")
//                    print("   - Context: \(context)")
//                    if let underlyingError = context.underlyingError {
//                        print("   - Underlying error: \(underlyingError)")
//                    }
//                @unknown default:
//                    print("🔍 Unknown decoding error")
//                }
//            }
//        }
//    }
//
//
//    func validateJSONFile() {
//
//        if let url = Bundle.main.url(forResource: "cloudPosts", withExtension: "json"),
//           let data = try? Data(contentsOf: url) {
//
//            print("📁 File exists, size: \(data.count) bytes")
//
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("📄 File content: \(jsonString.prefix(200))...")
//            }
//
//            do {
//                let posts = try JSONDecoder.appDecoder.decode([Post].self, from: data)
//                print("✅ Local file decoding SUCCESS: \(posts.count) posts")
//            } catch {
//                print("❌ Local file decoding FAILED: \(error)")
//            }
//        } else {
//            print("❌ JSON file not found")
//        }
//    }

