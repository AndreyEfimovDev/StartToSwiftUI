//
//  ContentViewWrapper.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 17.12.2025.
//

import SwiftUI
import SwiftData

struct StartView: View {
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var coordinator: NavigationCoordinator
    
    @StateObject private var vm: PostsViewModel
    @StateObject private var noticevm: NoticeViewModel
    
    @State private var showLaunchView: Bool = true
    @State private var isLoadingData = true
    
    // MARK: - Init
    init(modelContext: ModelContext) {
        _vm = StateObject(wrappedValue: PostsViewModel(modelContext: modelContext))
        _noticevm = StateObject(wrappedValue: NoticeViewModel(modelContext: modelContext))
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            if showLaunchView {
                LaunchView() {
                    showLaunchView = false
                }
                .transition(.move(edge: .leading))
            } else if isLoadingData {
                ProgressView("...loading data...")
                    .controlSize(.large)
            } else {
                mainContent
            }
        }
        .preferredColorScheme(vm.selectedTheme.colorScheme)
        .task {
            await loadInitialData()
        }
        .fullScreenCover(item: $coordinator.presentedSheet) { route in
            if UIDevice.isiPad {
                ModalNavigationContainer(initialRoute: route)
                    .presentationDetents([.large])  // На iPad можно sheet
                    .presentationDragIndicator(.visible)
            } else {
                ModalNavigationContainer(initialRoute: route)
            }
        }
        .environmentObject(vm)
        .environmentObject(noticevm)
    }
    
    // MARK: - Subviews
    @ViewBuilder
    private var mainContent: some View {
        if UIDevice.isiPad {
            // iPad - NavigationSplitView
            EmptyView()
//            SidebarView()
        } else {
            // iPhone - NavigationStack (portrait only)
            NavigationStack(path: $coordinator.path) {
                HomeView(selectedCategory: vm.selectedCategory)
                    .navigationDestination(for: AppRoute.self) { route in
                        if case .postDetails(let postId) = route {
                            PostDetailsView(postId: postId)
                        }
                    }
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
                    
            // Welcome at first launch to accept Terms of Use
        case .welcomeAtFirstLaunch:
            WelcomeAtFirstLaunchView()

            // Preferences
        case .preferences:
            PreferencesView()

            // Managing notices
        case .notices:
            NoticesView(isRootModal: false)
        case .noticeDetails(let noticeId):
            NoticeDetailsView(noticeId: noticeId)

            // Study progress
        case .studyProgress:
            StudyProgressView()

            // Managing posts (materials)
        case .postDrafts:
            PostDraftsView()
        case .checkForUpdates:
            CheckForPostsUpdateView()
        case .importFromCloud:
            ImportPostsFromCloudView()
        case .shareBackup:
            SharePostsView()
        case .restoreBackup:
            RestoreBackupView()
        case .erasePosts:
            EraseAllPostsView()
            
            // Gratitude
        case .acknowledgements:
            Acknowledgements()
            
            // About App
        case .aboutApp:
            AboutApp()
        case .welcome:
            WelcomeMessage()
        case .introduction:
            Introduction()
        case .whatIsNew:
            WhatsNewView()
            
            // Legal information
        case .legalInfo:
            LegalInformationView()
        case .termsOfUse:
            TermsOfUse()
        case .privacyPolicy:
            PrivacyPolicy()
        case .copyrightPolicy:
            CopyrightPolicy()
        case .fairUseNotice:
            FairUseNotice()
        default:
                EmptyView()
        }
        

    }
    
    // Модальные вью (для .sheet)
    @ViewBuilder
    private func modalSheetView(for route: AppRoute) -> some View {
        switch route {
        case .addPost:
            AddEditPostSheet(post: nil)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        case .editPost(let post):
            AddEditPostSheet(post: post)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        default:
            EmptyView()
        }
    }


    // MARK: - Data Loading
    private func loadInitialData() async {
        // Clearing duplicate AppState from previous runs (Xcode)
        let appStateManager = AppSyncStateManager(modelContext: modelContext)
        appStateManager.cleanupDuplicateAppStates()
        
        vm.loadPostsFromSwiftData()
        
        // If necessary, load static posts on first launch
        await vm.loadStaticPostsIfNeeded()
        
        // Import notifications (includes deleting duplicates)
        await noticevm.importNoticesFromCloud()
        
        isLoadingData = false
    }
}




#Preview("Simple Test") {
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppSyncState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let context = container.mainContext

    NavigationStack {
        StartView(modelContext: context)
            .modelContainer(container)
            .environmentObject(NavigationCoordinator())
    }
}
