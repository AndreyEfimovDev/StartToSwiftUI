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
            release: "Release 1.6.0(9)",
            news: [
                News(
                    title: "Added",
                    newsText: """
                    - New materials now shimmer — freshly imported content is highlighted with a subtle wave so you never miss new study material
                    - Shimmer wave can be toggled in Preferences
                    """
                ),
                News(
                    title: "New Code Snippets:",
                    newsText: """
                    - A007 Shimmer Wave — highlights a row with a subtle wave to draw attention to it
                    - A008 Expandable Section — a section is expandable from a fixed height to its full content height
                    - A009 OnToButton - it lets users jump back to the top of a long list with a single tap
                    - A010 Mask - a beautiful sample of Rating using .mask
                    """
                ),
                News(
                    title: "Improved",
                    newsText: """
                    - Switching between Materials and Code Snippets now slides smoothly with a directional animation
                    - Behaviour of 'Go to the Source' button when a url link is invalid 
                    """
                ),
                News(
                    title: "Fixed",
                    newsText: """
                    - An issue where the app icon badge was not cleared after opening the app, the badge now resets automatically on launch and when returning from background
                    - Auto-reset notification badge on app launch and foreground return
                    - First slide-in was from the bottom instead of the right in SliderTransition
                    """
                )
            ]
        ),

        Release(
            release: "Release 1.5.0(8)",
            news: [
                News(
                    title: "Added",
                    newsText: """
                    - Code Snippets — a new section with live UI demos showcasing modern SwiftUI interface techniques
                    - Switch between Materials and Code Snippets sections using the right top button in the shared toolbar
                    - Each snippet includes an interactive demo, description, and copyable source code
                    - Syntax highlighted code viewer with dark theme powered by Splash
                    - Snippets can be marked as favourites and persist between sessions and synced across devices
                    - Confirmation dialog before erasing a notice to prevent accidental deletions
                    """
                ),
                News(
                    title: "Improved",
                    newsText: """
                    - Removed the Hide action when deleting a material, now the deletion process is shorter: move materials to Deleted, then erase them permanently or restore back anytime
                    - Search bar and filter controls moved inline for a cleaner shared toolbar layout
                    - Connection errors now show a clear message instead of silently failing
                    """
                ),
                News(
                    title: "Fixed",
                    newsText: """
                    - An issue where changes made on one device were not syncing to other devices via iCloud
                    """
                )
            ]
        ),
        Release(
            release: "Release 1.4.2(7)",
            news: [
                News(
                    title: "Fixed",
                    newsText: """
                    - New notices briefly appeared, then disappeared after the next sync
                    """
                )
            ]
        ),
        Release(
            release: "Release 1.4.1(6)",
            news: [
                News(
                    title: "Fixed",
                    newsText: """
                    - Duplicate detection during cloud import now correctly checks both ID and title, previously a material with a duplicate title could slip through if its ID was new
                    """
                ),
            ]
        ),
        Release(
            release: "Release 1.4.0(5)",
            news: [
                News(
                    title: "Added",
                    newsText: """
                    - Push notifications — get notified about new events even when the app is closed
                    - Check for App Update button in About App section to quickly verify if a newer version is available
                    """
                ),
                News(
                    title: "Improved",
                    newsText: """
                    - URL format validation for source links
                    """
                ),
            ]
        ),
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
