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
            release: "Release 1.2.1(3)",
            news: [
                News(
                    title: "Added",
                    newsText: """
                    - An 'Original' sorting option to the materials filter to view them in their default order
                    """
                ),
                News(
                    title: "Fixed",
                    newsText: """
                    - Improved overall performance
                    - Various UX enhancements
                    """
                ),
            ]
        ),
        Release(
            release: "Release 1.1.2(2)",
            news: [
                News(
                    title: "Added",
                    newsText: """
                    - Sorting study materials filter
                    """
                ),
                News(
                    title: "Fixed",
                    newsText: """
                    - Improved cloud data synchronisation across devices
                    """
                ),
            ]
        ),
        Release(
            release: "Release 1.1.1(1)",
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
