//
//  ContentViewWrapper.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 14.12.2025.
//

import SwiftUI
import SwiftData
import Combine

struct StartView: View {

    // MARK: - Dependencies
    @ObservedObject private var vm: PostsViewModel
    @ObservedObject private var noticevm: NoticesViewModel
    @ObservedObject private var snippetsvm: SnippetsViewModel
    @ObservedObject private var coordinator: AppCoordinator
    @ObservedObject private var errorManager: ErrorManager
    private let appStoreService: AppStoreService
    private let remoteConfigService: RemoteConfigServiceProtocol

    init(dependencies: AppDependencies) {
        _vm = ObservedObject(wrappedValue: dependencies.postsViewModel)
        _noticevm = ObservedObject(wrappedValue: dependencies.noticesViewModel)
        _snippetsvm = ObservedObject(wrappedValue: dependencies.snippetsViewModel)
        _coordinator = ObservedObject(wrappedValue: dependencies.coordinator)
        _errorManager = ObservedObject(wrappedValue: dependencies.services.errorManager)
        appStoreService = dependencies.appStoreService
        remoteConfigService = dependencies.remoteConfigService
    }

    // MARK: - States
    @State private var showLaunchView: Bool = true
    @State private var splitViewVisibility: NavigationSplitViewVisibility = .doubleColumn
    /// В compact-ширине (узкий Split View/Slide Over — влезает только одна
    /// колонка) NavigationSplitView схлопывается в push-навигацию, и
    /// columnVisibility не управляет тем, что видно на экране — свою
    /// sidebar-кнопку сворачивания там показывать не нужно.
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // MARK: - Section Transition State
    /// A local copy of the section that we are changing through withAnimation
    @State private var displayedSection: AppSection = .materials
    /// true = forward (materials → snippets), false = backward
    @State private var isGoingForward: Bool = true
    
