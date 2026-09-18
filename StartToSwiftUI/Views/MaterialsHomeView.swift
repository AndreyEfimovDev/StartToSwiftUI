//
//  HomwViewCopy.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.08.2025.
//

import SwiftUI
import SwiftData

struct MaterialsHomeView: View {
    
    // MARK: - Dependencies
    @EnvironmentObject private var vm: PostsViewModel
    @EnvironmentObject private var noticevm: NoticesViewModel
    @EnvironmentObject private var coordinator: AppCoordinator

    private let hapticManager = HapticManager.shared

    // MARK: - Constants
    let selectedCategory: String?
    private let longPressDuration: Double = 0.5

    // MARK: - States
    @State private var showOnTopButton: Bool = false
    @State private var isDetectingLongPress: Bool = false
    @State private var isLongPressSuccess: Bool = false
    @State private var showViewOnDoubleTap: Bool = false
    @State private var isFilterButtonPressed: Bool = false
    /// Выбор в List(selection:) на iPad (iPadListContent) — привязан к id
    /// (String), а не к самому Post: Post — SwiftData @Model, reference type,
    /// и привязка selection напрямую к нему на реальном устройстве не работала
    /// (тап не долетал до vm.selectedPost вообще, даже в широком виде).
    /// Синхронизируется в vm.selectedPost через onChange ниже.
    @State private var selectedPostID: String?
    
    // MARK: - Computed Properties
    private var disableHomeView: Bool {
        isLongPressSuccess || showViewOnDoubleTap
    }
    
    private var postsToDisplay: [Post] {
        let byCategory: [Post]
        if let category = selectedCategory {
            byCategory = vm.filteredPosts.filter { $0.category == category }
        } else {
            byCategory = vm.filteredPosts
        }
        return byCategory.filter { $0.status == .active && !$0.draft }
    }

