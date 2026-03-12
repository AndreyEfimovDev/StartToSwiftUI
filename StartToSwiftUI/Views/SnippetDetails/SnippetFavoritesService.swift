//
//  SnippetFavoritesService.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 09.03.2026.
//

import Foundation

final class SnippetFavoritesService {
    
    static let shared = SnippetFavoritesService()
    
    private var appSyncStateManager: AppSyncStateManager? = nil
    
    func configure(with manager: AppSyncStateManager) {
        appSyncStateManager = manager
    }
    
    @MainActor func isFavorite(_ id: String) -> Bool {
        appSyncStateManager?.isSnippetFavorite(id) ?? false
    }
    
    @MainActor func toggle(_ id: String) {
        appSyncStateManager?.toggleSnippetFavorite(id)
    }
}
