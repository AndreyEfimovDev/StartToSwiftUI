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
            release: "Release 1.0.1 (2)",
            news: [
                News(
                    title: "Initial deployment",
                    newsText: """
                            StartToSwiftUI app features:
                            - Personal Library: Create and manage your own collection of links to learning materials.
                            - Curated Collection: Jumpstart your learning with a curated collection of SwiftUI tutorials and articles compiled from open sources. You will be notified when a new version of the collection is available for download. The developer strives to keep this collection up to date, though this cannot be guaranteed at all times.
                            - Smart Organisation: Organise learning resources by category such as level of study, year of materials, type of source/media, etc, create a collection of favourite materials.
                            - Full Control: Edit and delete your materials as needed, save drafts for further processing.
                            - Efficient Search & Filter: Quickly find what you need using search and filtering tools.
                            - Data Management: Backup, restore, share, or delete materials as needed.
                            """
                ),
            ]
        )
    ]
}
