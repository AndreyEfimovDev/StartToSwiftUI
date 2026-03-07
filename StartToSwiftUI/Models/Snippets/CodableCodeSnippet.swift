//
//  CodableCodeSnippet.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 07.03.2026.
//

import Foundation

// MARK: - Codable version of Post for JSON
struct CodableCodeSnippet: Codable {
    var id: String
    var category: String
    var title: String
    var intro: String
    var code: String
    var codeDate: Date?
    var thanks: String?
    var githubLink: String?
    var origin: OriginOptions
    var draft: Bool
    var status: StatusOptions
    var date: Date
    var addedDateStamp: Date?
}

extension CodableCodeSnippet {
    init(from snippet: CodeSnippet) {
        self.id = snippet.id
        self.category = snippet.category
        self.title = snippet.title
        self.intro = snippet.intro
        self.code = snippet.code
        self.codeDate = snippet.codeDate
        self.thanks = snippet.thanks
        self.githubLink = snippet.githubLink
        self.origin = snippet.origin
        self.draft = snippet.draft
        self.status = snippet.status
        self.date = snippet.date
        self.addedDateStamp = snippet.addedDateStamp
    }
}

enum SnippetMigrationHelper {
    static func convertFromCodable(_ c: CodableCodeSnippet) -> CodeSnippet {
        CodeSnippet(
            id: c.id,
            category: c.category,
            title: c.title,
            intro: c.intro,
            code: c.code,
            codeDate: c.codeDate,
            thanks: c.thanks,
            githubLink: c.githubLink,
            origin: c.origin,
            draft: c.draft,
            status: c.status,
            date: c.date,
            addedDateStamp: c.addedDateStamp
        )
    }
}
