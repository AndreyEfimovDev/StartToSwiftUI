//
//  HomwViewCopy.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.08.2025.
//

import SwiftUI
import SwiftData
import AudioToolbox


struct HomeView: View {
    
    // MARK: PROPERTIES
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var vm: PostsViewModel
    @EnvironmentObject private var noticevm: NoticeViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    
    private let hapticManager = HapticService.shared
    
    let selectedCategory: String?
    
    @State private var selectedPostToDelete: Post?
    @State private var showOnTopButton: Bool = false
    @State private var isShowingDeleteConfirmation: Bool = false
    @State private var noticeButtonAnimation = false
    @State private var isDetectingLongPress: Bool = false
    @State private var isLongPressSuccess: Bool = false
    @State private var showProgressSelectionView: Bool = false
    @State private var isFilterButtonPressed: Bool = false
    
    private var disableHomeView: Bool {
        isLongPressSuccess || showProgressSelectionView || isShowingDeleteConfirmation
    }
    private let longPressDuration: Double = 0.5
    private let limitToShortenTitle: Int = 30
    
    // MARK: VIEW BODY
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
            .navigationTitle(vm.selectedCategory ?? "SwiftUI")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                navigationToolbar()
            }
            .safeAreaInset(edge: .top) {
                SearchBarView()
            }
            .sheet(isPresented: $isFilterButtonPressed) {
                FiltersSheetView(
                    isFilterButtonPressed: $isFilterButtonPressed
                )
                .presentationBackground(.ultraThinMaterial)
                .presentationDetents([.height(600)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(30)
            }
            .overlay {
                if UIDevice.isiPhone { // only for iPhime version
                    ZStack {
                        // On long press gesture
                        if isLongPressSuccess {
                            RatingSelectionView() {
                                isLongPressSuccess = false
                                hapticManager.impact(style: .light)
                            }
                            .frame(maxHeight: max(proxy.size.height / 3, 300))
                            .padding(.horizontal, 30)
                        }
                        // On double tap gesture
                        if showProgressSelectionView {
                            ProgressSelectionView() {
                                showProgressSelectionView = false
                                hapticManager.impact(style: .light)
                            }
                            .allowsHitTesting(true)
                            .frame(maxHeight: max(proxy.size.height / 3, 300))
                            .padding(.horizontal, 30)
                        }
                    }
                }
            }
            .overlay {
                if isShowingDeleteConfirmation {
                    postDeletionConfirmation
                        .opacity(isShowingDeleteConfirmation ? 1 : 0)
                        .transition(.move(edge: .bottom))
                }
            }
            .onAppear {
                vm.isFiltersEmpty = vm.checkIfAllFiltersAreEmpty()
                soundNotificationIfNeeded()
            }
        }
    }
    
    // MARK: Subviews

    private var listPostRowsContent: some View {
        List {
            ForEach(postsForCategory(selectedCategory)) { post in
                PostRowView(post: post)
                    .id(post.id)
                    .background(trackingFistPostInList(post: post))
                    .background(.black.opacity(0.001))
                    .onLongPressGesture(
                        minimumDuration: longPressDuration,
                        maximumDistance: 50,
                        perform: {
                            vm.selectedRating = post.postRating
                            vm.selectedPostId = post.id
                            isLongPressSuccess = true
                            hapticManager.impact(style: .light)
                        },
                        onPressingChanged: { isPressing in
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
                    )
                    .onTapAndDoubleTap(
                        singleTap: {
                            vm.selectedPostId = post.id
                            if UIDevice.isiPhone {
                                coordinator.push(.postDetails(postId: post.id))
                            }
                            if UIDevice.isiPad {
                                hapticManager.impact(style: .light)
                            }
                        },
                        doubleTap: {
                            vm.selectedStudyProgress = post.progress
                            vm.selectedPostId = post.id
                            showProgressSelectionView = true
                            hapticManager.impact(style: .light)
                        }
                    )
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button("Delete", systemImage: "trash") {
                            selectedPostToDelete = post
                            hapticManager.notification(type: .warning)
                            isShowingDeleteConfirmation = true
                        }
                        .tint(Color.mycolor.myRed)
                        
                        Button("Edit", systemImage: post.origin == .cloud  || post.origin == .statical ? "pencil.slash" : "pencil") {
                            coordinator.push(.editPost(post))
                        }
                        .tint(Color.mycolor.myBlue)
                        .disabled(post.origin == .cloud || post.origin == .statical)
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button(post.favoriteChoice == .yes ? "Unmark" : "Mark" , systemImage: post.favoriteChoice == .yes ?  "heart.slash" : "heart") {
                            vm.favoriteToggle(post)
                        }.tint(post.favoriteChoice == .yes ? Color.mycolor.mySecondary : Color.mycolor.myRed.opacity(0.5))
                    }
            } // ForEach
            .listRowBackground(Color.clear)
            .listRowSeparatorTint(Color.mycolor.myAccent.opacity(0.35))
            .listRowSeparator(.hidden, edges: [.top])
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        } // List
        .listStyle(.plain)
        .refreshControl {
            // Pull to refresh the View
            vm.loadPostsFromSwiftData()
            hapticManager.impact(style: .light)
            Task {
                await noticevm.importNoticesFromCloud()
            }
        }
    }
    
    @ToolbarContentBuilder
    private func navigationToolbar() -> some ToolbarContent {
        
        ToolbarItem(placement: .navigationBarLeading) {
            CircleStrokeButtonView(
                iconName: "gearshape",
                isShownCircle: false)
            {
                coordinator.push(.preferences)
            }
        }
        if noticevm.hasUnreadNotices {
            ToolbarItem(placement: .navigationBarLeading) {
                CircleStrokeButtonView(
                    iconName: "message",
                    isShownCircle: false
                ){
                    coordinator.push(.notices)
                }
                .overlay {
                    Capsule()
                        .fill(Color.mycolor.myRed)
                        .frame(maxWidth: 15, maxHeight: 10)
                        .overlay {
                            Text("\(noticevm.notices.filter({ $0.isRead == false }).count)")
                                .font(.system(size: 8, weight: .bold, design: .default))
                                .foregroundStyle(Color.mycolor.myButtonTextPrimary)
                        }
                        .offset(x: 6, y: -9)
                }
                .background(
                    AnyView(
                        Circle()
                            .stroke(
                                Color.mycolor.myRed,
                                lineWidth: noticeButtonAnimation ? 3 : 0
                            )
                            .scaleEffect(noticeButtonAnimation ? 1.2 : 0.8)
                            .opacity(noticeButtonAnimation ? 0.0 : 1.0)
                    )
                    .animation(
                        noticeButtonAnimation
                        ? .easeOut(duration: 1.0)
                        : .none,
                        value: noticeButtonAnimation
                    )
                )
            }
        }
        
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            // Add a new post
            CircleStrokeButtonView(
                iconName: "plus",
                isShownCircle: false
            ){
                coordinator.push(.addPost)
            }
            // Filters sheet
            CircleStrokeButtonView(
                iconName: "line.3.horizontal.decrease",
                isIconColorToChange: !vm.isFiltersEmpty,
                isShownCircle: false
            ){
                isFilterButtonPressed.toggle()
                hapticManager.impact(style: .light)
            }
        }
    }
    
    @ViewBuilder
    private func trackingFistPostInList(post: Post) -> some View {
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
            systemImage: "tray.and.arrow.down",
            description: Text("Materials will appear here when you create your own or download a curated collection")
        )
    }
    
    private var filteredPostsIsEmpty: some View {
        ContentUnavailableView(
            "No Results matching your search criteria",
            systemImage: "magnifyingglass",
            description: Text("Check the spelling or try a new search")
        )
    }
    
    private func postsForCategory(_ category: String?) -> [Post] {
        guard let category = category else {
            return vm.filteredPosts
        }
        return vm.filteredPosts.filter { $0.category == category }
    }
    
    private var postDeletionConfirmation: some View {
        ZStack {
            Color.mycolor.myAccent.opacity(0.001)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    isShowingDeleteConfirmation = false
                }
            VStack(spacing: 8) {
                Text("Are you sure you want to delete the material?")
                    .font(.headline)
                    .foregroundColor(Color.mycolor.myRed)
                    .multilineTextAlignment(.center)
                    .padding(.vertical)
                Text(selectedPostToDelete?.title ?? "No material selected")
                    .font(.subheadline)
                    .foregroundColor(Color.mycolor.myAccent)
                    .minimumScaleFactor(0.75)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
                Text("This cannot be undone.")
                    .font(.caption2)
                    .foregroundColor(Color.mycolor.myAccent)
                    .padding(.vertical)
                ClearCupsuleButton(
                    primaryTitle: "Delete",
                    primaryTitleColor: Color.mycolor.myRed) {
                        withAnimation {
                            vm.deletePost(selectedPostToDelete ?? nil)
                            hapticManager.notification(type: .success)
                            isShowingDeleteConfirmation = false
                        }
                    }
                ClearCupsuleButton(
                    primaryTitle: "Cancel",
                    primaryTitleColor: Color.mycolor.myAccent) {
                        isShowingDeleteConfirmation = false
                    }
            }
            .padding()
            .background(.ultraThinMaterial)
            .menuFormater()
            .padding(.horizontal, 40)
        }
    }
    
    private func shortenPostTitle(title: String) -> String {
        if title.count > limitToShortenTitle {
            return String(title.prefix(limitToShortenTitle - 3)) + "..."
        }
        return title
    }
    
    /// One-time sound alert to the user when new notifications appear
    private func soundNotificationIfNeeded() {
        
        let appStateManager = AppSyncStateManager(modelContext: modelContext)
        let status = appStateManager.getUserNotifiedBySoundStatus()
        
        guard noticevm.hasUnreadNotices, noticevm.isNotificationOn, status else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            if noticevm.isSoundNotificationOn {
                // Sound played
                AudioServicesPlaySystemSound(1013)
                // Setting the user's sound notification status -> user notified
                appStateManager.markUserNotifiedBySound()
            }
            // Animation has started
            noticeButtonAnimation = true
            // Animation completed, user notified
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                noticeButtonAnimation = false
            }
        }
    }
    
}
//
//#Preview {
//    let container = try! ModelContainer(
//        for: Post.self, Notice.self, AppSyncState.self,
//        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
//    )
//    let context = ModelContext(container)
//    
//    let vm = PostsViewModel(modelContext: context)
//    let noticevm = NoticeViewModel(modelContext: context)
//    
//    return NavigationStack {
//        HomeView(selectedCategory: "SwiftUI")
//    }
//    .modelContainer(container)
//    .environmentObject(vm)
//    .environmentObject(noticevm)
//    .environmentObject(AppCoordinator())
//}


#Preview("With Extended Posts") {
    let extendedPosts = PreviewData.samplePosts + DevData.postsForCloud
    let postsVM = PostsViewModel(
        dataSource: MockPostsDataSource(posts: extendedPosts)
    )
    let noticesVM = NoticeViewModel(
        dataSource: MockNoticesDataSource()
    )
    
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppSyncState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    NavigationStack {
        HomeView(selectedCategory: "SwiftUI")
            .modelContainer(container)
            .environmentObject(AppCoordinator())
            .environmentObject(postsVM)
            .environmentObject(noticesVM)
    }
}
