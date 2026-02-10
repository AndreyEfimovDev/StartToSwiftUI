//
//  News.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 14.11.2025.
//

import SwiftUI

struct WhatsNews {
#warning("Add upated info before deployment to App Store")
    static let releases: [Release] = [
        Release(
            release: "Release 1.1.1(2)",
            news: [
                News(
                    title: "Fixed",
                    newsText: """
                    - Improved cloud data synchronisation across devices

                    """
                ),
                News(
                    title: "Added",
                    newsText: """
                    - Sorting study materials filter
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
