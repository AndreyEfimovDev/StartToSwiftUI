//
//  SnippetsViewModel+BackupRestore.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.03.2026.
//

import Foundation

// MARK: - Backup & Restore
extension SnippetsViewModel {

    func getSnippetsFromBackup(url: URL, completion: @escaping (Int) -> Void) {
        clearError()

        do {
            let jsonData = try Data(contentsOf: url)
            let codableSnippets = try JSONDecoder.appDecoder.decode([CodableCodeSnippet].self, from: jsonData)
            let snippets = codableSnippets.map { SnippetMigrationHelper.convertFromCodable($0) }
            let uniqueSnippets = filterUniqueSnippets(snippets)

            guard !uniqueSnippets.isEmpty else {
                completion(0)
                return
            }

            for snippet in uniqueSnippets {
                dataSource.insert(snippet)
            }
            saveContextAndReload()

            hapticManager.notification(type: .success)
            log("🍓 Restore: Restored \(uniqueSnippets.count) snippets from \(url.lastPathComponent)", level: .info)
            completion(uniqueSnippets.count)

        } catch {
            handleError(error, message: "Failed to load snippets from backup")
            completion(0)
        }
    }

    func exportSnippetsToJSON() -> Result<URL, Error> {
        log("🍓 Exporting \(allSnippets.count) snippets from SwiftData", level: .info)

        let codableSnippets = allSnippets.map { CodableCodeSnippet(from: $0) }
        let fileName = "StartToSwiftUI_snippets_\(DateFormatter.yyyyMMddHHmm.string(from: Date())).json"

        let result = fileManager.exportToTemporary(codableSnippets, fileName: fileName)

        switch result {
        case .success(let url):
            log("🍓✅ Exported snippets to: \(url.lastPathComponent)", level: .info)
            return .success(url)
        case .failure(let error):
            handleError(error, message: "Snippets export failed")
            return .failure(error)
        }
    }
}
