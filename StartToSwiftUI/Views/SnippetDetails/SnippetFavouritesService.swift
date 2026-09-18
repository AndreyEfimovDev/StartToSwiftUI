//
//  SnippetFavoritesService.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 09.03.2026.
//

import Foundation

@MainActor
final class SnippetFavouritesService {

    private let appSyncStateManager: AppSyncStateManager

    init(appSyncStateManager: AppSyncStateManager) {
        self.appSyncStateManager = appSyncStateManager
    }

    func isFavorite(_ id: String) -> Bool {
        appSyncStateManager.isSnippetFavorite(id)
    }

    func toggle(_ id: String) {
        appSyncStateManager.toggleSnippetFavorite(id)
    }
}
