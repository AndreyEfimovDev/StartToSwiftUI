//
//  AppCoordinator.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.12.2025.
//

import SwiftUI

// MARK: - App Section

enum AppSection: String {
    case materials
    case snippets

//    var switchIcon: String { "arrow.left.arrow.right" }

    /// Icon that hints at the OTHER section (what you'll switch TO)
    var switchLabel: String {
        switch self {
        case .materials: return "ellipsis.curlybraces" // chevron.left.forwardslash.chevron.right 
        case .snippets:  return "book" // graduationcap
        }
    }
}

// MARK: - AppCoordinator

final class AppCoordinator: ObservableObject {
    
    private let hapticManager = HapticManager.shared

    // MARK: - Section
    @AppStorage("activeSection") var activeSection: AppSection = .snippets
    
    // MARK: - Navigation
    /// For main stack navigation
    @Published var path = NavigationPath() {
        didSet {
            log("Coordinator: path changed. Count: \(path.count)", level: .info)
        }
    }
    /// For modal stack navigation
    @Published var modalPath = NavigationPath()  {
        didSet {
            log("Modal Coordinator: path changed. Count: \(modalPath.count)", level: .info)
        }
    }
    /// For modal Views
    @Published var presentedSheet: AppRoute?
    
    
    // MARK: - Section Switch
    /// Switches between Materials and Snippets, resetting the navigation path.
    func switchSection() {
        path = NavigationPath()
        activeSection = activeSection == .materials ? .snippets : .materials
        hapticManager.impact(style: .light)
        log("Switched to section: \(activeSection)", level: .info)
    }
    // MARK: - Main Stack
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
    var currentDepth: Int { path.count }

    /// Check if we are on the root screen (MaterialsHomeView)?
    var isAtRoot: Bool { path.isEmpty }

    /// Return to Home
    func popToRoot() { path = NavigationPath() }
    
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
         case .snippetDetails:
             path.append(route)   // push on main stack
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
    func popModalToRoot() { modalPath = NavigationPath() }

    ///  Close modal View and return to MaterialsHomeView
    func closeModal() {
        presentedSheet = nil
        modalPath = NavigationPath()
    }
}

// MARK: - Navigation Routes
enum AppRoute: Hashable, Identifiable {
    
    // MARK: Posts
    case postDetails(post: Post)
    case addPost
    case editPost(Post)

    // MARK: Preferences (modal root)
    case preferences

    // MARK: Notices
    case notices
    case noticeDetails(noticeId: String)

    // MARK: Study progress
    case studyProgress
    
    // MARK: Managing posts (modal)
    case postDrafts
    case archivedPosts
    case checkForUpdates
    case importFromCloud
    case shareBackup
    case restoreBackup
    case erasePosts
    
    // MARK: Snippets
    case snippetDetails(snippet: CodeSnippet)

    // MARK: About / Legal
    case acknowledgements
    case aboutApp
    case welcome
    case introduction
    case functionality
    case whatIsNew
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

    // MARK: id
    var id: String {
        switch self {
        case .postDetails(let p):       return "postDetails_\(p.id)"
        case .addPost:                  return "addPost"
        case .editPost(let p):          return "editPost_\(p.id)"
        case .preferences:              return "preferences"
        case .notices:                  return "notices"
        case .noticeDetails(let id):    return "noticeDetails_\(id)"
        case .studyProgress:            return "studyProgress"
        case .postDrafts:               return "postDrafts"
        case .archivedPosts:            return "archivedPosts"
        case .checkForUpdates:          return "checkForUpdates"
        case .importFromCloud:          return "importFromCloud"
        case .shareBackup:              return "shareBackup"
        case .restoreBackup:            return "restoreBackup"
        case .erasePosts:               return "erasePosts"
        case .snippetDetails(let s):    return "snippetDetails_\(s.id)"
        case .acknowledgements:         return "acknowledgements"
        case .aboutApp:                 return "aboutApp"
        case .welcome:                  return "welcome"
        case .introduction:             return "introduction"
        case .functionality:            return "functionality"
        case .whatIsNew:                return "whatIsNew"
        case .legalInfo:                return "legalInfo"
        case .termsOfUse:               return "termsOfUse"
        case .privacyPolicy:            return "privacyPolicy"
        case .copyrightPolicy:          return "copyrightPolicy"
        case .fairUseNotice:            return "fairUseNotice"
        }
    }
}

