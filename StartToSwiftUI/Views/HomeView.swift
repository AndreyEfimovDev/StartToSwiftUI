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
    
    //    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var vm: PostsViewModel
    @EnvironmentObject private var noticevm: NoticeViewModel
    @EnvironmentObject private var coordinator: NavigationCoordinator
    
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
    
    private let longPressDuration: Double = 0.5
    private let limitToShortenTitle: Int = 30
    
    // MARK: VIEW BODY
    
    var body: some View {
        NavigationStack (path: $coordinator.path) {
            Group {
                
                if !vm.isTermsOfUseAccepted {
                    WelcomeAtFirstLaunchView()
                } else {
                    
                    GeometryReader { proxy in
                        ScrollViewReader { scrollProxy in
                            ZStack (alignment: .bottom) {
                                if vm.allPosts.isEmpty {
                                    allPostsIsEmpty
                                } else if vm.filteredPosts.isEmpty {
                                    filteredPostsIsEmpty
                                } else {
                                    mainViewBody
                                    onTopButton(proxy: scrollProxy)
                                }
                            }
                        }
                        .disabled(isLongPressSuccess || isShowingDeleteConfirmation)
                        .navigationTitle(vm.selectedCategory ?? "SwiftUI")
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarBackButtonHidden(true)
                        .toolbar {
                            toolbarForMainViewBody()
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
                            if UIDevice.isiPhone {
                                ZStack {
                                    // On long press gesture
                                    if isLongPressSuccess {
                                        RatingSelectionView() {
                                            isLongPressSuccess = false
                                        }
                                        .frame(maxHeight: max(proxy.size.height / 3, 300))
                                        .padding(.horizontal, 30)
                                    }
                                    // On double tap gesture
                                    if showProgressSelectionView {
                                        ProgressSelectionView() {
                                            showProgressSelectionView = false
                                        }
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
                            // Задержка лоя синхронизации с appStateManager
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                if vm.isTermsOfUseAccepted {
                                    soundNotificationIfNeeded()
                                }
                            }
                        }
                    }
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                destinationView(for: route)
            }
        }
    }
    
    // MARK: - Destination View Builder
    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
            
            // Dealing with post details
        case .postDetails(let postId):
            PostDetailsView(postId: postId)
                .environmentObject(coordinator)
            
            // Addind and editing posts
        case .addPost:
            AddEditPostSheet(post: nil)
                .environmentObject(coordinator)
        case .editPost(let post):
            AddEditPostSheet(post: post)
                .environmentObject(coordinator)
                    
            // Welcome at first launch to accept Terms of Use
        case .welcomeAtFirstLaunch:
            WelcomeAtFirstLaunchView()
                .environmentObject(coordinator)

            // Preferences
        case .preferences:
            PreferencesView()
                .environmentObject(coordinator)

            // Managing notices
        case .notices:
            NoticesView()
                .environmentObject(coordinator)
        case .noticeDetails(let noticeId):
            NoticeDetailsView(noticeId: noticeId)
                .environmentObject(coordinator)
                .environmentObject(noticevm)

            // Study progress
        case .studyProgress:
            StudyProgressView()
                .environmentObject(coordinator)

            // Managing posts (materials)
        case .postDrafts:
            PostDraftsView()
                .environmentObject(coordinator)
        case .checkForUpdates:
            CheckForPostsUpdateView()
                .environmentObject(coordinator)
        case .importFromCloud:
            ImportPostsFromCloudView()
                .environmentObject(coordinator)
        case .shareBackup:
            SharePostsView()
                .environmentObject(coordinator)
        case .restoreBackup:
            RestoreBackupView()
                .environmentObject(coordinator)
        case .erasePosts:
            EraseAllPostsView()
                .environmentObject(coordinator)
            
            // Gratitude
        case .acknowledgements:
            Acknowledgements()
                .environmentObject(coordinator)
            
            // About App
        case .aboutApp:
            AboutApp()
                .environmentObject(coordinator)
        case .welcome:
            WelcomeMessage()
                .environmentObject(coordinator)
        case .introduction:
            Introduction()
                .environmentObject(coordinator)
        case .whatIsNew:
            WhatsNewView()
                .environmentObject(coordinator)
            
            // Legal information
        case .legalInfo:
            LegalInformationView()
                .environmentObject(coordinator)
        case .termsOfUse:
            TermsOfUse()
                .environmentObject(coordinator)
                .environmentObject(vm)
        case .privacyPolicy:
            PrivacyPolicy()
                .environmentObject(coordinator)
        case .copyrightPolicy:
            CopyrightPolicy()
                .environmentObject(coordinator)
        case .fairUseNotice:
            FairUseNotice()
                .environmentObject(coordinator)
            
        default:
            Text("Unknown route")
            
            
        }
    }
    
    // MARK: Subviews
    
    private var mainViewBody: some View {
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
                            coordinator.push(.postDetails(postId: post.id))
                        },
                        doubleTap: {
                            vm.selectedStudyProgress = post.progress
                            vm.selectedPostId = post.id
                            showProgressSelectionView = true
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
                            vm.favoriteToggle(post: post)
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
    
    /// Звуковое одноразовое оповещение пользователя при появлении новых уведомлений
    private func soundNotificationIfNeeded() {
        
        let appStateManager = AppSyncStateManager(modelContext: modelContext)
        let status = appStateManager.getUserNotifiedBySoundStatus()

        guard noticevm.hasUnreadNotices, noticevm.isNotificationOn, status else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            // print("🔔 3 секунды прошли, запускаем анимацию...")
            
            if noticevm.isSoundNotificationOn {
                // Воспроизведен звук
                AudioServicesPlaySystemSound(1013)
                // Сбрасывам статус звукового оповещения пользователя -> пользователь оповещен
                appStateManager.markUserNotifiedBySound()
            }
            // Анимация начата
            noticeButtonAnimation = true
            // Анимация завершена, пользователь уведомлен
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                noticeButtonAnimation = false
            }
        }

//        if noticevm.hasUnreadNotices {
//            let appStateManager = AppSyncStateManager(modelContext: modelContext)
//            let isPerformingSoundNoticeTask = noticevm.isNotificationOn && appStateManager.getUserNotifiedBySoundStatus()
            // Кнопка показывается сразу, анимация через 3 секунды
//            if isPerformingSoundNoticeTask {
                // Создаем задержку для уведомления...
//                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//                    //                    print("🔔 3 секунды прошли, запускаем анимацию...")
//                    
//                    if noticevm.isSoundNotificationOn {
//                        // Воспроизведен звук
//                        AudioServicesPlaySystemSound(1013)
//                        // Сбрасывам статус звукового оповещения пользователя -> пользователь оповещен
//                        appStateManager.markUserNotifiedBySound()
//                    }
//                    // Анимация начата
//                    noticeButtonAnimation = true
//                    // Анимация завершена, пользователь уведомлен
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                        noticeButtonAnimation = false
//                    }
//                }
//            }
//        }
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
                            vm.deletePost(post: selectedPostToDelete ?? nil)
                            hapticManager.notification(type: .success)
                            isShowingDeleteConfirmation = false
                        }
                    }
                ClearCupsuleButton(
                    primaryTitle: "Cancel",
                    primaryTitleColor: Color.mycolor.myAccent) {
                        isShowingDeleteConfirmation = false
                    }
            } // VStack
            .padding()
            .background(.ultraThinMaterial)
            .menuFormater()
            .padding(.horizontal, 40)
        } // ZStack
    }
    
    private func shortenPostTitle(title: String) -> String {
        if title.count > limitToShortenTitle {
            return String(title.prefix(limitToShortenTitle - 3)) + "..."
        }
        return title
    }
    
    @ToolbarContentBuilder
    private func toolbarForMainViewBody() -> some ToolbarContent {
        
        ToolbarItem(placement: .navigationBarLeading) {
            CircleStrokeButtonView(
                iconName: "gearshape",
                isShownCircle: false)
            {
                //                showPreferancesView.toggle()
                //                coordinator.presentPreferences()
                coordinator.push(.preferences)
            }
        }
        if noticevm.hasUnreadNotices {
            ToolbarItem(placement: .navigationBarLeading) {
                CircleStrokeButtonView(
                    iconName: "message",
                    isShownCircle: false)
                {
                    print("=== HomeView: Opening Preferences ===")
                    print("📱 Current path before push: \(coordinator.path.count)")
                    
                    //                    showNoticesView = true
                    coordinator.presentNotices()
                    print("📱 Path after push (should be 1): \(coordinator.path.count)")
                    
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
            
            if UIDevice.isiPhone {
                CircleStrokeButtonView(
                    iconName: "plus",
                    isShownCircle: false
                ){
                    //                    showAddPostView.toggle()
                    coordinator.push(.addPost)
                }
            }
            
            CircleStrokeButtonView(
                iconName: "line.3.horizontal.decrease",
                isIconColorToChange: !vm.isFiltersEmpty,
                isShownCircle: false
            ){
                isFilterButtonPressed.toggle()
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
            "No Posts",
            systemImage: "tray.and.arrow.down",
            description: Text("Posts will appear here when you create your own or download a curated collection.")
        )
    }
    
    private var filteredPostsIsEmpty: some View {
        ContentUnavailableView(
            "No Results matching your search criteria",
            systemImage: "magnifyingglass",
            description: Text("Check the spelling or try a new search.")
        )
    }
    
    // MARK: Private functions
    
    private func postsForCategory(_ category: String?) -> [Post] {
        guard let category = category else {
            return vm.filteredPosts
        }
        return vm.filteredPosts.filter { $0.category == category }
    }
}

// MARK: - Helper Extension для Pull to Refresh

extension View {
    func refreshControl(action: @escaping () -> Void) -> some View {
        self.refreshable {
            action()
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppSyncState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    
    let vm = PostsViewModel(modelContext: context)
    let noticevm = NoticeViewModel(modelContext: context)
    
    return NavigationStack {
        HomeView(selectedCategory: "SwiftUI")
    }
    .modelContainer(container)
    .environmentObject(vm)
    .environmentObject(noticevm)
    .environmentObject(NavigationCoordinator())
}
