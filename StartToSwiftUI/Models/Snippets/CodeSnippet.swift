//
//  CodeSnippet.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 07.03.2026.
//

import Foundation
import SwiftData

@Model
final class CodeSnippet {
    var id: String = UUID().uuidString
    var category: String = Constants.mainCategory
    var title: String = ""
    var intro: String = ""
    var codeSnippet: String = ""
    var thanks: String? = nil
    var githubUrlString: String? = nil
    var notes: String = ""
    var favoriteChoiceRawValue: String = "no"
    var originRawValue: String = "local"
    var statusRawValue: String = "active"
    var date: Date = Date()
    var addedDateStamp: Date?
    
    // Computed properties for ease of working with enumerations
    var origin: OriginOptions {
        get { OriginOptions(rawValue: originRawValue) ?? .local }
        set { originRawValue = newValue.rawValue }
    }
    
    var status: StatusOptions {
        get { StatusOptions(rawValue: statusRawValue) ?? .active }
        set { statusRawValue = newValue.rawValue }
    }
    
    var favoriteChoice: FavoriteChoice {
        get { FavoriteChoice(rawValue: favoriteChoiceRawValue) ?? .no }
        set { favoriteChoiceRawValue = newValue.rawValue }
    }

    init(
        id: String = UUID().uuidString,
        category: String = Constants.mainCategory,
        title: String = "",
        intro: String,
        codeSnippet: String = "",
        thanks: String? = nil,
        githubUrlString: String? = nil,
        notes: String = "",
        favoriteChoice: FavoriteChoice = .no,
        origin: OriginOptions = .local,
        status: StatusOptions = .active,
        date: Date = .now,
        addedDateStamp: Date? = nil
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.intro = intro
        self.codeSnippet = codeSnippet
        self.thanks = thanks
        self.githubUrlString = githubUrlString
        self.notes = notes
        self.favoriteChoice = favoriteChoice
        self.origin = origin
        self.status = status
        self.date = date
        self.addedDateStamp = addedDateStamp
    }
    
}
