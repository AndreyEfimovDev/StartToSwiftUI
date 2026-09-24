//
//  PostsFilteringTests.swift
//  StartToSwiftUIUnitTests
//
//  Tests for the PostsViewModel+Filtering Combine pipeline (category/filter/
//  search/sort). filterPosts/searchPosts/applySorting are private, so all
//  assertions go through the public filteredPosts after the pipeline settles.
//

import XCTest
@testable import StartToSwiftUI

@MainActor
final class PostsFilteringTests: XCTestCase {

    var vm: PostsViewModel!

    // Пайплайн начинает эмитить только после первого срабатывания
    // debounce(0.5s) на searchText — берём с запасом.
    private let pipelineDelay: UInt64 = 700_000_000

    override func setUp() async throws {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }

    override func tearDown() {
        vm = nil
    }

    private func makeVM(posts: [Post]) async throws -> PostsViewModel {
        let viewModel = PostsViewModel(
            dataSource: MockPostsDataSource(posts: posts),
            fbPostsManager: MockFBPostsManager.mockPosts([]),
            services: .make()
        )
        viewModel.start()
        viewModel.loadPostsFromSwiftData(removeDuplicates: false)
        try await Task.sleep(nanoseconds: pipelineDelay)
        return viewModel
    }

    private func post(
        title: String = "Title",
        intro: String = "",
        author: String = "",
        category: String = Constants.mainCategory,
        postType: PostType = .post,
        postPlatform: Platform = .youtube,
        postDate: Date? = nil,
        studyLevel: StudyLevel = .beginner,
        favoriteChoice: FavoriteChoice = .no,
        notes: String = "",
        date: Date = .now
    ) -> Post {
        Post(
            category: category,
            title: title,
            intro: intro,
            author: author,
            postType: postType,
            postPlatform: postPlatform,
            postDate: postDate,
            studyLevel: studyLevel,
            favoriteChoice: favoriteChoice,
            notes: notes,
            date: date
        )
    }

    // MARK: - Category

    func test_onlyMainCategoryPosts_areIncluded() async throws {
        let inCategory = post(title: "In category")
        let otherCategory = post(title: "Other category", category: "SomeOtherCategory")
        vm = try await makeVM(posts: [inCategory, otherCategory])

        XCTAssertEqual(vm.filteredPosts.map(\.title), ["In category"])
    }

    // MARK: - No filters

    func test_noFiltersSelected_returnsAllCategoryPosts() async throws {
        let a = post(title: "A")
        let b = post(title: "B")
        vm = try await makeVM(posts: [a, b])

        XCTAssertEqual(Set(vm.filteredPosts.map(\.title)), ["A", "B"])
    }

    // MARK: - Single filters

    func test_filterByLevel_returnsOnlyMatching() async throws {
        let beginner = post(title: "Beginner", studyLevel: .beginner)
        let advanced = post(title: "Advanced", studyLevel: .advanced)
        vm = try await makeVM(posts: [beginner, advanced])

        vm.selectedLevel = .advanced
        try await Task.sleep(nanoseconds: pipelineDelay)

        XCTAssertEqual(vm.filteredPosts.map(\.title), ["Advanced"])
    }

    func test_filterByFavorite_returnsOnlyMatching() async throws {
        let favorite = post(title: "Favorite", favoriteChoice: .yes)
        let notFavorite = post(title: "Not favorite", favoriteChoice: .no)
        vm = try await makeVM(posts: [favorite, notFavorite])

        vm.selectedFavorite = .yes
        try await Task.sleep(nanoseconds: pipelineDelay)

        XCTAssertEqual(vm.filteredPosts.map(\.title), ["Favorite"])
    }

    func test_filterByType_returnsOnlyMatching() async throws {
        let course = post(title: "Course", postType: .course)
        let article = post(title: "Article", postType: .article)
        vm = try await makeVM(posts: [course, article])

        vm.selectedType = .course
        try await Task.sleep(nanoseconds: pipelineDelay)

        XCTAssertEqual(vm.filteredPosts.map(\.title), ["Course"])
    }

