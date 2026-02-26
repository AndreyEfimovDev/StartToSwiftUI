//
//  ModalNavigationContainer.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 11.12.2025.
//

import SwiftUI

struct ModalNavigationContainer: View {
    
    let initialRoute: AppRoute
    
    @EnvironmentObject private var coordinator: AppCoordinator
    
    var body: some View {
        // Тested navigation for modal views
        NavigationStack(path: $coordinator.modalPath) {
            // ROOT of the stack - first view opens as root
            contentView(for: initialRoute, isRoot: true)
                .navigationDestination(for: AppRoute.self) { route in
                    // NESTED views, other sub-views are opened
                    contentView(for: route, isRoot: false)
                }
        }
        .background(Color.mycolor.myBackground)
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private func contentView(for route: AppRoute, isRoot: Bool) -> some View {
        switch route {
            
        case .postDetails(let post):
            PostDetailsView(post: post)
        case .addPost:
            AddEditPostView(post: nil)
        case .editPost(let post):
            AddEditPostView(post: post)
            
        case .preferences:
            PreferencesView()
        case .notices:
            NoticesView(isRootModal: isRoot)  // true if called from HomeView, false - from Preferences
        case .noticeDetails(let noticeId):
            NoticeDetailsView(noticeId: noticeId)

        case .studyProgress:
            StudyProgressView()
            
        case .postDrafts:
            PostDraftsView()
        case .archivedPosts:
            ArchivedPostsView()
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
            
        case .acknowledgements:
            Acknowledgements()
            
        case .aboutApp:
            AboutApp()
        case .welcome:
            WelcomeMessage()
        case .introduction:
            Introduction()
        case .functionality:
            Functionality()
        case .whatIsNew:
            WhatsNewView()
            
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
        }
    }
}
