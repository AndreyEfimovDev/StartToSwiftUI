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


