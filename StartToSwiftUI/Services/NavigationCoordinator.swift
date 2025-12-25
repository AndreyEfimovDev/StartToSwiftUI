//
//  NavigationCoordinator.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.12.2025.
//

import SwiftUI

// MARK: - Navigation Routes
enum AppRoute: Hashable {
    
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

}

// MARK: - Navigation Coordinator
@MainActor
class NavigationCoordinator: ObservableObject {
    @Published var path = NavigationPath() {
        didSet {
//            log("📱 NavigationCoordinator: path changed. Count: \(path.count)", level: .info)
        }
    }
    @Published var showNotices = false
    
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
        path.append(route)
    }
    
    /// One level back
    func pop() {
        guard !path.isEmpty else { return }
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
