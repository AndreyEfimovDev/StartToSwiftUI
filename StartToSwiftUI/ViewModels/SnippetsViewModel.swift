//
//  SnippetsViewModel.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.03.2026.
//

import SwiftUI
import SwiftData
import Combine
import CoreData

// MARK: - SnippetsViewModel
//
// Simplified compared to PostsViewModel because snippets are curated-only:
// - No add / edit / delete by user
// - No draft, progress, rating, studyLevel
// - StatusOptions: .active and .hidden only (no .deleted)
// - FavoriteChoice: available
// - Origin: .local not used (all snippets come from Firestore → .cloudNew / .cloud)

@MainActor
final class SnippetsViewModel: ObservableObject {

    // MARK: - Properties
    let dataSource: SnippetsDataSourceProtocol
    let hapticManager = HapticManager.shared
    let appStateManager: AppSyncStateManager?
    let fbSnippetsManager: FBSnippetsManagerProtocol

    /// All snippets from SwiftData (.active + .hidden)
    @Published var allSnippets: [CodeSnippet] = []

    /// Snippets after filtering, search, sort — only .active
    @Published var filteredSnippets: [CodeSnippet] = []

    @Published var selectedSnippet: CodeSnippet? = nil
    @Published var searchText: String = ""
    @Published var isFiltersEmpty: Bool = true
    @Published var reshuffleToken = UUID()

    @Published var errorMessage: String?
    @Published var showErrorMessageAlert = false

    var cancellables = Set<AnyCancellable>()
    var utcCalendar = Calendar.current

    var allYears: [String]? = nil
    var allCategories: [String]? = nil
    let mainCategory: String = Constants.mainCategory
    var randomSortOrder: [String] = []
    var dispatchTime: DispatchTime { .now() + 1.5 }

    private var lastLoadTime: Date = Date(timeIntervalSince1970: 0)
    private let minLoadInterval: TimeInterval = 3

    // MARK: - Computed Properties
    var swiftDataSource: SwiftDataSnippetsDataSource? {
        dataSource as? SwiftDataSnippetsDataSource
    }
    var isSwiftData: Bool { swiftDataSource != nil }

    // MARK: - AppStorage (prefix "snippet_" avoids collision with PostsViewModel)
    @AppStorage("snippet_storedCategory") var storedCategory: String?
    @Published var selectedCategory: String? = nil {
        didSet { storedCategory = selectedCategory }
    }

    @AppStorage("snippet_storedYear") var storedYear: String?
    @Published var selectedYear: String? = nil {
        didSet { storedYear = selectedYear }
    }

    @AppStorage("snippet_storedSortOption") var storedSortOption: SortOption = .notSorted
    @Published var selectedSortOption: SortOption = .notSorted {
        didSet {
            storedSortOption = selectedSortOption
            if selectedSortOption == .random { reshuffleSnippets() }
        }
    }

    // MARK: - Computed Properties for UI

    var hasHidden: Bool { allSnippets.contains { $0.status == .hidden } }
    var hiddenCount: Int { allSnippets.filter { $0.status == .hidden }.count }

    var cloudSnippetsCount: Int {
        allSnippets.filter { $0.origin == .cloud || $0.origin == .cloudNew }.count
    }
    var hasCloudSnippets: Bool {
        allSnippets.contains { $0.origin == .cloud || $0.origin == .cloudNew }
    }
    var shouldShowImportFromCloud: Bool { !hasCloudSnippets }

    var lastDateSnippetsLoaded: Date? {
        appStateManager?.getLastDateOfSnippetsLoaded()
    }

    // MARK: - Init
    init(
        dataSource: SnippetsDataSourceProtocol,
        fbSnippetsManager: FBSnippetsManagerProtocol = FBSnippetsManager()
    ) {
        self.dataSource = dataSource
        self.fbSnippetsManager = fbSnippetsManager

        if let swiftDataSource = dataSource as? SwiftDataSnippetsDataSource {
            self.appStateManager = AppSyncStateManager(modelContext: swiftDataSource.modelContext)
        } else {
            self.appStateManager = nil
        }

        setupTimezone()
        restoreFilters()
    }

    convenience init(
        modelContext: ModelContext,
        fbSnippetsManager: FBSnippetsManagerProtocol = FBSnippetsManager()
    ) {
        self.init(
            dataSource: SwiftDataSnippetsDataSource(modelContext: modelContext),
            fbSnippetsManager: fbSnippetsManager
        )
    }

    func start() {
        setupSubscriptions()
        setupSubscriptionForChangesInCloud()
    }

    // MARK: - Setup
    private func setupTimezone() {
        if let utcTimeZone = TimeZone(secondsFromGMT: 0) {
            utcCalendar.timeZone = utcTimeZone
        }
    }