    func test_filterByPlatform_returnsOnlyMatching() async throws {
        let video = post(title: "Video", postPlatform: .youtube)
        let site = post(title: "Site", postPlatform: .website)
        vm = try await makeVM(posts: [video, site])

        vm.selectedPlatform = .website
        try await Task.sleep(nanoseconds: pipelineDelay)

        XCTAssertEqual(vm.filteredPosts.map(\.title), ["Site"])
    }

    func test_filterByYear_returnsOnlyMatching() async throws {
        // Год поста filterPosts() считает по локальному календарю — тому же,
        // которым дата создаётся и отображается.
        let local = Calendar.current
        let year2024 = post(title: "2024", postDate: DateComponents(calendar: local, year: 2024, month: 6, day: 15).date)
        let year2025 = post(title: "2025", postDate: DateComponents(calendar: local, year: 2025, month: 6, day: 15).date)
        vm = try await makeVM(posts: [year2024, year2025])

        vm.selectedYear = "2025"
        try await Task.sleep(nanoseconds: pipelineDelay)

        XCTAssertEqual(vm.filteredPosts.map(\.title), ["2025"])
    }

    func test_filterByYear_localNewYearMidnight_belongsToDisplayedYear() async throws {
        // Граничный случай: 1 января 00:30 по локальному времени. В строке
        // пост показывается как 01.01.2025, значит и в фильтре он должен
        // быть в 2025 (с UTC-календарём восточнее UTC он уходил в 2024).
        let local = Calendar.current
        let newYear = post(title: "New Year", postDate: DateComponents(calendar: local, year: 2025, month: 1, day: 1, hour: 0, minute: 30).date)
        vm = try await makeVM(posts: [newYear])

        XCTAssertEqual(vm.allYears, ["2025"])

        vm.selectedYear = "2025"
        try await Task.sleep(nanoseconds: pipelineDelay)

        XCTAssertEqual(vm.filteredPosts.map(\.title), ["New Year"])
    }

    // MARK: - visiblePosts

    func test_visiblePosts_excludesDeletedAndDrafts() async throws {
        // Given — активный пост, пост в корзине и черновик
        let active = post(title: "Active")
        let deleted = post(title: "Deleted")
        deleted.status = .deleted
        let draft = post(title: "Draft")
        draft.draft = true
        vm = try await makeVM(posts: [active, deleted, draft])

        // Then — видимы (в списке и статистике) только активные не-черновики
        XCTAssertEqual(vm.visiblePosts.map(\.title), ["Active"])
    }

    func test_visiblePosts_followsFilters() async throws {
        // Given
        let advanced = post(title: "Advanced", studyLevel: .advanced)
        let beginner = post(title: "Beginner", studyLevel: .beginner)
        vm = try await makeVM(posts: [advanced, beginner])

        // When — фильтр списка применяется и к видимым постам (статистике)
        vm.selectedLevel = .advanced
        try await Task.sleep(nanoseconds: pipelineDelay)

        // Then
        XCTAssertEqual(vm.visiblePosts.map(\.title), ["Advanced"])
    }

    // MARK: - Combined filters (AND)

    func test_combinedFilters_matchAllSimultaneously() async throws {
        let matches = post(title: "Matches", studyLevel: .advanced, favoriteChoice: .yes)
        let wrongLevel = post(title: "Wrong level", studyLevel: .beginner, favoriteChoice: .yes)
        let wrongFavorite = post(title: "Wrong favorite", studyLevel: .advanced, favoriteChoice: .no)
        vm = try await makeVM(posts: [matches, wrongLevel, wrongFavorite])

        vm.selectedLevel = .advanced
        vm.selectedFavorite = .yes
        try await Task.sleep(nanoseconds: pipelineDelay)

        XCTAssertEqual(vm.filteredPosts.map(\.title), ["Matches"])
    }

    // MARK: - Search

