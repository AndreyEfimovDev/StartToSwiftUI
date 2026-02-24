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
        
        let fbResponse: [FBPostModel] = await fbPostsManager.getAllPosts(after: lastDatePostsLoaded)
        log("🔥 lastDatePostsLoaded \(String(describing: lastDatePostsLoaded))", level: .info)
        log("☁️ Imported \(fbResponse.count) posts from \(sourceName))", level: .info)
        
        let fbResponseChecked = filterUniquePosts(from: fbResponse)
        
        guard !fbResponseChecked.isEmpty else {
            hapticManager.impact(style: .light)
            FBPerformanceManager.shared.stopTrace(name: "import_posts_firebase")
            log("ℹ️ No new posts from \(sourceName)", level: .info)
            
            // Migration: If the date has not yet been set, we take it from local posts
            // TODO: Remove this migration block after v?.? — one-time fix for users
            // who had lastPostsFBUpdateDate = nil before saveContext() was added
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

    /// Check for updates to available posts in the cloud
    func checkFBPostsForUpdates() async -> Bool {
        clearError()
        guard let appStateManager else {
            print("🔥🔥🔥🔥🔥 checkFBPostsForUpdates(): appStateManager is not valid")
            return false
        }
        guard let lastLoadedDate = appStateManager.getLastDateOfPostsLoaded() else {
            print("🔥🔥🔥🔥🔥 checkFBPostsForUpdates(): lastLoadedDate is nil")
            return true
        }
        print("🔥🔥🔥🔥🔥 checkFBPostsForUpdates(): lastLoadedDate: \(lastLoadedDate)")

        let newPosts = await fbPostsManager.getAllPosts(after: lastLoadedDate)
        print("🔥🔥🔥🔥🔥 checkFBPostsForUpdates(): newPosts count: \(newPosts.count)")

        let hasUpdates = !newPosts.isEmpty
        print("🔥🔥🔥🔥🔥 checkFBPostsForUpdates(): hasUpdates: \(hasUpdates)")

        return hasUpdates
    }

#warning("Delete this func before deployment to App Store")
    func uploadDevDataPostsToFirebase() async {
        await fbPostsManager.uploadDevDataPostsToFirebase()
        FBAnalyticsManager.shared.logEvent(name: "dev_data_uploaded")
    }

}
