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
    
    @Published var allPosts: [Post] = []
    @Published var filteredPosts: [Post] = []
    @Published var searchText: String = ""
    @Published var isFiltersEmpty: Bool = true
    
    @AppStorage("homeTitleName") var homeTitleName: String = "SwiftUI materials"
    
    // GitHub cloud url on JSON file with pre-loaded posts
    let cloudPostsURLoriginal: String = "https://raw.githubusercontent.com/AndreyEfimovDev/StartToSwiftUI/refs/heads/main/cloudPosts.json"
    
    @AppStorage("cloudPostsURL") var cloudPostsURL: String = "https://raw.githubusercontent.com/AndreyEfimovDev/StartToSwiftUI/refs/heads/main/cloudPosts.json"
        
    // stored filters
    @AppStorage("storedLevel") var storedLevel: StudyLevel?
    @AppStorage("storedFavorite") var storedFavorite: FavoriteChoice?
    @AppStorage("storedType") var storedType: PostType?
    @AppStorage("storedPlatform") var storedPlatform: Platform?
    @AppStorage("storedYear") var storedYear: String?
    
    // Stored draft of the port from AddEdit
    @AppStorage("isPostDraftSaved") var isPostDraftSaved: Bool = false
    @AppStorage("titlePostSaved") var titlePostSaved: String?
    @AppStorage("introPostSaved") var introPostSaved: String?
    @AppStorage("authorPostSaved") var authorPostSaved: String?
    @AppStorage("typePostSaved") var typePostSaved: PostType?
    @AppStorage("urlStringPostSaved") var urlStringPostSaved: String?
    @AppStorage("platformPostSaved") var platformPostSaved: Platform?
    @AppStorage("datePostSaved") var datePostSaved: Date?
    @AppStorage("studyLevelPostSaved") var studyLevelPostSaved: StudyLevel?
    @AppStorage("favoriteChoicePostSaved") var favoriteChoicePostSaved: FavoriteChoice?
    @AppStorage("additionalTextPostSaved") var additionalTextPostSaved: String?
    
    // MARK: Stored preferances
    
    @AppStorage("isNotification") var isNotification: Bool = false
    // stored the date of the Cloud posts last imported
    @AppStorage("localLastUpdated") var localLastUpdated: Date = (ISO8601DateFormatter().date(from: "2000-01-15T00:00:00Z") ?? Date())
    @Published var isPostsUpdateAvailable: Bool = false

    // setting filters
    @Published var selectedLevel: StudyLevel? = nil {
        didSet { storedLevel = selectedLevel }}
    @Published var selectedFavorite: FavoriteChoice? = nil {
        didSet { storedFavorite = selectedFavorite }}
    @Published var selectedType: PostType? = nil {
        didSet { storedType = selectedType }}
    @Published var selectedYear: String? = nil {
        didSet { storedYear = selectedYear }}
    
    private var cancellables = Set<AnyCancellable>()
    private let fileManager = FileStorageService.shared
    private let hapticManager = HapticService.shared
    private let networkService = NetworkService()
    
    @Published var isLoadingFromCloud = false
    @Published var cloudImportError: String?
    @Published var showCloudImportAlert = false
    
    private var utcCalendar = Calendar.current
    var listOfYearsInPosts: [String]? = nil
    var dispatchTime: DispatchTime { .now() + 2 }
    
    // MARK: INIT() SECTION
    
    init() {
        
        print("VM(init): Last update date: \(localLastUpdated.formatted(date: .abbreviated, time: .shortened))")
                
        self.allPosts = fileManager.loadPosts()
        
        // getting a list of years presented in current posts and checking for updates
        if !self.allPosts.isEmpty {
            
            self.listOfYearsInPosts = getListOfPostedYearsOfPosts()
            checkCloudForUpdates { hasUpdates in
                if hasUpdates {
                    self.isPostsUpdateAvailable = true
                    print("VM(init): Posts update is available")
                    print(self.isPostsUpdateAvailable.description)
                }
            }
        }
        
        self.filteredPosts = self.allPosts
        
        // filters initilazation
        self.selectedLevel = self.storedLevel
        self.selectedFavorite = self.storedFavorite
        self.selectedType = self.storedType
        self.selectedYear = self.storedYear
        self.isFiltersEmpty = checkIfAllFiltersAreEmpty()
        
        if let utcTimeZone = TimeZone(secondsFromGMT: 0) {
            utcCalendar.timeZone = utcTimeZone
            print("✅ VM(init): TimeZone is set successfully")
        } else {
            print("❌ VM(init): TimeZone is not set")
        }
        
        // initiating subscriptions
        addSubscribers()
    }
    
    // MARK: PRIVATE FUNCTIONS
    
    private func addSubscribers() {
        
        // Subscribe on change of filters
//        let filters = $selectedLevel
//            .combineLatest($selectedFavorite, $selectedType)
        $selectedYear
            .combineLatest($selectedLevel, $selectedFavorite, $selectedType)
            .map {year, level, favorite, type -> [Post] in
//                let (level, favorite, type) = filters
                return self.filterPosts(
                    allPosts: self.allPosts,
                    level: level,
                    favorite: favorite,
                    type: type,
                    year: year
                )
            }
            .sink { [weak self] filtered in
                self?.filteredPosts = filtered
            }
            .store(in: &cancellables)
        
        $searchText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map { text -> [Post] in
                guard !text.isEmpty else {
                    return self.filteredPosts
                }
                let searchedPosts = self.filteredPosts.filter( {
                    $0.title.lowercased().contains(text.lowercased()) ||
                    $0.intro.lowercased().contains(text.lowercased())  ||
                    $0.author.lowercased().contains(text.lowercased()) ||
                    $0.additionalText.lowercased().contains(text.lowercased())
                } )
                return searchedPosts
            }
            .sink { [weak self] searchedPosts in
                self?.filteredPosts = searchedPosts
            }
            .store(in: &cancellables)
        
        // Subscribe on change of posts
        $allPosts
            .map { posts -> [Post] in
                return self.filterPosts(
                    allPosts: posts,
                    level: self.selectedLevel,
                    favorite: self.selectedFavorite,
                    type: self.selectedType,
                    year: self.selectedYear
                )
            }
            .sink { [weak self] posts in
                guard let self = self else { return }
                if !posts.isEmpty {
                    self.filteredPosts.removeAll()
                    self.filteredPosts = posts
                    
                }
            }
            .store(in: &cancellables)
    }
    
    private func filterPosts(
        allPosts: [Post],
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
            return allPosts.filter { post in
                let matchesLevel = level == nil || post.studyLevel == level
                let matchesFavorite = favorite == nil || post.favoriteChoice == favorite
                let matchesType = type == nil || post.postType == type

                let postYear = String(utcCalendar.component(.year, from: post.postDate ?? Date()))
                let matchesYear = year == nil || postYear == year
                
                return matchesLevel && matchesFavorite && matchesType && matchesYear
            }
        }
    
    private func searchPosts() -> [Post] {
        guard !searchText.isEmpty else {
            return filteredPosts
        }
        let searchedPosts = filteredPosts.filter( {
            $0.title.lowercased().contains(searchText.lowercased()) ||
            $0.intro.lowercased().contains(searchText.lowercased())  ||
            $0.author.lowercased().contains(searchText.lowercased()) ||
            $0.additionalText.lowercased().contains(searchText.lowercased())
        } )
        return searchedPosts
    }

    
    // MARK: PUBLIC FUNCTIONS
    
    func addPost(_ newPost: Post) {
        print("✅ VM(addPost): Adding a new post")
        allPosts.append(newPost)
        fileManager.savePosts(allPosts)
    }
    
    func updatePost(_ updatedPost: Post) {
        if let index = allPosts.firstIndex(where: { $0.id == updatedPost.id }) {
            print("✅ VM(updatePost): Updating a current edited post")
            allPosts[index] = updatedPost
            listOfYearsInPosts = getListOfPostedYearsOfPosts()
            fileManager.savePosts(allPosts)
        } else {
            print("❌ VM(updatePost): Can't find the index")
        }
    }
    
    func deletePost(post: Post?) {
        
        if let validPost = post {
            if let index = allPosts.firstIndex(of: validPost) {
                allPosts.remove(at: index)
                listOfYearsInPosts = getListOfPostedYearsOfPosts()
                fileManager.savePosts(allPosts)
            }
        } else {
            print("VM.deletePost: passed post is nil")
        }
        
    }
    
    func eraseAllPosts(_ completion: @escaping () -> ()) {
        
        filteredPosts = []
        allPosts = []
        listOfYearsInPosts = getListOfPostedYearsOfPosts()
        fileManager.savePosts(allPosts)
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
            fileManager.savePosts(allPosts)
        }
    }
    
    /// Import manually pre-saved posts mainly for the development purpose.
    ///
    /// Manually pre-saved posts are also used for creating remote posts in the Cloud .
    ///
    /// ```
    /// loadPersistentPosts() -> Void
    /// ```
    ///
    /// - Warning: This app is made for self study purpose only.
    /// - Returns: Returns a boolean result or error within completion handler.

    func loadPersistentPosts(_ completion: @escaping () -> ()) {
        
        let receivedPosts: [Post] = DevPreview.postsForCloud
        
        // Skipping posts with the same title - make posts unique by title
        let newPosts = receivedPosts.filter { newPost in
            !allPosts.contains(where: { $0.title == newPost.title })
        }
        
        if !newPosts.isEmpty {
            allPosts.append(contentsOf: newPosts)
            fileManager.savePosts(allPosts)
            listOfYearsInPosts = getListOfPostedYearsOfPosts()
        }
        completion()
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
    
    func importPostsFromCloud(urlString: String = Constants.cloudPostsURL, completion: @escaping () -> Void = {}) {

        cloudImportError = nil
        
        networkService.fetchCloudPosts(from: urlString) { [weak self] result in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let cloudResponse):
                    
                    // Selecting Cloud posts with unique Titles only -  - do not append such posts from Cloud
                    let newCloudPosts1stCheck = cloudResponse.cloudPosts.filter { newPost in
                        !(self?.allPosts.contains(where: { $0.title == newPost.title }) ?? false)
                    }
                    
                    // Checking Cloud posts with the same ID to local App posts - do not append such posts from Cloud
                    let newCloudPosts2ndCheck = newCloudPosts1stCheck.filter { newPost in
                        !(self?.allPosts.contains(where: { $0.id == newPost.id }) ?? false)
                    }

                    if !newCloudPosts2ndCheck.isEmpty {
                        // Updating App posts
                        self?.allPosts.append(contentsOf: newCloudPosts2ndCheck)
                        self?.fileManager.savePosts(self?.allPosts ?? [])
                        
                        self?.hapticManager.notification(type: .success)
                        // Saving the date stamp of the Cloud posts
                        print(self?.localLastUpdated.formatted(date: .abbreviated, time: .shortened) ?? Date())
                        self?.localLastUpdated = cloudResponse.dateStamp
                        print(cloudResponse.dateStamp.formatted(date: .abbreviated, time: .shortened))

                        print("✅ Successfully imported \(newCloudPosts2ndCheck.count) posts from cloud")
                        
                    } else {
                        print("✅ No new posts from cloud. \(newCloudPosts2ndCheck.count) imported posts ")
                        self?.hapticManager.impact(style: .heavy)
                    }
                    
                    self?.cloudImportError = nil

                case .failure(let error):
                    self?.cloudImportError = error.localizedDescription
                    self?.showCloudImportAlert = true
                    
                    // Haptic feedback for error
                    self?.hapticManager.notification(type: .error)
                    
                    print("❌ Cloud import error: \(error.localizedDescription)")
                }
                completion()
            }
        }
    }
    
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
        networkService.fetchCloudPosts(from: Constants.cloudPostsURL) { result in
            switch result {
            case .success(let cloudResponse):
                let hasUpdates = cloudResponse.dateStamp > self.localLastUpdated
                DispatchQueue.main.async {
                    completion(hasUpdates)
                }
            case .failure (let error):
                self.cloudImportError = error.localizedDescription
                self.showCloudImportAlert = true
                self.hapticManager.notification(type: .error)

                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
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
    
    func checkNewPostForUniqueTitle(_ postTitle: String, editingPostId: UUID?) -> Bool {
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
//            selectedLanguage == nil &&
            selectedType == nil &&
            selectedYear == nil {
            return true
        } else {
            return false
        }
    }
    
    /// Gets a list of years presented in current posts.
    ///
    /// The result is used in the FilterSheetView for selecting a year for the filter.
    ///
    /// ```
    /// getListOfPostedYearsOfPosts() -> [String]?
    /// ```
    ///
    /// - Warning: This app is made for self study purpose only.
    /// - Returns: Returns an array of strings with the values of years available in the current posts.
    ///
    
    private func getListOfPostedYearsOfPosts() -> [String]? {
        
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
    
}
