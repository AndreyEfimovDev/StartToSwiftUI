//
//  HomwViewCopy.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.08.2025.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    
    // MARK: - Dependencies
    @EnvironmentObject private var vm: PostsViewModel
    @EnvironmentObject private var noticevm: NoticeViewModel
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
    
    // MARK: - Computed Properties
    private var disableHomeView: Bool {
        isLongPressSuccess || showViewOnDoubleTap
    }
    
    private var postsToDisplay: [Post] {
        guard let category = selectedCategory else {
            return vm.filteredPosts
        }
        return vm.filteredPosts.filter { $0.category == category }
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
                        onTopButton(proxy: scrollProxy)
                    }
                }
            }
            .disabled(disableHomeView)
            .navigationTitle(vm.selectedCategory ?? Constants.mainCategory)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                navigationToolbar()
            }
            .safeAreaInset(edge: .top) {
                SearchBarView()
            }
            .sheet(isPresented: $isFilterButtonPressed) {
                filtersSheet
            }
            .overlay { gestureOverlays(proxy: proxy) }
            .alert("Error", isPresented: $vm.showErrorMessageAlert, actions: {
                Button("OK") {}
            }, message: {
                if let errorMessage = vm.errorMessage {
                    Text(errorMessage)
                }
            })
            .alert("Error", isPresented: $noticevm.showErrorMessageAlert, actions: {
                Button("OK") {}
            }, message: {
                if let errorMessage = noticevm.errorMessage {
                    Text(errorMessage)
                }
            })
            .task {
                FBAnalyticsManager.shared.logScreen(name: "HomeView")
                
                vm.loadPostsFromSwiftData()
                noticevm.loadNoticesFromSwiftData()
                vm.updateWidgetData()
                vm.isFiltersEmpty = vm.checkIfAllFiltersAreEmpty()
                noticevm.playSoundNotificationIfNeeded()
                await noticevm.importNoticesFromFirebase()
            }
        }
    }
    
    // MARK: Subviews
    private var listPostRowsContent: some View {
        List {
            ForEach(postsToDisplay.filter { $0.status == .active && !$0.draft }) { post in
                PostRowView(post: post)
                    .id(post.id)
                    .background(trackingFirstPostInList(post: post))
                    .background(.black.opacity(0.001))
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
        .refreshControl {
            refresh()
        }
    }
    
    // MARK: - Refresh

    private func refresh() {
        vm.loadPostsFromSwiftData()
        vm.updateWidgetData()
        Task {
            await noticevm.importNoticesFromFirebase()
        }
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
    
    private func handleSingleTap(on post: Post) {
        vm.selectedPost = post
        
        // Mark a new post from cloud as not new after tapping if necessary
        if post.origin == .cloudNew {
            vm.updatePostOrigin(post)
        }
        
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
        Button("Hide", systemImage: "eye.slash") {
            vm.setPostHidden(post)
        }.tint(PostStatus.hidden.color)
        
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
    
    // MARK: - Toolbar

    @ToolbarContentBuilder
    private func navigationToolbar() -> some ToolbarContent {
        
        ToolbarItem(placement: .navigationBarLeading) {
            CircleStrokeButtonView(iconName: "gearshape", isShownCircle: false) {
                coordinator.push(.preferences)
                hapticManager.impact(style: .light)
            }
        }
        if noticevm.unreadCount != 0  {
            ToolbarItem(placement: .navigationBarLeading) {
                noticeButton
            }
        }
  
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            // Add a new post
            CircleStrokeButtonView(
                iconName: "plus",
                isShownCircle: false
            ){
                coordinator.push(.addPost)
                hapticManager.impact(style: .light)
            }
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
            }
        }
    }
    
    private var noticeButton: some View {
        CircleStrokeButtonView(iconName: "message", isShownCircle: false) {
            coordinator.push(.notices)
        }
        .overlay {
            Capsule()
                .fill(Color.mycolor.myRed)
                .frame(maxWidth: 15, maxHeight: 10)
                .overlay {
                    Text("\(noticevm.unreadCount)")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(Color.mycolor.myButtonTextPrimary)
                }
                .offset(x: 6, y: -9)
        }
        .background(noticeButtonAnimationBackground)
    }

    private var noticeButtonAnimationBackground: some View {
        Circle()
            .stroke(
                Color.mycolor.myRed,
                lineWidth: noticevm.shouldAnimateNoticeButton ? 3 : 0
            )
            .scaleEffect(noticevm.shouldAnimateNoticeButton ? 1.2 : 0.8)
            .opacity(noticevm.shouldAnimateNoticeButton ? 0.0 : 1.0)
            .animation(
                noticevm.shouldAnimateNoticeButton ? .easeOut(duration: 1.0) : .none,
                value: noticevm.shouldAnimateNoticeButton
            )
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
        FiltersView(isFilterButtonPressed: $isFilterButtonPressed)
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

    @ViewBuilder
    private func trackingFirstPostInList(post: Post) -> some View {
        GeometryReader { geo in
            Color.clear
                .onChange(of: geo.frame(in: .global).minY) { oldY, newY in
                    // Track first element position in the List
                    if post.id == vm.filteredPosts.first?.id {
                        showOnTopButton = newY < 0
                    }
                }
        }
    }
    
    @ViewBuilder
    private func onTopButton(proxy: ScrollViewProxy) -> some View {
        if showOnTopButton {
            CircleStrokeButtonView(
                iconName: "control",
                iconFont: .title,
                imageColorPrimary: Color.mycolor.myBlue,
                widthIn: 55,
                heightIn: 55) {
                    withAnimation {
                        if let firstID = vm.filteredPosts.first?.id {
                            proxy.scrollTo(firstID, anchor: .top)
                        }
                    }
                }
        }
    }
    
    private var allPostsIsEmpty: some View {
        ContentUnavailableView(
            "No Study Materials",
            systemImage: "tray",
            description: Text("Materials will appear here once you create them yourself.")
        )
    }
    
    private var filteredPostsIsEmpty: some View {
        ContentUnavailableView(
            "No Results matching your search criteria",
            systemImage: "magnifyingglass",
            description: Text("Check the spelling or try a new search.")
        )
    }
#warning("Delete this func before deployment to App Store")
//    private func postsForCategory(_ category: String?) -> [Post] {
//        guard let category = category else {
//            return vm.filteredPosts
//        }
//        return vm.filteredPosts.filter { $0.category == category }
//    }
    
}

private struct HomeViewPreview: View {
    
    @StateObject var vm: PostsViewModel = {
        let vm = PostsViewModel(
            dataSource: MockPostsDataSource(),
            fbPostsManager: MockFBPostsManager()
        )
        vm.start()
        return vm
    }()
    
    @StateObject var noticesVM = NoticeViewModel(
        dataSource: MockNoticesDataSource(),
        fbNoticesManager: MockFBNoticesManager()
    )
    
    var body: some View {
        NavigationStack {
            HomeView(selectedCategory: Constants.mainCategory)
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
