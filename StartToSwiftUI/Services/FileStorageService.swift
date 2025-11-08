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

    // MARK: FILE MANAGER FUNCIONS
    
    // Getting a full path of the JSON data file stored by File Manager
    func getFileURL(fileName: String) -> Result<URL, FileStorageError> {
        guard
            let documentsDirectory = FileManager
                .default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first else {
            print("❌ FM(getFileURL): Error in getting path: \(fileName).")
            return .failure(.invalidURL)
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        return .success(fileURL)
    }
    
    // Saving posts with encoding into JSON data

    func savePosts<T: Codable>(
        _ data: T,
        fileName: String,
        encoder: JSONEncoder = .appEncoder, // we use the date encoding strategy - ISO8601 (string)
        completion: @escaping (Result<Void, FileStorageError>) -> Void
    ) {
        
        let urlResult = getFileURL(fileName: fileName)
        
        switch urlResult {
        case .success(let url):
            do {
                let jsonData = try encoder.encode(data)
                try jsonData.write(to: url)
                print("✅ FM(savePosts): Successfully saved в \(url)")
                completion(.success(()))
            } catch {
                print("❌ FM(savePosts): Error in saving posts: \(error)")
                completion(.failure(.encodingFailed(error)))
            }
            
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    // Loading and decoding JSON data into posts
    func loadPosts<T: Codable>(
        fileName: String,
        decoder: JSONDecoder = .appDecoder, // we use the date decoding strategy - ISO8601 (string)
        completion: @escaping (Result<T, FileStorageError>) -> Void
    ) {
        
        let urlResult = getFileURL(fileName: fileName)
        
        switch urlResult {
        case .success(let url):
            // Check the file for existance
            guard FileManager.default.fileExists(atPath: url.path) else {
                print("☑️ FM(loadPosts): No saved posts found")
                completion(.failure(.fileNotFound))
                return
            }
            
            
            do {
                let jsonData = try Data(contentsOf: url)
                let decodedData = try decoder.decode(T.self, from: jsonData)
                print("✅ FM(loadPosts): Successfully uploaded")
                completion(.success(decodedData))
            } catch {
                print("☑️ FM(loadPosts): Decoding error: \(error)")
                completion(.failure(.decodingFailed(error)))
            }
            
        case .failure(let error):
                    completion(.failure(error))
                }

    }
    
//    func checkIfFileExists(fileName: String) -> Bool {
//            guard case .success(let url) = getFileURL(fileName: fileName) else {
//                return false
//            }
//            return FileManager.default.fileExists(atPath: url.path)
//        }

}


