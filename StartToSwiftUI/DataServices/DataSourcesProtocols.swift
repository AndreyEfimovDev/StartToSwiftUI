//
//  DataSources.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 21.01.2026.
//

import Foundation

// MARK: - Data Source Protocols
@MainActor
protocol PostsDataSourceProtocol {
    func fetchPosts() throws -> [Post]
    func insert(_ post: Post)
    func delete(_ post: Post)
    func deleteAll() throws
    func save() throws
    /// Отменяет все несохранённые изменения — после неудачного `save()`.
    func rollback()
}
@MainActor
protocol NoticesDataSourceProtocol {
    func fetchNotices() throws -> [Notice]
    func insert(_ notice: Notice)
    func delete(_ notice: Notice)
    func save() throws
    /// Отменяет все несохранённые изменения — после неудачного `save()`.
    func rollback()
}


protocol AppSyncStateManagerProtocol {
    func getLastNoticeDate() -> Date?
    func updateLatestNoticeDate(_ date: Date)
    func resetLatestNoticeDate()
    func getAppFirstLaunchDate() -> Date?

    func getLastDateOfPostsLoaded() -> Date?
    func setLastDateOfPostsLoaded(_ date: Date)
    func resetLastDateOfPostsLoaded()
    func cleanupDuplicateAppStates()
}

/// Хранилище избранных сниппетов — только то, что нужно SnippetsViewModel.
protocol SnippetFavoritesStoreProtocol {
    func getSnippetFavoriteIDs() -> Set<String>
    func toggleSnippetFavorite(_ id: String)
}