    // MARK: - iCloud Sync Subscription
    private func setupSubscriptionForChangesInCloud() {
        NotificationCenter.default.publisher(for: Notification.Name.NSPersistentStoreRemoteChange)
            .receive(on: DispatchQueue.main)
            .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                let now = Date()
                guard now.timeIntervalSince(self.lastLoadTime) >= self.minLoadInterval else {
                    log("Snippets cloud sync skipped (too soon)", level: .debug)
                    return
                }
                self.loadSnippetsFromSwiftData()
                log("Cloud snippets sync subscription run", level: .info)
            }
            .store(in: &cancellables)
    }

    func restoreFilters() {
        selectedCategory = storedCategory
        selectedYear = storedYear
        selectedSortOption = storedSortOption
        isFiltersEmpty = checkIfAllFiltersAreEmpty()
    }

    // MARK: - SwiftData Load
    func loadSnippetsFromSwiftData() {
        lastLoadTime = Date()
        do {
            allSnippets = try dataSource.fetchSnippets()
            removeDuplicateSnippets()
            allYears = getAllYears()
            allCategories = getAllCategories()
            log("📊 Loaded \(allSnippets.count) snippets from SwiftData", level: .debug)
        } catch {
            handleError(error, message: "Error loading snippets")
        }
    }

    // MARK: - Duplicate Removal (two-pass, identical to PostsViewModel)
    private func removeDuplicateSnippets() {
        var toDelete: [CodeSnippet] = []

        // Pass 1: by ID
        let idGroups = Dictionary(grouping: allSnippets, by: \.id).filter { $0.value.count > 1 }
        for (id, list) in idGroups {
            if let keep = list.sorted(by: { $0.date < $1.date }).first {
                for s in list where s.persistentModelID != keep.persistentModelID {
                    toDelete.append(s)
                    log("🗑️ Duplicate snippet by ID \(id): '\(s.title)'", level: .info)
                }
            }
        }

        // Pass 2: by title (excluding already-marked)
        let markedIDs = Set(toDelete.map { $0.persistentModelID })
        let remaining = allSnippets.filter { !markedIDs.contains($0.persistentModelID) }
        let titleGroups = Dictionary(grouping: remaining, by: \.title).filter { $0.value.count > 1 }
        for (title, list) in titleGroups {
            if let keep = list.sorted(by: { $0.date < $1.date }).first {
                for s in list where s.persistentModelID != keep.persistentModelID {
                    toDelete.append(s)
                    log("🗑️ Duplicate snippet by title '\(title)'", level: .info)
                }
            }
        }

        guard !toDelete.isEmpty else { return }
        toDelete.forEach { dataSource.delete($0) }

        do {
            try dataSource.save()
            allSnippets = try dataSource.fetchSnippets()
            log("✅ Removed \(toDelete.count) duplicate snippets", level: .info)
        } catch {
            handleError(error, message: "Error removing duplicate snippets")
        }
    }

    // MARK: - Status Management
    func setSnippetActive(_ snippet: CodeSnippet) {
        snippet.status = .active
        saveContextAndReload()
    }

    func setSnippetHidden(_ snippet: CodeSnippet) {
        snippet.status = .hidden
        saveContextAndReload()
    }

    // MARK: - Favourite
    func favoriteToggle(_ snippet: CodeSnippet) {
        snippet.favoriteChoice = snippet.favoriteChoice == .yes ? .no : .yes
        saveContextAndReload()
    }

    // MARK: - Origin
    /// Mark as .cloud after user opens a .cloudNew snippet for the first time
    func updateSnippetOrigin(_ snippet: CodeSnippet) {
        snippet.origin = .cloud
        saveContextAndReload()
    }

    // MARK: - Helpers
    func getSnippet(id: String) -> CodeSnippet? {
        allSnippets.first { $0.id == id }
    }

    func saveContextAndReload() {
        do {
            try dataSource.save()
            loadSnippetsFromSwiftData()
        } catch {
            handleError(error, message: "Error saving snippet data")
        }
    }

    func filterUniqueSnippets(from fbResponse: [FBSnippetModel]) -> [FBSnippetModel] {
        let existingTitles = Set(allSnippets.map { $0.title })
        let existingIds = Set(allSnippets.map { $0.id })
        return fbResponse.filter {
            !existingTitles.contains($0.title) && !existingIds.contains($0.snippetId)
        }
    }

    func getLatestDateFromSnippets(_ snippets: [CodeSnippet]) -> Date? {
        snippets.max { $0.date < $1.date }?.date
    }

    private func getAllYears() -> [String]? {
        let years = allSnippets.map { String(utcCalendar.component(.year, from: $0.date)) }
        let unique = Array(Set(years)).sorted()
        return unique.isEmpty ? nil : unique
    }

    private func getAllCategories() -> [String]? {
        let cats = Array(Set(allSnippets.map { $0.category })).sorted()
        return cats.isEmpty ? nil : cats
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
}
