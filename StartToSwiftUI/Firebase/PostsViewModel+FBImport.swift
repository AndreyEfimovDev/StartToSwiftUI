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
            appStateManager.setCuratedPostsLoadStatusOff()
            log("🔥 LastNoticeDate updated in appStateManager \(latestDate)", level: .info)
            
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
        guard let appStateManager else { return false }
        
        guard let lastLoadedDate = appStateManager.getLastDateOfPostsLoaded() else {
                log("🔥 checkFBPostsForUpdates: no lastLoadedDate, skipping", level: .info)
                return false
            }

        let newPosts = await fbPostsManager.getAllPosts(after: lastLoadedDate)
        let hasUpdates = !newPosts.isEmpty
        log("🔥 checkFBPostsForUpdates: \(hasUpdates ? "Updates available" : "No updates")", level: .info)
        return hasUpdates
    }

#warning("Delete this func before deployment to App Store")
    func uploadDevDataPostsToFirebase() async {
        await fbPostsManager.uploadDevDataPostsToFirebase()
        FBAnalyticsManager.shared.logEvent(name: "dev_data_uploaded")
    }

}
