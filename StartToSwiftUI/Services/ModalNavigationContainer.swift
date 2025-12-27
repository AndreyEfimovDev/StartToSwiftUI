//
//  ModalNavigationContainer.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 11.12.2025.
//

import SwiftUI

struct ModalNavigationContainer: View {
    
    let initialRoute: AppRoute
    
    @EnvironmentObject private var coordinator: Coordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.modalPath) {
            contentView(for: initialRoute, isRoot: true)
                .navigationDestination(for: AppRoute.self) { route in
                    contentView(for: route, isRoot: false)
                }
        }
        .background(Color.mycolor.myBackground)
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private func contentView(for route: AppRoute, isRoot: Bool) -> some View {
        switch route {
//        case .welcomeAtFirstLaunch:
//            WelcomeAtFirstLaunchView()
        case .preferences:
            PreferencesView()
        case .notices:
            NoticesView(isRootModal: isRoot)  // true if called from HomeView, false - is from Preferences
        case .addPost:
            AddEditPostSheet(post: nil)
        case .editPost(let post):
            AddEditPostSheet(post: post)
        case .studyProgress:
            StudyProgressView()
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
        case .acknowledgements:
            Acknowledgements()
        case .aboutApp:
            AboutApp()
        case .welcome:
            WelcomeMessage()
        case .introduction:
            Introduction()
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
        case .noticeDetails(let noticeId):
            NoticeDetailsView(noticeId: noticeId)
        default:
            EmptyView()
        }
    }
}
