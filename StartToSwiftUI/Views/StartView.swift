//
//  ContentViewWrapper.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 14.12.2025.
//

import SwiftUI
import SwiftData

struct StartView: View {
    
    // MARK: - Dependencies
    @EnvironmentObject private var vm: PostsViewModel
    @EnvironmentObject private var noticevm: NoticeViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    
    // MARK: - States
    @State private var showLaunchView: Bool = true
    @State private var visibility: NavigationSplitViewVisibility = .doubleColumn
    
    // MARK: - Body
    var body: some View {
        ZStack {
            if showLaunchView {
                LaunchView() {
                    showLaunchView = false
                }
                .transition(.move(edge: .leading))
            } else {
                mainContent
                    .onAppear {
                        vm.selectedCategory = vm.mainCategory
                    }
            }
        }
        .preferredColorScheme(vm.selectedTheme.colorScheme)
        .adaptiveModal(item: $coordinator.presentedSheet)
        .environmentObject(vm)
        .environmentObject(noticevm)
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
    
    private var iPadContent: some View {
        NavigationSplitView(columnVisibility: $visibility) {
#if DEBUG
#warning("Delete this commented out code snippet before deployment")
            //                    //                if let categories = vm.allCategories {
            //                    //                    List(categories, id: \.self, selection: $vm.selectedCategory) { category in
            //                    //                        Text(category)
            //                    //                    }
            //                    //                    .navigationTitle("Categories")
            //                    //                    .navigationSplitViewColumnWidth(150)
            //                    //                } else {
            //                    //                    Text("No categories")
            //                    //                }
            //                    //            } content: {
#else
    #error("Remove this debug code before App Store release!")
#endif
            if let selectedCategory = vm.selectedCategory {
                NavigationStack(path: $coordinator.path) {
                    HomeView(selectedCategory: selectedCategory)
                        .navigationDestination(for: AppRoute.self) { route in
                            destinationView(for: route)
                        }
                }
                .navigationSplitViewColumnWidth(430)
            } else {
                postNotSelectedEmptyView(text: "Select Category")
            }
        } detail: {
            if let selectedPostId = vm.selectedPostId {
                PostDetailsView(postId: selectedPostId)
                    .id(selectedPostId)
            } else {
                postNotSelectedEmptyView(text: "Select Topic")
            }
        }
    }
    
    private var iPhoneContent: some View {
        NavigationStack(path: $coordinator.path) {
            HomeView(selectedCategory: vm.selectedCategory)
                .navigationDestination(for: AppRoute.self) { route in
                    destinationView(for: route)
                }
        }
    }
    
    // MARK: - Destination View for routing
    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
            // Post details View
        case .postDetails(let postId):
            PostDetailsView(postId: postId)
        default:
            EmptyView()
        }
    }
}

#Preview("StartView with Mock Data") {
    let postsVM = PostsViewModel(
        dataSource: MockPostsDataSource(posts: PreviewData.samplePosts)
    )
    let noticesVM = NoticeViewModel(
        dataSource: MockNoticesDataSource(notices: PreviewData.sampleNotices)
    )
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppSyncState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    StartView()
        .modelContainer(container)
        .environmentObject(AppCoordinator())
        .environmentObject(postsVM)
        .environmentObject(noticesVM)
    
}
