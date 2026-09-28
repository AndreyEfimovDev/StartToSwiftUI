//
//  FileManagerService.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.09.2025.
//

import Foundation

final class JSONFileManager {

    init() {}

    // MARK: Export JSON file on local device
    func exportToTemporary<T: Codable>(
        _ data: T,
        fileName: String,
        encoder: JSONEncoder = .appEncoder
    ) -> Result<URL, FileStorageError> {
        // Кодирование и запись — разные ошибки: запись может упасть из-за
        // нехватки места, и об этом пользователю нужно сказать отдельно.
        let jsonData: Data
        do {
            jsonData = try encoder.encode(data)
        } catch {
            log("🍎❌ FM(exportToTemporary): Encoding error: \(error)", level: .error)
            return .failure(.encodingFailed(error))
        }

        let tempFileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName)
        do {
            try jsonData.write(to: tempFileURL)
        } catch {
            log("🍎❌ FM(exportToTemporary): Write error: \(error)", level: .error)
            return .failure(.fileSystemError(error))
        }

        log("🍎 FM(exportToTemporary): Exported to: \(tempFileURL.lastPathComponent)", level: .info)
        return .success(tempFileURL)
    }
}

// MARK: - File Storage Errors
enum FileStorageError: LocalizedError, CustomNSError {
    case encodingFailed(Error)
    case fileSystemError(Error)

    var errorDescription: String? {
        switch self {
        case .encodingFailed(let error):
            return "Encoding failed: \(error.localizedDescription)"
        case .fileSystemError(let error):
            return "File system error: \(error.localizedDescription)"
        }
    }

    /// Исходная ошибка — в `NSUnderlyingErrorKey`: без этого при переводе в
    /// `NSError` она теряется, и `ErrorManager` не распознаёт, например,
    /// нехватку места (Cocoa `NSFileWriteOutOfSpaceError`) под этой ошибкой.
    var errorUserInfo: [String: Any] {
        let underlying: Error
        switch self {
        case .encodingFailed(let error), .fileSystemError(let error):
            underlying = error
        }
        var userInfo: [String: Any] = [NSUnderlyingErrorKey: underlying]
        if let errorDescription {
            userInfo[NSLocalizedDescriptionKey] = errorDescription
        }
        return userInfo
    }
}
