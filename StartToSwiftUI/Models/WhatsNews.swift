//
//  News.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 14.11.2025.
//

import SwiftUI

struct WhatsNews {
    static let releases: [Release] = [
        Release(
            release: "Release 1.3.0(4)",
            news: [
                News(
                    title: "Added",
                    newsText: """
                    - Materials can now be hidden and then moved to Deleted before permanent erase
                    - Hidden and deleted materials can be restored to Active in the new 'Archived Materials' view
                    - Notes in curated materials are now available for editing
                    - The "Random" sorting option in the filter to display materials in shuffled order
                    """
                ),
                News(
                    title: "Improved",
                    newsText: """
                    - Curated content migrated from GitHub JSON to Firestore Cloud for faster updates
                    - Search bar now supports keyboard language switching
                    """
                ),
                News(
                    title: "Fixed",
                    newsText: """
                    - A potential crash caused by distantPast date handling in Firestore
                    """
                ),
            ]
        ),
        Release(
            release: "Release 1.2.0(3)",
            news: [
                News(
                    title: "Added",
                    newsText: """
                    - The "Original" sorting option in the filter to display materials in the default order
                    """
                ),
                News(
                    title: "Improved",
                    newsText: """
                    - Overall performance at app launch related to Cloud sync
                    """
                ),
            ]
        ),
        Release(
            release: "Release 1.1.1(2)",
            news: [
                News(
                    title: "Added",
                    newsText: """
                    - Sorting study materials filter
                    """
                ),
                News(
                    title: "Improved",
                    newsText: """
                    - Cloud data synchronisation across devices
                    """
                ),
            ]
        ),
        Release(
            release: "Release 1.1.0(1)",
            news: [
                News(
                    title: "Initial deployment",
                    newsText: ""
                ),
            ]
        )
    ]
}

struct News: Identifiable {
    
    let id: String
    let title: String
    let newsText: String
    
    init(
        id: String = UUID().uuidString,
        title: String,
        newsText: String = ""
    ) {
        self.id = id
        self.title = title
        self.newsText = newsText
    }
}

struct Release: Identifiable {
    
    let id: String
    let release: String
    let news: [News]
    
    init(
        id: String = UUID().uuidString,
        release: String,
        news: [News]
    ) {
        self.id = id
        self.release = release
        self.news = news
    }
}
