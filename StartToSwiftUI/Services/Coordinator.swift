//
//  NavigationCoordinator.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.12.2025.
//

import SwiftUI

// MARK: - Navigation Routes
enum AppRoute: Hashable, Identifiable {
    
    // MARK: Regular Views
    // Dealing with details
    case postDetails(postId: String)
    
    // MARK: Modal Views
    // Adding and editing posts
    // Dead end View, no further navigation
    case addPost
    case editPost(Post)
    
    // Welcome at first launch to accept Terms of Use
    case welcomeAtFirstLaunch
    
    // Preferences
    case preferences
    
    // Managing notices
    case notices // called from HomeView and Preferences
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
    
    // Denfying root modal Views (that open directly)
    var isRootModal: Bool {
        switch self {
        case .addPost, .editPost, .preferences, .notices:
            return true  // These items open as root modal Views
        default:
            return false // Other open inside other modal Views
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
class Coordinator: ObservableObject {
    
    // For regular navigation
    @Published var path = NavigationPath() {
        didSet {
            log("🏃🏼‍♀️ Coordinator: path changed. Count: \(path.count)", level: .info)
        }
    }
    
    // For modal navigation
    @Published var modalPath = NavigationPath()  {
        didSet {
            log("🏃🏼‍♀️ Modal Coordinator: path changed. Count: \(modalPath.count)", level: .info)
        }
    }

    // For modal Views
    @Published var presentedSheet: AppRoute?

    
    // MARK: Regular Navigation Methods - in fact for PostDetails only so far
    /// One level back
    func pop() {
        guard !path.isEmpty else {
            log("pop(): path is empty", level: .info)
            return
        }
        path.removeLast()
    }
    /// Move back through N levels
    func pop(levels: Int) {
        guard path.count >= levels else {
            popToRoot()
            return
        }
        path.removeLast(levels)
    }
    
    /// Current navigation depth (how many Views are in the stack)
    var currentDepth: Int {
        path.count
    }

    /// Check if we are on the root screen (HomeView)?
    var isAtRoot: Bool {
        path.isEmpty
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

    // MARK: Modal Navigation Methods
    /// Go to View
    func push(_ route: AppRoute) {
         switch route {
         case .postDetails, .welcomeAtFirstLaunch:
             path.append(route)  // ONLY PostDetails in main navigation
         default:
             presentedSheet = route  // ALL others are modal
             modalPath = NavigationPath()  // Resetting the modal path when a new View opens
         }
     }

    /// Go to View in modal navigation
    func pushModal(_ route: AppRoute) {
        modalPath.append(route)
    }
    
    /// Move one level back in modal navigation
    func popModal() {
        guard !modalPath.isEmpty else { return }
        modalPath.removeLast()
    }

    /// Return to the root of modal navigation (Preferences)
    func popModalToRoot() {
        modalPath = NavigationPath()
    }

    ///  Close modal View and return to HomeView
    func closeModal() {
        presentedSheet = nil
        modalPath = NavigationPath()
    }
}



