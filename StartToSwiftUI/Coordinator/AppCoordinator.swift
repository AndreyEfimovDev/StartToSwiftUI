//
//  AppCoordinator.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.12.2025.
//

import SwiftUI

final class AppCoordinator: ObservableObject {
    
    private let hapticManager = HapticManager.shared

    // For main stack navigation
    @Published var path = NavigationPath() {
        didSet {
            log("Coordinator: path changed. Count: \(path.count)", level: .info)
        }
    }
    
    // For modal stack navigation
    @Published var modalPath = NavigationPath()  {
        didSet {
            log("Modal Coordinator: path changed. Count: \(modalPath.count)", level: .info)
        }
    }

    // For modal Views
    @Published var presentedSheet: AppRoute?
    
    // MARK: Main Stack Navigation Methods - in fact for PostDetails only so far
    /// One level back
    func pop() {
        guard !path.isEmpty else {
            log("pop(): path is empty", level: .info)
            hapticManager.impact(style: .light)
            return
        }
        path.removeLast()
    }
    /// Move back through N levels
    func pop(levels: Int) {
        guard path.count >= levels else {
            popToRoot()
            hapticManager.impact(style: .light)
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

    /// Go to View
    func push(_ route: AppRoute) {
         switch route {
         case .postDetails:
             if modalPath.isEmpty { // if empty it is called in main stack
                 path.append(route) // To the main stack
             } else { // if not empty it is called in modal stack
                 presentedSheet = route
                 modalPath = NavigationPath()
             }
         default:
             presentedSheet = route  // ALL others are modal, opens a modal view
             modalPath = NavigationPath()  // Resets the modal stack, resetting the modal path when a new View opens
         }
     }
    
    // MARK: Modal Navigation Methods
    /// Go to View in modal navigation
    func pushModal(_ route: AppRoute) {
        modalPath.append(route)
    }
    
    /// Move one level back in modal navigation
    func popModal() {
        guard !modalPath.isEmpty else {
            hapticManager.impact(style: .light)
            return
        }
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

// MARK: - Navigation Routes
enum AppRoute: Hashable, Identifiable {
    
    // Dealing with details
    case postDetails(post: Post)
    
    // Adding and editing posts
    case addPost
    case editPost(Post)
        
    // Preferences
    case preferences
    
    // Managing notices
    case notices // called from HomeView and Preferences
    case noticeDetails(noticeId: String)

    // Study progress
    case studyProgress
    
    // Managing posts
    case postDrafts
    case archivedPosts
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
    case functionality
    case whatIsNew
    
    // Legal information
    case legalInfo
    case termsOfUse
    case privacyPolicy
    case copyrightPolicy
    case fairUseNotice
    
    // Set root modal Views to manage different behaviour
    var isRootModal: Bool {
        switch self {
        case .preferences, .notices, .aboutApp, .legalInfo:
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
        case .archivedPosts:
            return "archivedPosts"
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
        case .functionality:
            return "functionality"
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

