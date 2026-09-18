//
//  CodeSnippet.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 07.03.2026.
//

import Foundation

struct CodeSnippet: Identifiable, Hashable {
    /// Не должен содержать запятую — избранные сниппеты (см.
    /// AppSyncState.snippetFavoriteIDs) сериализуются через запятую как
    /// одна строка для CloudKit-синка; ID с запятой расколется на несколько
    /// значений при следующем чтении.
    let id: String
    let category: String
    let title: String
    let intro: String
    let thanks: String?
    let date: Date
    let codeSnippet: String
    let minOS: MinOS
    
    init(
        id: String,
        category: String = Constants.mainCategory,
        title: String,
        intro: String,
        thanks: String?,
        date: Date,
        codeSnippet: String ,
        minOS: MinOS = .ios18
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.intro = intro
        self.thanks = thanks
        self.date = date
        self.codeSnippet = codeSnippet
        self.minOS = minOS
    }
    
    enum MinOS: String {
        case ios18 = "iOS 18+"
        case ios26 = "iOS 26+"

        var isAvailable: Bool {
            if #available(iOS 26, *) { return true }
            return self == .ios18
        }
    }
    
}










