//
//  PostsViewModel+BackupRestore.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 11.02.2026.
//

import Foundation

// MARK: - Backup & Restore
extension PostsViewModel {
    
    func getPostsFromBackup(url: URL, completion: @escaping (Int) -> Void) {
        
        clearError()
        
        do {
            let jsonData = try Data(contentsOf: url)
            let codablePosts = try JSONDecoder.appDecoder.decode([CodablePost].self, from: jsonData)
            let posts = codablePosts.map { PostMigrationHelper.convertFromCodable($0) }
            let uniquePosts = filterUniquePosts(posts)
            
            guard !uniquePosts.isEmpty else {
                completion(0)
                return
            }
            
            for post in uniquePosts {
                dataSource.insert(post)
            }
            saveContextAndReload()
            
            hapticManager.notification(type: .success)
            log("🍓 Restore: Restored \(uniquePosts.count) posts from \(url.lastPathComponent)", level: .info)
            completion(uniquePosts.count)
            
        } catch {
            FBCrashManager.shared.sendNonFatal(error)
            handleError(error, message: "Failed to load posts")
            completion(0)
        }
    }
    
    func exportPostsToJSON() -> Result<URL, Error> {
        log("🍓 Exporting \(allPosts.count) posts from SwiftData", level: .info)
        
        let codablePosts = allPosts.map { CodablePost(from: $0) }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm"
        let fileName = "StartToSwiftUI_backup_\(dateFormatter.string(from: Date())).json"
        
        let result = fileManager.exportToTemporary(codablePosts, fileName: fileName)
        
        switch result {
        case .success(let url):
            log("🍓✅ Exported to: \(url.lastPathComponent)", level: .info)
            return .success(url)
        case .failure(let error):
            FBCrashManager.shared.sendNonFatal(error)
            handleError(error, message: "Export failed")
            return .failure(error)
        }
    }
}
