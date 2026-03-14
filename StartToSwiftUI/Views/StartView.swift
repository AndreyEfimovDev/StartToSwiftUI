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
    
    @StateObject private var errorManager = ErrorManager.shared

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
                    .alert("Error", isPresented: $errorManager.showAlert) {
                        Button("OK") {}
                    } message: {
                        Text(errorManager.errorMessage ?? "")
                    }
                    .task {
                        vm.selectedCategory = vm.mainCategory
                        vm.loadPostsFromSwiftData()
                        noticevm.loadNoticesFromSwiftData()
                        vm.updateWidgetData()
                        vm.isFiltersEmpty = vm.checkIfAllFiltersAreEmpty()
                        snippetsvm.isFiltersEmpty = snippetsvm.checkIfAllFiltersAreEmpty()
                        /* Clean dublicates if any. iCloud sync can create multiple appsyncstates on different devices. This function finds duplicates, merges their data into one (the oldest), and deletes the rest. */
                        vm.appStateManager?.cleanupDuplicateAppStates()
                        await noticevm.importNoticesFromFirebase()
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
