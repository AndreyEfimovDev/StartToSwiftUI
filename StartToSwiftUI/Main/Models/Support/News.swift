//
//  News.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 14.11.2025.
//

import Foundation

struct News: Identifiable {
    
    let id: String
    let title: String
    let newsText: String
    
    init(
        id: String = UUID().uuidString,
        title: String,
        newsText: String
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


struct WhatsNews {
    static let releases: [Release] = [
        Release(
            release: "Release 1.0.0 (1)",
            news: [
                News(
                    title: "Initial deployment",
                    newsText: """
                            The App's features are described in the 'Introduction/About App' section.
                            """),
            ]
        )

    ]
    
}