    func test_search_matchesTitleCaseInsensitive() async throws {
        let match = post(title: "SwiftUI Basics")
        let noMatch = post(title: "UIKit Basics")
        vm = try await makeVM(posts: [match, noMatch])

        vm.searchText = "swiftui"
        try await Task.sleep(nanoseconds: pipelineDelay)

        XCTAssertEqual(vm.filteredPosts.map(\.title), ["SwiftUI Basics"])
    }

    func test_search_matchesIntroAuthorAndNotes() async throws {
        let byIntro = post(title: "A", intro: "unique-intro-marker")
        let byAuthor = post(title: "B", author: "unique-author-marker")
        let byNotes = post(title: "C", notes: "unique-notes-marker")
        let noMatch = post(title: "D")
        vm = try await makeVM(posts: [byIntro, byAuthor, byNotes, noMatch])

        vm.searchText = "unique-author-marker"
        try await Task.sleep(nanoseconds: pipelineDelay)

        XCTAssertEqual(vm.filteredPosts.map(\.title), ["B"])
    }

    func test_search_noMatch_returnsEmpty() async throws {
        vm = try await makeVM(posts: [post(title: "Something")])

        vm.searchText = "xyzzy_no_match_12345"
        try await Task.sleep(nanoseconds: pipelineDelay)

        XCTAssertTrue(vm.filteredPosts.isEmpty)
    }

    func test_search_emptyText_returnsAll() async throws {
        vm = try await makeVM(posts: [post(title: "A"), post(title: "B")])

        vm.searchText = "A"
        try await Task.sleep(nanoseconds: pipelineDelay)
        vm.searchText = ""
        try await Task.sleep(nanoseconds: pipelineDelay)

        XCTAssertEqual(vm.filteredPosts.count, 2)
    }

    // MARK: - Sorting

    func test_sortNewestFirst_ordersDescendingByPostDate() async throws {
        let old = post(title: "Old", postDate: Date(timeIntervalSince1970: 1_000))
        let new = post(title: "New", postDate: Date(timeIntervalSince1970: 2_000))
        vm = try await makeVM(posts: [old, new])

        vm.selectedSortOption = .newestFirst
        try await Task.sleep(nanoseconds: pipelineDelay)

        XCTAssertEqual(vm.filteredPosts.map(\.title), ["New", "Old"])
    }

    func test_sortOldestFirst_ordersAscendingByPostDate() async throws {
        let old = post(title: "Old", postDate: Date(timeIntervalSince1970: 1_000))
        let new = post(title: "New", postDate: Date(timeIntervalSince1970: 2_000))
        vm = try await makeVM(posts: [old, new])

        vm.selectedSortOption = .oldestFirst
        try await Task.sleep(nanoseconds: pipelineDelay)

        XCTAssertEqual(vm.filteredPosts.map(\.title), ["Old", "New"])
    }

    /// Посты без postDate должны уходить в конец при обеих сортировках по
    /// дате — так реализовано сейчас (case (nil, _): false / case (_, nil): true).
    func test_sortNewestFirst_postsWithoutDate_goLast() async throws {
        let dated = post(title: "Dated", postDate: Date(timeIntervalSince1970: 1_000))
        let undated = post(title: "Undated", postDate: nil)
        vm = try await makeVM(posts: [undated, dated])

        vm.selectedSortOption = .newestFirst
        try await Task.sleep(nanoseconds: pipelineDelay)

        XCTAssertEqual(vm.filteredPosts.map(\.title), ["Dated", "Undated"])
    }

    func test_sortNotSorted_preservesOriginalOrder() async throws {
        let first = post(title: "First")
        let second = post(title: "Second")
        let third = post(title: "Third")
        vm = try await makeVM(posts: [first, second, third])

        XCTAssertEqual(vm.selectedSortOption, .notSorted)
        XCTAssertEqual(vm.filteredPosts.map(\.title), ["First", "Second", "Third"])
    }

    func test_sortRandom_keepsSameCountAndElements() async throws {
        let titles = (1...5).map { "Post \($0)" }
        vm = try await makeVM(posts: titles.map { post(title: $0) })

        vm.selectedSortOption = .random // выставляет .random и сам вызывает reshufflePosts()
        try await Task.sleep(nanoseconds: pipelineDelay)

        XCTAssertEqual(vm.filteredPosts.count, titles.count)
        XCTAssertEqual(Set(vm.filteredPosts.map(\.title)), Set(titles))
    }

