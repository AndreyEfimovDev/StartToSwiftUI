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
        
        FBCrashManager.shared.addLog("importPostsFromFirebase: started, posts count: \(allPosts.count)")
        FBPerformanceManager.shared.startTrace(name: "import_posts_firebase")
        
        clearError()
        
        let sourceName = isSwiftData ? "SwiftData" : "(Mock)"
        
        let result = await fbPostsManager.fetchFBPosts(after: lastDatePostsLoaded)
        
        log("🔥 lastDatePostsLoaded \(String(describing: lastDatePostsLoaded))", level: .info)
        
        switch result {
        case .failure(.networkUnavailable):
            handleError(nil, message: "No internet connection. Please check your network and try again.")
            FBPerformanceManager.shared.stopTrace(name: "import_posts_firebase")
            return false
            
        case .failure(.unknown(let error)):
            handleError(error, message: "Failed to load posts from Firebase")
            FBPerformanceManager.shared.stopTrace(name: "import_posts_firebase")
            return false
            
        case .success(let fbResponse):
            let fbResponseChecked = filterUniquePosts(from: fbResponse)
            guard !fbResponseChecked.isEmpty else {
                hapticManager.impact(style: .light)
                FBPerformanceManager.shared.stopTrace(name: "import_posts_firebase")
                log("ℹ️ No new posts from \(sourceName)", level: .info)
                
                // Migration: If the date has not yet been set, we take it from local posts
                // One-time fix for users who had lastPostsFBUpdateDate = nil before saveContext() was added
                if let appStateManager {
                    let lastDate = appStateManager.getLastDateOfPostsLoaded()
                    if lastDate == nil || (lastDate ?? Date()) <= Date(timeIntervalSince1970: 1) {
                        let cloudPosts = allPosts.filter { $0.origin == .cloud || $0.origin == .cloudNew }
                        if let latestDate = cloudPosts.max(by: { $0.date < $1.date })?.date {
                            appStateManager.setLastDateOfPostsLoaded(latestDate.addingTimeInterval(1))
                            log("🔥 lastPostsFBUpdateDate restored from local posts: \(latestDate)", level: .info)
                        }
                    }
                }
                return true
            }
            
            FBAnalyticsManager.shared.logEvent(name: "import_posts", params: ["count": fbResponseChecked.count])
            
            // Adding new posts
            for firebasePost in fbResponseChecked {
                dataSource.insert(PostMigrationHelper.convertFromFirebase(firebasePost))
            }
            saveContextAndReload()
            
            // Update last date of posts loaded from Firebase
            if let appStateManager,
               let latestDate = fbResponseChecked.max(by: { $0.date < $1.date })?.date {
                appStateManager.setLastDateOfPostsLoaded(latestDate.addingTimeInterval(1))
                log("🔥 lastPostsFBUpdateDate updated in appStateManager \(latestDate)", level: .info)
            }
            
            hapticManager.notification(type: .success)
            
            FBCrashManager.shared.addLog("importPostsFromFirebase: finished, import count: \(fbResponseChecked.count)")
            FBCrashManager.shared.addLog("importPostsFromFirebase: finished, updated posts count: \(allPosts.count)")
            log("✅ Added \(fbResponseChecked.count) new posts from \(sourceName)", level: .info)
            FBPerformanceManager.shared.setValue(
                name: "import_posts_firebase",
                value: "\(fbResponseChecked.count)/\(fbResponse.count)",
                forAttribute: "posts_new_of_received"
            )
            FBPerformanceManager.shared.stopTrace(name: "import_posts_firebase")
            return true
        }
    }

    /// Check for updates to available posts in the cloud
    func checkFBPostsForUpdates() async -> Bool {
        clearError()
        guard let appStateManager else { return false }
        guard let lastLoadedDate = appStateManager.getLastDateOfPostsLoaded() else {
            return true // дата не установлена — считаем что обновления есть
        }

        let result = await fbPostsManager.fetchFBPosts(after: lastLoadedDate)
        
        switch result {
        case .success(let newPosts): return !newPosts.isEmpty
        case .failure: return false
        }
    }
    
#warning("Delete a body of this func before deployment to App Store")
    func uploadDevDataPostsToFirebase() async {
        await fbPostsManager.uploadDevDataPostsToFirebase()
    }
    
    // MARK: - Migration
    func migrateHiddenToDeleted() {
        let hiddenPosts = allPosts.filter { $0.status == .hidden }
        guard !hiddenPosts.isEmpty else { return }
        
        hiddenPosts.forEach { $0.status = .deleted }
        saveContextAndReload()
        
        log("🔄 Migrated \(hiddenPosts.count) posts: hidden → deleted", level: .info)
    }

}
