//
//  FileManagerService.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.09.2025.
//

import Foundation
import SwiftUI

class JSONFileManager: ObservableObject {
    
    static let shared = JSONFileManager()
    
    private init() {}

    // MARK: FILE MANAGER FUNCIONS
    
    // Getting a full path of the JSON file

    func getFileURL(fileName: String) -> Result<URL, FileStorageError> {
        
        guard
            let documentsDirectory = FileManager
                .default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first else {
            log("🍎❌ FM(getFileURL): Error in getting path for \(fileName).", level: .error)
            return .failure(.invalidURL)
        }

        let fileURL = documentsDirectory.appendingPathComponent(fileName)
                log("🍎 FM(getFileURL): Successfully in getting path: \(fileURL).", level: .info)
                return .success(fileURL)
        }
    
    // Saving posts with encoding into JSON data

    func saveData<T: Codable>(
        _ data: T,
        fileName: String,
        encoder: JSONEncoder = .appEncoder, // we use the date encoding strategy - ISO8601 (string)
        completion: @escaping (Result<Void, FileStorageError>) -> Void
    ) {
        log("🍎 FM(saveData): Getting URL", level: .info)

        let urlResult = getFileURL(fileName: fileName)
        
        switch urlResult {
        case .success(let url):
            do {
                let jsonData = try encoder.encode(data)
                try jsonData.write(to: url)
                log("🍎 FM(saveData): Data successfully saved in: \(url)", level: .info)
                completion(.success(()))
            } catch {
                log("🍎❌ FM(saveData): Error in saving data: \(error)", level: .error)
                completion(.failure(.encodingFailed(error)))
            }
            
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    // Loading and decoding JSON data into posts
    func loadData<T: Codable>(
        fileName: String,
        decoder: JSONDecoder = .appDecoder, // we use the date decoding strategy - ISO8601 (string)
        completion: @escaping (Result<T, FileStorageError>) -> Void
    ) {
        log("🍎 FM(loadData): Getting URL", level: .info)

        let urlResult = getFileURL(fileName: fileName)
        
        switch urlResult {
        case .success(let url):
            // Check the file for existance
            guard FileManager.default.fileExists(atPath: url.path) else {
                log("🍎☑️ FM(loadData): No JSON file found", level: .info)
                completion(.failure(.fileNotFound))
                return
            }
            
            do {
                let jsonData = try Data(contentsOf: url)
                let decodedData = try decoder.decode(T.self, from: jsonData)
                log("🍎 FM(loadData): Successfully uploaded \(T.self)", level: .info)
                completion(.success(decodedData))
            } catch {
                log("🍎☑️ FM(loadData): Decoding error: \(error)", level: .error)
                completion(.failure(.decodingFailed(error)))
            }
            
        case .failure(let error):
            completion(.failure(error))
        }
        
    }
    
    func checkIfFileExists(fileName: String) -> Bool {
        log("🍎 FM(checkIfFileExists): Getting URL", level: .info)

            guard case .success(let url) = getFileURL(fileName: fileName) else {
                return false
            }
            return FileManager.default.fileExists(atPath: url.path)
        }

}


