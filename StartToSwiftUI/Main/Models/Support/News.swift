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


struct WhatsNews {
    static let releases: [Release] = [
//        Release(
//            release: "Release 1.1.0 (5)",
//            news: [
//                News(
//                    title: "Added",
//                    newsText: """
//                            A sorting materials feature has been implemented with the following options:
//                            - Unordered (in order as materails added)
//                            - Newest
//                            - Oldest
//                            - Random
//                            
//                            The feature can be find in the Filters.
//                            """
//                ),
//            ]
//        ),
        Release(
            release: "Release 1.0.1 (4)",
            news: [
                News(
                    title: "Initial deployment",
                    newsText: ""
                ),
            ]
        )
    ]
}
