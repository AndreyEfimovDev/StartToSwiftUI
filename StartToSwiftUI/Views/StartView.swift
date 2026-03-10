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
    @EnvironmentObject private var vm: PostsViewModel
    @EnvironmentObject private var noticevm: NoticesViewModel
    @EnvironmentObject private var snippetsvm: SnippetsViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    
    // MARK: - States
    @State private var showLaunchView: Bool = true
    @State private var visibility: NavigationSplitViewVisibility = .doubleColumn
    
    // MARK: - Body
    var body: some View {
        ZStack {
            if showLaunchView {
                LaunchView() { showLaunchView = false }
                .transition(.move(edge: .leading))
            } else {
                mainContent
                    .task {
                        vm.selectedCategory = vm.mainCategory
                        noticevm.loadNoticesFromSwiftData()
                        await noticevm.importNoticesFromFirebase()
                        vm.loadPostsFromSwiftData()
                        vm.updateWidgetData()
                        vm.isFiltersEmpty = vm.checkIfAllFiltersAreEmpty()
                    }
            }
        }
        .preferredColorScheme(vm.selectedTheme.colorScheme)
        .adaptiveModal(item: $coordinator.presentedSheet)
        .environmentObject(vm)
        .environmentObject(noticevm)
        .environmentObject(snippetsvm)
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
        switch coordinator.activeSection {
        case .materials:
            NavigationStack(path: $coordinator.path) {
                HomeView(selectedCategory: vm.selectedCategory)
                    .navigationDestination(for: AppRoute.self) { destinationView(for: $0) }
            }
        case .snippets:
            NavigationStack(path: $coordinator.path) {
                SnippetsHomeView()
                    .navigationDestination(for: AppRoute.self) { destinationView(for: $0) }
            }
        }
    }

    // iPad: NavigationSplitView — same section switch in the primary column
    @ViewBuilder
    private var iPadContent: some View {
        NavigationSplitView(columnVisibility: $visibility) {
            Group {
            switch coordinator.activeSection {
                case .materials:
                    HomeView(selectedCategory: vm.selectedCategory)
                case .snippets:
                    SnippetsHomeView()
                }
            }
            .navigationSplitViewColumnWidth(430)
        } detail: {
            switch coordinator.activeSection {
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
    }

    // Switches root view based on active section
    @ViewBuilder
    private var sectionRootView: some View {
        switch coordinator.activeSection {
        case .materials:
            HomeView(selectedCategory: vm.selectedCategory)
        case .snippets:
            SnippetsHomeView()
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
    }
    
}

// MARK: - Shared Toolbar Items
// Used by HomeView and SnippetsHomeView — call from their @ToolbarContentBuilder

struct SharedToolbarLeadingItems: ToolbarContent {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var vm: PostsViewModel
    @EnvironmentObject private var noticevm: NoticesViewModel

    var body: some ToolbarContent {
        // ⚙️ Preferences
        ToolbarItem(placement: .topBarLeading) {
            CircleStrokeButtonView(iconName: "gearshape", isShownCircle: false) {
                coordinator.push(.preferences)
            }
        }

        // 🔔 Notices badge (only when unread)
        if noticevm.unreadCount > 0 {
            ToolbarItem(placement: .navigationBarLeading) {
                noticeButton
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
        .background(
            Circle()
                .stroke(Color.mycolor.myRed,
                        lineWidth: noticevm.shouldAnimateNoticeButton ? 3 : 0)
                .scaleEffect(noticevm.shouldAnimateNoticeButton ? 1.2 : 0.8)
                .opacity(noticevm.shouldAnimateNoticeButton ? 0 : 1)
                .animation(
                    noticevm.shouldAnimateNoticeButton ? .easeOut(duration: 1.0) : .none,
                    value: noticevm.shouldAnimateNoticeButton
                )
        )
    }
}

struct SharedToolbarSwitchItem: ToolbarContent {
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some ToolbarContent {
        // ⇄ Switch section — always visible, shows icon hinting at the OTHER section
        ToolbarItem(placement: .topBarTrailing) {
            CircleStrokeButtonView(
                iconName: coordinator.activeSection.switchLabel,
                isShownCircle: false
            ) {
                coordinator.switchSection()
            }
        }
    }
}

// MARK: - Preview

private struct StartViewPreview: View {
    @StateObject var vm: PostsViewModel = {
        let vm = PostsViewModel(dataSource: MockPostsDataSource(), fbPostsManager: MockFBPostsManager())
        vm.start()
        return vm
    }()
    @StateObject var noticesVM = NoticesViewModel(dataSource: MockNoticesDataSource(), fbNoticesManager: MockFBNoticesManager())
    var body: some View {
        StartView()
            .environmentObject(AppCoordinator())
            .environmentObject(vm)
            .environmentObject(noticesVM)
    }
}

#Preview("With Mock Data") {
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppSyncState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    StartViewPreview().modelContainer(container)
}
