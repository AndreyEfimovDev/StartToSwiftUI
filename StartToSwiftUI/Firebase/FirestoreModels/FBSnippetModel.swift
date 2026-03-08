//
//  FBSnippetModel.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.03.2026.
//

import Foundation
import FirebaseFirestore

// MARK: - Firestore Notice Model
struct FBSnippetModel {
    let snippetId: String
    let category: String
    let title: String
    let intro: String
    var codeSnippet: String
    var thanks: String?
    var githubUrlString: String?
    var date: Date = Date()
    
    init(
        snippetId: String,
        category: String,
        title: String,
        intro: String,
        codeSnippet: String,
        thanks: String?,
        githubUrlString: String?,
        date: Date
    ) {
        self.snippetId = snippetId
        self.category = category
        self.title = title
        self.intro = intro
        self.codeSnippet = codeSnippet
        self.thanks = thanks
        self.githubUrlString = githubUrlString
        self.date = date
    }
}

// MARK: - Firestore Snippet Mapping
extension FBSnippetModel {
    // Initialisation from the Firestore DocumentSnapshot
    init?(document: DocumentSnapshot) {
        guard
            let data = document.data(),
            let category = data["category"] as? String,
            let title = data["title"] as? String,
            let intro = data["intro"] as? String,
            let codeSnippet = data["code_snippet"] as? String,
            let thanks = data["thanks"] as? String,
            let githubUrlString = data["github_url_string"] as? String,
            let date = data["date"] as? Timestamp
        else {
            return nil
        }
        self.snippetId = document.documentID
        self.category = category
        self.title = title
        self.intro = intro
        self.codeSnippet = codeSnippet
        self.thanks = thanks
        self.githubUrlString = githubUrlString
        // Truncate to seconds — remove nanoseconds from Firestore Timestamp
        let rawDate = date.dateValue()
        self.date = Date(timeIntervalSince1970: rawDate.timeIntervalSince1970.rounded(.down))
    }
}
