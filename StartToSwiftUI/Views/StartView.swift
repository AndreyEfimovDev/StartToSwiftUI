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
    @State private var isLoadingData = true
    @State private var visibility: NavigationSplitViewVisibility = .doubleColumn
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            if showLaunchView {
                LaunchView() {
                    showLaunchView = false
                }
                .transition(.move(edge: .leading))
            } else if isLoadingData {
                ProgressView("Loading data...")
                    .controlSize(.large)
            } else {
                mainContent
                    .onAppear {
                        if !vm.isTermsOfUseAccepted {
                            coordinator.push(.welcomeAtFirstLaunch)
                        }
                    }
            }
        }
        .preferredColorScheme(vm.selectedTheme.colorScheme)
        .task {
            try? await Task.sleep(for: .milliseconds(100))
            isLoadingData = false
        }
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
        .onAppear {
            // Temporary - only for single SwiftUI mode
            vm.selectedCategory = "SwiftUI"
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
    
    //    @ViewBuilder
    //    private var mainContent: some View {
    //        Group {
    //            if UIDevice.isiPad {
    //                // iPad - NavigationSplitView
    //                NavigationSplitView (columnVisibility: $visibility) {
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
    //                    if let selectedCategory = vm.selectedCategory {
    //                        NavigationStack(path: $coordinator.path) {
    //                            HomeView(selectedCategory: selectedCategory)
    //                                .navigationDestination(for: AppRoute.self) { route in
    //                                    destinationView(for: route)
    //                                }
    //                        }
    //                        .navigationSplitViewColumnWidth(430)
    //                    } else {
    //                        postNotSelectedEmptyView(text: "Select Category")
    //                    }
    //                }
    //                detail: {
    //                    if let selectedPostId = vm.selectedPostId {
    //                        PostDetailsView(postId: selectedPostId)
    //                            .id(selectedPostId)
    //                    } else {
    //                        postNotSelectedEmptyView(text: "Select Topic")
    //                    }
    //                }
    //                .onAppear { // Temprorary - only for single SwiftUI mode
    //                    vm.selectedCategory = "SwiftUI"
    //                }
    //
    //            } else {
    //                // iPhone - portrait mode only
    //                NavigationStack(path: $coordinator.path) {
    //                    HomeView(selectedCategory: vm.selectedCategory)
    //                        .navigationDestination(for: AppRoute.self) { route in
    //                            destinationView(for: route)  // for PostDetails only in fact
    //                        }
    //                }
    //            }
    //        }
    //    }
    
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
    
    NavigationStack {
        StartView()
            .modelContainer(container)
            .environmentObject(AppCoordinator())
            .environmentObject(postsVM)
            .environmentObject(noticesVM)
    }
}

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
        StartView()
            .modelContainer(container)
            .environmentObject(AppCoordinator())
            .environmentObject(postsVM)
            .environmentObject(noticesVM)
    }
}

//            // Preferences
//        case .preferences:
//            PreferencesView()
//
//            // Managing notices
//        case .notices:
//            NoticesView(isRootModal: false)
//        case .noticeDetails(let noticeId):
//            NoticeDetailsView(noticeId: noticeId)
//
//            // Study progress
//        case .studyProgress:
//            StudyProgressView()
//
//            // Managing posts (materials)
//        case .postDrafts:
//            PostDraftsView()
//        case .checkForUpdates:
//            CheckForPostsUpdateView()
//        case .importFromCloud:
//            ImportPostsFromCloudView()
//        case .shareBackup:
//            SharePostsView()
//        case .restoreBackup:
//            RestoreBackupView()
//        case .erasePosts:
//            EraseAllPostsView()
//
//            // Gratitude
//        case .acknowledgements:
//            Acknowledgements()
//
//            // About App
//        case .aboutApp:
//            AboutApp()
//        case .welcome:
//            WelcomeMessage()
//        case .introduction:
//            Introduction()
//        case .whatIsNew:
//            WhatsNewView()
//
//            // Legal information
//        case .legalInfo:
//            LegalInformationView()
//        case .termsOfUse:
//            TermsOfUse()
//        case .privacyPolicy:
//            PrivacyPolicy()
//        case .copyrightPolicy:
//            CopyrightPolicy()
//        case .fairUseNotice:
//            FairUseNotice()
