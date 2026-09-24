//
//  PostsViewModel+BackupRestore.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 11.02.2026.
//

import Foundation

// MARK: - Backup & Restore
extension PostsViewModel {
    
    /// Восстанавливает посты из файла бэкапа, пропуская уже существующие.
    ///
    /// - Parameter completion: `.success(count)` — сколько постов добавлено
    ///   (0, если все уже есть); `.failure` — файл не прочитан или сохранение
    ///   не удалось (текст ошибки показан глобальным алертом).
    func getPostsFromBackup(url: URL, completion: @escaping (Result<Int, Error>) -> Void) {
        Task {
            do {
                let codablePosts = try await loadBackupPosts(from: url)
                let posts = codablePosts.map { PostMigrationHelper.convertFromCodable($0) }
                let uniquePosts = filterUniquePosts(posts)

                guard !uniquePosts.isEmpty else {
                    completion(.success(0))
                    return
                }

                for post in uniquePosts {
                    dataSource.insert(post)
                }
                // Ошибку сохранения saveContextAndReload() уже показал — здесь
                // только сообщаем экрану, что восстановление не удалось.
                guard saveContextAndReload() else {
                    completion(.failure(BackupRestoreError.saveFailed))
                    return
                }

                hapticManager.notification(type: .success)
                log("🍓 Restore: Restored \(uniquePosts.count) posts from \(url.lastPathComponent)", level: .info)
                completion(.success(uniquePosts.count))

            } catch {
                crashManager.sendNonFatal(error)
                handleError(error, message: "Failed to load posts")
                completion(.failure(error))
            }
        }
    }

    /// Ошибки восстановления, не пришедшие от системы (чтение/декод файла).
    enum BackupRestoreError: Error {
        /// Посты прочитаны, но сохранить их не удалось.
        case saveFailed
    }

    /// Чтение файла бэкапа с диска и JSON-декод — потенциально медленная
    /// операция для большого бэкапа, явно уводим с MainActor через
    /// @concurrent, чтобы не блокировать UI. Не трогает self — ничего
    /// MainActor-изолированного здесь нет.
    @concurrent
    private func loadBackupPosts(from url: URL) async throws -> [CodablePost] {
        let jsonData = try Data(contentsOf: url)
        return try await JSONDecoder.appDecoder.decode([CodablePost].self, from: jsonData)
    }
    
    func exportPostsToJSON() -> Result<URL, Error> {
        log("🍓 Exporting \(allPosts.count) posts from SwiftData", level: .info)
        
        let codablePosts = allPosts.map { CodablePost(from: $0) }

        let fileName = "StartToSwiftUI_backup_\(DateFormatter.yyyyMMddHHmm.string(from: Date())).json"
        
        let result = fileManager.exportToTemporary(codablePosts, fileName: fileName)
        
        switch result {
        case .success(let url):
            log("🍓✅ Exported to: \(url.lastPathComponent)", level: .info)
            return .success(url)
        case .failure(let error):
            crashManager.sendNonFatal(error)
            handleError(error, message: "Export failed")
            return .failure(error)
        }
    }
}