    // MARK: BODY
    var body: some View {
        GeometryReader { proxy in
            ScrollViewReader { scrollProxy in
                ZStack (alignment: .bottom) {
                    if vm.allPosts.isEmpty {
                        allPostsIsEmpty
                    } else if vm.filteredPosts.isEmpty {
                        filteredPostsIsEmpty
                    } else {
                        listPostRowsContent
                        OnTopButton(isVisible: showOnTopButton) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                scrollProxy.scrollTo(postsToDisplay.first?.id, anchor: .top)
                            }
                        }
                    }
                }
            }
            .disabled(disableHomeView)
            .navigationTitle("Materials")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar { SharedToolbarLeadingItems() }
            .safeAreaInset(edge: .top) { searchBarStack }
            .sheet(isPresented: $isFilterButtonPressed) {filtersSheet }
            .overlay { gestureOverlays(proxy: proxy) }
            .task {
                vm.analyticsManager.logScreen(name: "MaterialsHomeView")
            }
        }
    }
    
    // MARK: Subviews

    /// iPhone — обычный ForEach со всеми жестами (long-press, double-tap, swipe).
    /// iPad — List(selection:), привязанный к NavigationSplitView: тап по строке
    /// сам переключает detail-колонку и даёт системную кнопку "назад" в
    /// схлопнутом (compact) состоянии — то, что вручную через columnVisibility
    /// заставить работать не удалось (см. обсуждение бага с открытием деталей).
    /// Long-press/double-tap на iPad не переносим — они конфликтовали бы с
    /// собственным тап-жестом List(selection:).
    @ViewBuilder
    private var listPostRowsContent: some View {
        if UIDevice.isiPad {
            iPadListContent
        } else {
            iPhoneListContent
        }
    }

    private var iPhoneListContent: some View {
        List {
            ForEach(postsToDisplay) { post in
                PostRowView(post: post)
                    .id(post.id)
                    .background(.black.opacity(0.001))
                    .shimmerWave(enabled: vm.shimmerWaveEnabled && post.origin == .cloudNew)
                    .onLongPressGesture(
                        minimumDuration: longPressDuration,
                        maximumDistance: 50,
                        perform: { handleLongPress(on: post) },
                        onPressingChanged: { handlePressingChanged($0) }
                    )
                    .onTapAndDoubleTap(
                        singleTap: { handleSingleTap(on: post) },
                        doubleTap: { handleDoubleTap(on: post) }
                    )
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        trailingSwipeActions(for: post)
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        leadingSwipeActions(for: post)
                    }
            } // ForEach
            .listRowBackground(Color.clear)
            .listRowSeparatorTint(Color.mycolor.myAccent.opacity(0.35))
            .listRowSeparator(.hidden, edges: [.top])
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        } // List
        .listStyle(.plain)
        .coordinateSpace(name: "postsList")
        .onScrollGeometryChange(for: CGFloat.self) { geo in
            geo.contentOffset.y
        } action: { _, newOffset in
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                showOnTopButton = newOffset > 100
            }
        }
        .refreshControl { await refresh() }
    }

    private var iPadListContent: some View {
        List(postsToDisplay, selection: $selectedPostID) { post in
            PostRowView(post: post)
                .id(post.id)
                .shimmerWave(enabled: vm.shimmerWaveEnabled && post.origin == .cloudNew)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    trailingSwipeActions(for: post)
                }
                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                    leadingSwipeActions(for: post)
                }
        } // List
        .listStyle(.plain)
        .tint(Color.mycolor.myAccent.opacity(0.15)) // цвет подсветки выбранной строки
        .coordinateSpace(name: "postsList")
        .onScrollGeometryChange(for: CGFloat.self) { geo in
            geo.contentOffset.y
        } action: { _, newOffset in
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                showOnTopButton = newOffset > 100
            }
        }
        .refreshControl { await refresh() }
        .onChange(of: selectedPostID) { _, newID in
            vm.selectedPost = postsToDisplay.first { $0.id == newID }
        }
    }

    // MARK: - Refresh

    private func refresh() async {
        vm.loadPostsFromSwiftData()
        vm.updateWidgetData()
        await noticevm.importNoticesFromFirebase()
    }
    
    // MARK: - Gesture Handlers
    
    private func handleLongPress(on post: Post) {
        vm.selectedRating = post.postRating
        vm.selectedPost = post
        isLongPressSuccess = true
        hapticManager.impact(style: .light)
    }
    
    private func handlePressingChanged(_ isPressing: Bool) {
        if isPressing {
            isDetectingLongPress = true
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if !isLongPressSuccess {
                    isDetectingLongPress = false
                }
            }
        }
    }
    
    /// Используется только на iPhone (ForEach + жесты, см. iPhoneListContent).
    /// На iPad деталь открывается через List(selection:) в iPadListContent —
    /// "отметить прочитанным" в этом случае происходит в PostDetailsView.onAppear.
    private func handleSingleTap(on post: Post) {
        vm.selectedPost = post
        if UIDevice.isiPhone {
            coordinator.push(.postDetails(post: post))
        }
    }
    
    private func handleDoubleTap(on post: Post) {
        vm.selectedStudyProgress = post.progress
        vm.selectedPost = post
        showViewOnDoubleTap = true
        hapticManager.impact(style: .light)
    }
    
    // MARK: - Swipe Actions
    
    @ViewBuilder
    private func trailingSwipeActions(for post: Post) -> some View {
        Button("Delete", systemImage: "archivebox") {
            vm.setPostDeleted(post)
        }.tint(StatusOptions.deleted.color)
        
        Button("Edit", systemImage: "pencil") {
            coordinator.push(.editPost(post))
        }.tint(Color.mycolor.myBlue)
    }
    
    @ViewBuilder
    private func leadingSwipeActions(for post: Post) -> some View {
        Button(post.favoriteChoice == .yes ? "Unmark" : "Mark",
               systemImage: post.favoriteChoice == .yes ? "star.slash" : "star"
        ) {
            vm.favoriteToggle(post)
        }
        .tint(post.favoriteChoice.color)
    }
    
    // MARK: - Search Bar Stack
    private var searchBarStack: some View {
        HStack {
            SearchBarView(searchText: $vm.searchText)
            // Add a new post
            CircleStrokeButtonView(
                iconName: "plus",
                isShownCircle: false
            ){
                coordinator.push(.addPost)
                hapticManager.impact(style: .light)
            }
            .background(.ultraThinMaterial)
            .clipShape(.circle)
            .background(
                Circle().stroke(Color.mycolor.mySecondary,lineWidth: 1)
            )

            // Fliters for posts
            if !vm.allPosts.isEmpty {
                CircleStrokeButtonView(
                    iconName: "line.3.horizontal.decrease",
                    isIconColorToChange: !vm.isFiltersEmpty,
                    isShownCircle: false
                ) {
                    isFilterButtonPressed.toggle()
                    hapticManager.impact(style: .light)
                }
                .background(.ultraThinMaterial)
                .clipShape(.circle)
                .background(
                    Circle()
                        .stroke(
                            Color.mycolor.mySecondary,
                            lineWidth: 1)
                )
            }
        }
        .padding(.horizontal)
    }
    

    // MARK: - Overlays
    
    @ViewBuilder
    private func gestureOverlays(proxy: GeometryProxy) -> some View {
        if UIDevice.isiPhone {
            ZStack {
                if isLongPressSuccess {
                    ProgressSelectionView { // ProgressSelectionView
                        isLongPressSuccess = false
                        hapticManager.impact(style: .light)
                    }
                    .allowsHitTesting(true)
                    .frame(maxHeight: max(proxy.size.height / 3, 300))
                    .padding(.horizontal, 30)
                }
                
                if showViewOnDoubleTap {
                    RatingSelectionView { // RatingSelectionView
                        showViewOnDoubleTap = false
                        hapticManager.impact(style: .light)
                    }
                    .frame(maxHeight: max(proxy.size.height / 3, 300))
                    .padding(.horizontal, 30)
                }
            }
        }
    }
    
    // MARK: - Filters View

    private var filtersSheet: some View {
        PostsFilterView(isFilterButtonPressed: $isFilterButtonPressed)
            .overlay(alignment: .top) {
                if UIDevice.isiPhone {
                    LinearGradient(
                        colors: [
                            Color.mycolor.mySecondary.opacity(0.1),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 30)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 30)
                    )
                }
            }
            .presentationBackground(.ultraThinMaterial)
            .presentationDetents([.height(600)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(30)
    }

    // MARK: - Supporting Views

    private var allPostsIsEmpty: some View {
        ZStack {
            ContentUnavailableView(
                "No Study Materials",
                systemImage: "tray",
                description: Text("Materials will appear here once you create them yourself or download curated content.")
            )
            Button("Download curated collection") {
                coordinator.push(.importFromCloud)
            }
            .customListRowStyle(iconName: "icloud.and.arrow.down", iconWidth: 18)
            .offset(y: 100)
        }
    }
    
    private var filteredPostsIsEmpty: some View {
        ContentUnavailableView(
            "No Results matching your search criteria",
            systemImage: "magnifyingglass",
            description: Text("Check the spelling or try a new search.")
        )
    }

}

private struct HomeViewPreview: View {
    
    @StateObject var vm: PostsViewModel = {
        let vm = PostsViewModel(
            dataSource: MockPostsDataSource(),
            fbPostsManager: MockFBPostsManager(),
            services: .make()
        )
        vm.start()
        return vm
    }()
    
    @StateObject var noticesVM = NoticesViewModel(
        dataSource: MockNoticesDataSource(),
        fbNoticesManager: MockFBNoticesManager(),
        services: .make()
    )
    
    var body: some View {
        NavigationStack {
            MaterialsHomeView(selectedCategory: Constants.mainCategory)
                .environmentObject(AppCoordinator())
                .environmentObject(vm)
                .environmentObject(noticesVM)
        }
    }
}

#Preview("With Mock Posts") {
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppSyncState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    HomeViewPreview()
        .modelContainer(container)
}
