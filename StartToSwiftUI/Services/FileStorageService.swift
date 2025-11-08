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
    
//    let fileName = Constants.localFileName // "posts_app.json"

//    var fileURL: URL? {
//        guard
//            let path = FileManager
//                .default
//                .urls(for: .documentDirectory, in: .userDomainMask)
//                .first?
//                .appendingPathComponent(fileName) else {
//            print("❌ FM: Error getting path.")
//            return nil
//        }
//        return path
//    }

    // MARK: FILE MANAGER FUNCIONS
    
    // getting a full path of the JSON data file stored by File Manager
    func getFileURL(fileName: String) -> URL? {
        guard
            let path = FileManager
                .default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent(fileName) else {
            print("❌ FM(getFileURL): Error in getting path: \(fileName).")
            return nil
        }
        return path
    }
    
    // Encoding posts and saving into JSON data
    func savePosts<T: Codable>(
        _ data: T,
        fileName: String,
        encoder: JSONEncoder = .appEncoder // we use the date encoding strategy - ISO8601 (string)
    ) {
        
        guard let url = getFileURL(fileName: fileName) else {
            print("❌ FM(savePosts): Error in getting url: \(fileName)")
            return
        }
        
        do {
            let jsonData = try encoder.encode(data)
            try jsonData.write(to: url)
            print("✅ FM(savePosts): Successfully saved в \(url)")
        } catch {
            print("❌ FM(savePosts): Error in saving posts: \(error)")
        }
    }
    
    // Loading and decoding JSON data into posts
    func loadPosts<T: Codable>(
        fileName: String,
        encoder: JSONDecoder = .appDecoder // we use the date decoding strategy - ISO8601 (string)
    ) -> T? {
        
        guard let url = getFileURL(fileName: fileName) else { return nil }
        
        do {
            let jsonData = try Data(contentsOf: url)
            let decodedData = try encoder.decode(T.self, from: jsonData)
            print("✅ FM(loadPosts): Successfully uploaded")
            return decodedData
        } catch {
            print("☑️ FM(loadPosts): There are no saved posts on the device.: \(error)")
            return nil
        }
    }
}