    // Сам случайный порядок недетерминирован — проверяем свойства:
    // у каждого поста есть ключ и список отсортирован по ключам.
    private func assertSortedByRandomKeys(_ vm: PostsViewModel, file: StaticString = #filePath, line: UInt = #line) {
        let keys = vm.filteredPosts.map { vm.randomSortKeys[$0.id] }
        XCTAssertFalse(keys.contains(nil), "У каждого поста должен быть ключ", file: file, line: line)
        let values = keys.compactMap { $0 }
        XCTAssertEqual(values, values.sorted(), "Список должен быть отсортирован по ключам", file: file, line: line)
    }

    func test_sortRandom_selectedBeforeLoad_shufflesLoadedPosts() async throws {
        // Given — как после перезапуска: "Random" выставлен до загрузки постов
        // (restorePostFilters() в init), reshufflePosts() видит пустой allPosts.
        let posts = (1...5).map { post(title: "Post \($0)") }
        let viewModel = PostsViewModel(
            dataSource: MockPostsDataSource(posts: posts),
            fbPostsManager: MockFBPostsManager.mockPosts([]),
            services: .make()
        )
        viewModel.selectedSortOption = .random

        // When
        viewModel.start()
        viewModel.loadPostsFromSwiftData(removeDuplicates: false)
        try await Task.sleep(nanoseconds: pipelineDelay)
        vm = viewModel

        // Then — все загруженные посты получили ключи и отсортированы по ним
        XCTAssertEqual(vm.filteredPosts.count, posts.count)
        assertSortedByRandomKeys(vm)
    }

    func test_sortRandom_postAddedAfterShuffle_getsKey() async throws {
        // Given
        vm = try await makeVM(posts: (1...3).map { post(title: "Post \($0)") })
        vm.selectedSortOption = .random
        try await Task.sleep(nanoseconds: pipelineDelay)

        // When — пост добавлен после перемешивания
        let newPost = post(title: "New")
        vm.addPost(newPost)
        try await Task.sleep(nanoseconds: pipelineDelay)

        // Then — новый пост получил свой ключ (раньше всегда уходил в конец)
        XCTAssertNotNil(vm.randomSortKeys[newPost.id])
        XCTAssertEqual(vm.filteredPosts.count, 4)
        assertSortedByRandomKeys(vm)
    }

    func test_sortRandom_pipelineRerun_keepsOrder() async throws {
        // Given
        vm = try await makeVM(posts: (1...5).map { post(title: "Post \($0)") })
        vm.selectedSortOption = .random
        try await Task.sleep(nanoseconds: pipelineDelay)
        let orderBefore = vm.filteredPosts.map(\.title)

        // When — пайплайн перезапускается без reshuffle (фильтр туда и обратно)
        vm.selectedLevel = .advanced
        try await Task.sleep(nanoseconds: pipelineDelay)
        vm.selectedLevel = nil
        try await Task.sleep(nanoseconds: pipelineDelay)

        // Then — порядок не изменился
        XCTAssertEqual(vm.filteredPosts.map(\.title), orderBefore)
    }

    // MARK: - checkIfAllFiltersAreEmpty

    func test_checkIfAllFiltersAreEmpty_trueByDefault() async throws {
        vm = try await makeVM(posts: [])
        XCTAssertTrue(vm.checkIfAllFiltersAreEmpty())
    }

    func test_checkIfAllFiltersAreEmpty_falseWhenAnyFilterSet() async throws {
        vm = try await makeVM(posts: [])
        vm.selectedLevel = .advanced
        XCTAssertFalse(vm.checkIfAllFiltersAreEmpty())
    }

    func test_checkIfAllFiltersAreEmpty_falseWhenSortOptionSet() async throws {
        vm = try await makeVM(posts: [])
        vm.selectedSortOption = .newestFirst
        XCTAssertFalse(vm.checkIfAllFiltersAreEmpty())
    }
}
