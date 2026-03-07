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
    var code: String = ""
    var codeDate: Date? = nil
    var thanks: String? = nil
    var githubLink: String? = nil
    var originRawValue: String = "local"
    var draft: Bool = false
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
    
    init(
        id: String = UUID().uuidString,
        category: String = Constants.mainCategory,
        title: String = "",
        intro: String,
        code: String = "",
        codeDate: Date? = nil,
        thanks: String? = nil,
        githubLink: String? = nil,
        origin: OriginOptions = .local,
        draft: Bool = false,
        status: StatusOptions = .active,
        date: Date = .now,
        addedDateStamp: Date? = nil
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.intro = intro
        self.code = code
        self.codeDate = codeDate
        self.thanks = thanks
        self.githubLink = githubLink
        self.origin = origin
        self.draft = draft
        self.status = status
        self.date = date
        self.addedDateStamp = addedDateStamp
    }
    
}
