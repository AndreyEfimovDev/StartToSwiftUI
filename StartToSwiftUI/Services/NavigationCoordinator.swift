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
            print("📱 NavigationCoordinator: path changed. Count: \(path.count)")
        }
    }

    // Модальные окна (не входят в path)
//    @Published var showAddPost = false
//    @Published var showEditPost: Post?
//    @Published var showPreferences = false
    @Published var showNotices = false
    
    /// Текущая глубина навигации (сколько экранов в стеке)
    var currentDepth: Int {
        path.count
    }

    /// Находимся ли мы на корневом экране (HomeView)
    var isAtRoot: Bool {
        path.isEmpty
    }

    // MARK: - Navigation Methods
    
    /// Переход на экран
    func push(_ route: AppRoute) {
        path.append(route)
    }
    
    /// Назад на 1 уровень
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    /// Назад через N уровней
    func pop(levels: Int) {
        guard path.count >= levels else {
            popToRoot()
            return
        }
        path.removeLast(levels)
    }
    
    /// Вернуться в HomeView
    func popToRoot() {
        path = NavigationPath()
    }
    
    /// Заменить текущий экран
    func replace(with route: AppRoute) {
        if !path.isEmpty {
            path.removeLast()
        }
        path.append(route)
    }
    
    // MARK: - Modal Methods
    
//    func presentAddPost() {
//        showAddPost = true
//    }
//    
//    func presentEditPost(_ post: Post) {
//        showEditPost = post
//    }
    
//    func presentPreferences() {
//        showPreferences = true
//    }
    
    func presentNotices() {
        showNotices = true
    }
    
    func dismissModals() {
//        showAddPost = false
//        showEditPost = nil
//        showPreferences = false
        showNotices = false
    }
}
