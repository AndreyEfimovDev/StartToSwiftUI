//
//  SnippetFavoritesService.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 09.03.2026.
//

import Foundation


final class SnippetFavoritesService {
    
    static let shared = SnippetFavoritesService()
    
    private let key = "snippet_favorites"
    
    private var favoriteIDs: Set<String> {
        get {
            let array = UserDefaults.standard.stringArray(forKey: key) ?? []
            return Set(array)
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: key)
        }
    }
    
    func isFavorite(_ id: String) -> Bool { favoriteIDs.contains(id) }
    
    func toggle(_ id: String) {
        var ids = favoriteIDs
        if ids.contains(id) {
            ids.remove(id)
        } else {
            ids.insert(id)
        }
        favoriteIDs = ids
    }
}
