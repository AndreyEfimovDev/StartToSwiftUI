//
//  NavigationCoordinator.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.12.2025.
//

import SwiftUI

// MARK: - Navigation Routes
enum AppRoute: Hashable, Identifiable {
    
    // Dealing with details
    case postDetails(postId: String)
        
    // Addind and editing posts
    case addPost
    case editPost(Post)
    
    // Welcome at first launch to accept Terms of Use
    case welcomeAtFirstLaunch
    
    // Preferences
    case preferences
    
    // Managing notices
    case notices
    case noticeDetails(noticeId: String)

    // Study progress
    case studyProgress
    
    // Managing posts (materials)
    case postDrafts
    case checkForUpdates
    case importFromCloud
    case shareBackup
    case restoreBackup
    case erasePosts
    
    // Gratitude
    case acknowledgements
    
    // About App
    case aboutApp
    case welcome
    case introduction
    case whatIsNew
    
    // Legal information
    case legalInfo
    case termsOfUse
    case privacyPolicy
    case copyrightPolicy
    case fairUseNotice
    
    var shouldOpenAsModal: Bool {
        switch self {
        case .addPost, .editPost:
            return true  // We open these cases as modal - for AddEditView
        default:
            return false // The rest is regular navigation
        }
    }

    var id: String {
        switch self {
        case .postDetails(let postId):
            return "postDetails_\(postId)"
        case .addPost:
            return "addPost"
        case .editPost(let post):
            return "editPost_\(post.id)"
        case .welcomeAtFirstLaunch:
            return "welcomeAtFirstLaunch"
        case .preferences:
            return "preferences"
        case .notices:
            return "notices"
        case .noticeDetails(let noticeId):
            return "noticeDetails_\(noticeId)"
        case .studyProgress:
            return "studyProgress"
        case .postDrafts:
            return "postDrafts"
        case .checkForUpdates:
            return "checkForUpdates"
        case .importFromCloud:
            return "importFromCloud"
        case .shareBackup:
            return "shareBackup"
        case .restoreBackup:
            return "restoreBackup"
        case .erasePosts:
            return "erasePosts"
        case .acknowledgements:
            return "acknowledgements"
        case .aboutApp:
            return "aboutApp"
        case .welcome:
            return "welcome"
        case .introduction:
            return "introduction"
        case .whatIsNew:
            return "whatIsNew"
        case .legalInfo:
            return "legalInfo"
        case .termsOfUse:
            return "termsOfUse"
        case .privacyPolicy:
            return "privacyPolicy"
        case .copyrightPolicy:
            return "copyrightPolicy"
        case .fairUseNotice:
            return "fairUseNotice"
        }
    }

}

// MARK: - Navigation Coordinator
@MainActor
class NavigationCoordinator: ObservableObject {
    @Published var path = NavigationPath() {
        didSet {
            log("📱 NavigationCoordinator: path changed. Count: \(path.count)", level: .info)
        }
    }
    
    // For modal Views
    @Published var presentedSheet: AppRoute?

    
    /// Current navigation depth (how many screens are in the stack)
    var currentDepth: Int {
        path.count
    }

    /// Are we on the root screen (HomeView)?
    var isAtRoot: Bool {
        path.isEmpty
    }

    // MARK: - Navigation Methods
    /// Go to View
    func push(_ route: AppRoute) {
        // If AddEditView - open it as a modal
        if route.shouldOpenAsModal {
            presentedSheet = route
        } else {
            // The rest is regular navigation
            path.append(route)
        }
    }

    func dismissModal() {
        presentedSheet = nil
    }

    /// One level back
    func pop() {
        guard !path.isEmpty else {
            log("pop(): path is empty", level: .info)
            return
        }
        path.removeLast()
    }
    
    /// Back through N levels
    func pop(levels: Int) {
        guard path.count >= levels else {
            popToRoot()
            return
        }
        path.removeLast(levels)
    }
    
    /// Return to HomeView
    func popToRoot() {
        path = NavigationPath()
    }
    
    /// Replace the current View
    func replace(with route: AppRoute) {
        if !path.isEmpty {
            path.removeLast()
        }
        path.append(route)
    }
}
