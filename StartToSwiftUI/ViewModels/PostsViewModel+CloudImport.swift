//
//  PostsViewModel+CloudImport.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 11.02.2026.
//

import Foundation

// MARK: - Cloud Import & Update Check
extension PostsViewModel {
    
    /// Cloud import of curated study materials
    func importPostsFromCloud() async -> Bool {
        
        clearError()
        
        let sourceName = isSwiftData ? "SwiftData" : "(Mock)"
        
        do {
            let cloudResponse: [CodablePost] = try await networkService.fetchDataFromURLAsync()
            log("☁️ Imported \(cloudResponse.count) posts from \(sourceName))", level: .info)
            
            let newPosts = filterUniquePosts(from: cloudResponse)
            
            guard !newPosts.isEmpty else {
                hapticManager.impact(style: .light)
                log("ℹ️ No new posts from \(sourceName)", level: .info)
                return true
            }
            
            for post in newPosts {
                post.addedDateStamp = .now
                dataSource.insert(post)
            }
            saveContextAndReload()
            
            if let appStateManager {
                let latestDate = getLatestDateFromPosts(posts: allPosts) ?? .now
                appStateManager.setLastDateOfCuaratedPostsLoaded(latestDate)
                appStateManager.setCuratedPostsLoadStatusOff()
            }
            
            hapticManager.notification(type: .success)
            log("✅ Added \(newPosts.count) new posts from \(sourceName)", level: .info)
            return true
            
        } catch {
            handleError(error, message: "Import error from \(sourceName)")
            return false
        }
    }
    
    /// Check for updates to available posts in the cloud
    func checkCloudCuratedPostsForUpdates() async -> Bool {
        
        clearError()
        
        do {
            let cloudResponse: [CodablePost] = try await networkService.fetchDataFromURLAsync()
            let localPosts = self.allPosts.filter { $0.origin == .cloud || $0.origin == .cloudNew }
            let cloudPosts = cloudResponse
                .filter { $0.origin == .cloudNew }
                .map { PostMigrationHelper.convertFromCodable($0) }
            
            var hasUpdates: Bool
            
            if let latestLocalDate = self.getLatestDateFromPosts(posts: localPosts),
               let latestCloudDate = self.getLatestDateFromPosts(posts: cloudPosts) {
                hasUpdates = latestLocalDate < latestCloudDate
            } else {
                hasUpdates = localPosts.isEmpty && !cloudPosts.isEmpty
            }
            log("🍓 checkCloudForUpdates: \(hasUpdates ? "Updates available" : "No updates")", level: .debug)
            return hasUpdates
            
        } catch {
            handleError(error, message: "checkCloudForUpdates error")
            return false
        }
    }
}
