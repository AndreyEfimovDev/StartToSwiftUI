//
//  FileManagerService.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.09.2025.
//

import Foundation
import SwiftUI

class FileStorageService: ObservableObject {
    
    static let shared = FileStorageService()
    
    let fileName = "posts_app.json"

    var fileURL: URL? {
        
        guard
            let path = FileManager
                .default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent(fileName) else {
            print("❌ FM: Error getting path.")
            return nil
        }
        return path
    }

    // MARK: FILE MANAGER FUNCIONS
    
    // getting a full path of the JSON data file stored by File Manager
    func getFileURL(fileName: String) -> URL? {
        
        guard
            let path = FileManager
                .default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent(fileName) else {
            print("❌ FM: rror getting path.")
            return nil
        }
        return path
    }
    
    // Encoding posts and saving into JSON data
    func savePosts(_ posts: [Post]) {
        
        guard let url = getFileURL(fileName: fileName) else { return }
        
        do {
            let jsonData = try JSONEncoder().encode(posts)
            try jsonData.write(to: url)
            print("✅ FM: Successfully saved в \(url)")
        } catch {
            print("❌ FM: Error in saving posts: \(error)")
        }
    }
    
    // Loading and decoding JSON data into posts
    func loadPosts() -> [Post] {
        
        guard let url = getFileURL(fileName: fileName) else { return [] }
        
        do {
            let data = try Data(contentsOf: url)
            let posts = try JSONDecoder().decode([Post].self, from: data)
            print("✅ FM: Successfully uploaded \(posts.count) posts")
            return posts
        } catch {
            print("☑️ FM: There are no saved posts on the device.: \(error)")
            return []
        }
    }
}


