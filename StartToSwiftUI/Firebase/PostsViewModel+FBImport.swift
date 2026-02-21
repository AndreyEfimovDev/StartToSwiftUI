//
//  PostsViewModel+FBCloudImport.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 21.02.2026.
//

import Foundation

// MARK: - Firebase Import & Update Check
extension PostsViewModel {
    
    /// Firebase import of study materials
    func importPostsFromFirebase() async -> Bool {
        
        clearError()
        let sourceName = isSwiftData ? "SwiftData" : "(Mock)"
        
        let fbResponse: [FBPostModel] = await fbPostsManager.getAllPosts(after: lastDatePostsLoaded)
        log("🔥 lastDatePostsLoaded \(String(describing: lastDatePostsLoaded))", level: .info)
        log("☁️ Imported \(fbResponse.count) posts from \(sourceName))", level: .info)
        
        let fbResponseChecked = filterUniquePosts(from: fbResponse)
        
        guard !fbResponseChecked.isEmpty else {
            hapticManager.impact(style: .light)
            log("ℹ️ No new posts from \(sourceName)", level: .info)
            return true
        }
        
        // Adding new posts
        for firebasePost in fbResponseChecked {
            dataSource.insert(PostMigrationHelper.convertFromFirebase(firebasePost))
        }
        saveContextAndReload()
        
        // Update last date of posts loaded from Firebase
        if let appStateManager,
           let latestDate = fbResponseChecked.max(by: { $0.date < $1.date })?.date {
            appStateManager.setLastDateOfPostsLoaded(latestDate.addingTimeInterval(1))
            appStateManager.setCuratedPostsLoadStatusOff()
            log("🔥 LastNoticeDate updated in appStateManager \(latestDate)", level: .info)
            
        }
        
        hapticManager.notification(type: .success)
        log("✅ Added \(fbResponseChecked.count) new posts from \(sourceName)", level: .info)
        return true
    }

    /// Check for updates to available posts in the cloud
    func checkFBPostsForUpdates() async -> Bool {
        clearError()
        guard let appStateManager else { return false }
        
        let lastLoadedDate = appStateManager.getLastDateOfPostsLoaded()
        let newPosts = await fbPostsManager.getAllPosts(after: lastLoadedDate)

        let hasUpdates = !newPosts.isEmpty
        log("🔥 checkFBPostsForUpdates: \(hasUpdates ? "Updates available" : "No updates")", level: .info)
        return hasUpdates
    }
    
    func migratePostsFromGitHubToFirebase() async {
        await fbPostsManager.migratePostsFromGitHubToFirebase()
    }
}
