//
//  NavigationCoordinator.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 23.12.2025.
//

import SwiftUI

// MARK: - Navigation Routes
enum AppRoute: Hashable {
    // Main flow
    case postDetails(postId: String)
    
    // Preferences flow
    case preferences
    case studyProgress
    case postDrafts
    case checkForUpdates
    case importFromCloud
    case shareBackup
    case restoreBackup
    case erasePosts
    case notices
    case acknowledgements
    case aboutApp
    case legalInfo
    
    // Modals (will be handled separately)
    case addPost
    case editPost(Post)
}

// MARK: - Navigation Coordinator
@MainActor
class NavigationCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    
    // Модальные окна (не входят в path)
    @Published var showAddPost = false
    @Published var showEditPost: Post?
    @Published var showPreferences = false
    @Published var showNotices = false
    
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
    
    func presentAddPost() {
        showAddPost = true
    }
    
    func presentEditPost(_ post: Post) {
        showEditPost = post
    }
    
    func presentPreferences() {
        showPreferences = true
    }
    
    func presentNotices() {
        showNotices = true
    }
    
    func dismissModals() {
        showAddPost = false
        showEditPost = nil
        showPreferences = false
        showNotices = false
    }
}
