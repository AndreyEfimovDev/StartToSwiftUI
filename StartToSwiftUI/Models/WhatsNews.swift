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
            release: "Release 1.3.1(4)",
            news: [
                News(
                    title: "Added",
                    newsText: """
                    - Study content can be managed by first moving it to the 'hidden' pool, then to the 'deleted' pool, before it is permanently erased
                    - The "Random" sorting option in the filter to display materials in shuffled order
                    - The "Make all curated collection available" option to drop the latest date of loading curated collection
                    """
                ),
                News(
                    title: "Fixed",
                    newsText: """
                    - Remote curated content migrated to Firestore Cloud
                    - Various UI/UX enhancements
                    """
                ),
            ]
        ),
        Release(
            release: "Release 1.2.1(3)",
            news: [
                News(
                    title: "Added",
                    newsText: """
                    - The "Original" sorting option in the filter to display materials in the default order
                    """
                ),
                News(
                    title: "Fixed",
                    newsText: """
                    - Improved overall performance at app launch related to Cloud sync
                    - Various UI/UX enhancements
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