    // MARK: - Section Transition Helper (is not used)
    private var sectionTransition: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 0.97)),
            removal:   .opacity.combined(with: .scale(scale: 0.97))
        )
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            if showLaunchView {
                LaunchView() { showLaunchView = false }
                    .transition(.move(edge: .leading))
            } else {
                mainContent
                    .alert("Error", isPresented: $errorManager.showAlert) {
                        Button("OK") {}
                    } message: {
                        Text(errorManager.errorMessage ?? "")
                    }
                    .task {
                        displayedSection = coordinator.activeSection
                        vm.loadPostsFromSwiftData()
                        noticevm.loadNoticesFromSwiftData()
                        vm.updateWidgetData()
                        vm.isFiltersEmpty = vm.checkIfAllFiltersAreEmpty()
                        /* Clean dublicates if any. iCloud sync may create multiple appSyncStates on different devices. This function finds duplicates, merges their data into one (the oldest), and deletes the rest.
                         */
                        vm.appStateManager?.cleanupDuplicateAppStates()
                        await noticevm.importNoticesFromFirebase()
                    }
                    .onChange(of: coordinator.activeSection) { oldSection, newSection in
                        isGoingForward = newSection.transitionIndex > oldSection.transitionIndex
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            displayedSection = newSection
                        }
                    }
            }
        }
        .preferredColorScheme(vm.selectedTheme.colorScheme)
        .adaptiveModal(item: $coordinator.presentedSheet)
        .environmentObject(vm)
        .environmentObject(noticevm)
        .environmentObject(snippetsvm)
        .environmentObject(coordinator)
        .environmentObject(errorManager)
        .environment(\.appStoreService, appStoreService)
        .environment(\.remoteConfigService, remoteConfigService)
    }
    
    // MARK: Main Content
    
    @ViewBuilder
    private var mainContent: some View {
        if UIDevice.isiPad {
            iPadContent
        } else {
            iPhoneContent
        }
    }
    
    // iPhone: single NavigationStack, root switches with activeSection
    @ViewBuilder
    private var iPhoneContent: some View {
        Group {
            switch displayedSection {
            case .materials:
                NavigationStack(path: $coordinator.path) {
                    MaterialsHomeView(selectedCategory: Constants.mainCategory)
                        .navigationDestination(for: AppRoute.self) { destinationView(for: $0) }
                }
                .transition(sectionTransition)
            case .snippets:
                NavigationStack(path: $coordinator.path) {
                    SnippetsHomeView()
                        .navigationDestination(for: AppRoute.self) { destinationView(for: $0) }
                }
                .transition(sectionTransition)
            }
        }
    }
    
    // iPad: NavigationSplitView — same section switch in the primary column
    @ViewBuilder
    private var iPadContent: some View {
        NavigationSplitView(columnVisibility: $splitViewVisibility) {
            Group {
                switch displayedSection {
                case .materials:
                    MaterialsHomeView(selectedCategory: Constants.mainCategory)
                        .transition(sectionTransition)
                case .snippets:
                    SnippetsHomeView()
                        .transition(sectionTransition)
                }
            }
            .navigationSplitViewColumnWidth(430)
            .toolbar(removing: .sidebarToggle)
            .toolbar { sidebarSplitViewToggleItem }
        } detail: {
            Group {
                switch displayedSection {
                case .materials:
                    if let post = vm.selectedPost {
                        PostDetailsView(post: post).id(post.id)
                    } else {
                        placeholderView(text: "Select Topic")
                    }
                case .snippets:
                    if let snippet = snippetsvm.selectedSnippet {
                        SnippetDetailsView(snippet: snippet).id(snippet.id)
                    } else {
                        placeholderView(text: "Select Snippet")
                    }
                }
            }
            // Системная sidebarToggle-кнопка переезжает в nav bar detail-колонки,
            // когда sidebar скрыт (detailOnly) — прячем её и здесь тоже,
            // иначе своя кнопка добавится, а системная белая останется рядом.
            .toolbar(removing: .sidebarToggle)
            .toolbar { detailSplitViewToggleItem }
        }
    }

    private func toggleSplitViewVisibility() {
        withAnimation {
            splitViewVisibility = splitViewVisibility == .detailOnly ? .doubleColumn : .detailOnly
        }
        HapticManager.shared.impact(style: .light)
    }

    /// Замена системной sidebarToggle-кнопки `NavigationSplitView` — та в iOS 26
    /// (Liquid Glass) не подхватывает ни `.tint()`, ни `UIWindow`/`UINavigationBar`
    /// tintColor (подтверждённый баг Apple, не наш код), поэтому всегда рисуется
    /// белой. Своя кнопка красится явно через CircleStrokeButtonView, как и
    /// остальные иконки нав-бара.
    ///
    /// В отличие от системной, показывается только в ОДНОЙ колонке за раз —
    /// в sidebar, когда он виден, и в detail, когда он открыт на весь экран
    /// (sidebar скрыт) — а не в обеих одновременно.
    /// Сворачивать sidebar в пустой placeholder ("Select Topic"/"Select
    /// Snippet") смысла нет — тогда detail-колонка пуста, а вернуться
    /// назад можно только тем же переключением, что мы прячем.
    private var hasSelectionInDisplayedSection: Bool {
        switch displayedSection {
        case .materials: vm.selectedPost != nil
        case .snippets: snippetsvm.selectedSnippet != nil
        }
    }

    @ToolbarContentBuilder
    private var sidebarSplitViewToggleItem: some ToolbarContent {
        if splitViewVisibility != .detailOnly && horizontalSizeClass != .compact && hasSelectionInDisplayedSection {
            ToolbarItem(placement: .navigationBarLeading) {
                CircleStrokeButtonView(iconName: "sidebar.left", isShownCircle: false, completion: toggleSplitViewVisibility)
            }
        }
    }

    @ToolbarContentBuilder
    private var detailSplitViewToggleItem: some ToolbarContent {
        if splitViewVisibility == .detailOnly {
            ToolbarItem(placement: .navigationBarLeading) {
                CircleStrokeButtonView(iconName: "sidebar.left", isShownCircle: false, completion: toggleSplitViewVisibility)
            }
        }
    }

    // MARK: - Destination View for routing
    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
            // Posts
        case .postDetails(let post):
            PostDetailsView(post: post)
            
            // Snippets — push on main stack
        case .snippetDetails(let snippet):
            SnippetDetailsView(snippet: snippet)
                .environmentObject(snippetsvm)
            
        default:
            EmptyView()
        }
    }
    
    // MARK: - Placeholder
    private func placeholderView(text: String) -> some View {
        ContentUnavailableView(text, systemImage: "arrow.left")
            .foregroundStyle(Color.mycolor.myAccent)
    }
    
}

// MARK: - Preview

#Preview("With Mock Data") {
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppSyncState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let services = AppServiceDependencies.make()
    let stateManager = AppSyncStateManager(modelContext: container.mainContext)
    let postsVM = PostsViewModel(dataSource: MockPostsDataSource(), fbPostsManager: MockFBPostsManager(), services: services)
    let dependencies = AppDependencies(
        appStateManager: stateManager,
        services: services,
        appStoreService: AppStoreService(),
        remoteConfigService: MockRemoteConfigService(),
        postsViewModel: postsVM,
        noticesViewModel: NoticesViewModel(dataSource: MockNoticesDataSource(), fbNoticesManager: MockFBNoticesManager(), services: services),
        snippetsViewModel: SnippetsViewModel(services: services),
        coordinator: AppCoordinator()
    )

    return StartView(dependencies: dependencies)
        .modelContainer(container)
        .task { postsVM.start() }
}
