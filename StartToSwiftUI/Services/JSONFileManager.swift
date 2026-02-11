//
//  FileManagerService.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.09.2025.
//

import Foundation

final class JSONFileManager: ObservableObject {
    
    static let shared = JSONFileManager()
    
    private init() {}

    // MARK: Export JSON file on local device
    func exportToTemporary<T: Codable>(
        _ data: T,
        fileName: String,
        encoder: JSONEncoder = .appEncoder
    ) -> Result<URL, FileStorageError> {
        do {
            let jsonData = try encoder.encode(data)
            let tempFileURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(fileName)
            try jsonData.write(to: tempFileURL)
            log("🍎 FM(exportToTemporary): Exported to: \(tempFileURL.lastPathComponent)", level: .info)
            return .success(tempFileURL)
        } catch {
            log("🍎❌ FM(exportToTemporary): Export error: \(error)", level: .error)
            return .failure(.encodingFailed(error))
        }
    }
}

// MARK: - File Storage Errors
enum FileStorageError: LocalizedError {
    case fileNotFound
    case invalidURL
    case encodingFailed(Error)
    case decodingFailed(Error)
    case fileSystemError(Error)
    case exportError(String)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "File not found"
        case .invalidURL:
            return "Invalid file URL"
        case .encodingFailed(let error):
            return "Encoding failed: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Decoding failed: \(error.localizedDescription)"
        case .fileSystemError(let error):
            return "File system error: \(error.localizedDescription)"
        case .exportError(let message):
            return message
        }
    }
}


