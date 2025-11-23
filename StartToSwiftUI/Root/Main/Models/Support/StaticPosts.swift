//
//  StaticPosts.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 20.11.2025.
//

import Foundation

struct StaticPost {
    
    static let staticPosts = [
        Post(
            title: "How to schedule local Push Notifications in SwiftUI",
            intro: """
            In this video we will add local push notifications to our app! We will learn how to request permissions from the user and then schedule the notifications with 3 different triggers. The 1st will be based on time, the 2nd based on date, and the 3rd based on location. Apple has made adding these notifications extremely easy and they will give your app a very professional feel!
            """,
            author: "Swiftful Thinking/Nick Sarno", // Nick Sarno
            urlString: "https://www.youtube.com/watch?v=mG9BVAs8AIo",
            postPlatform: .youtube,
            postDate: Date.from(year: 2021, month: 4, day: 9),
            studyLevel: .middle,
            origin: .statical,
        ),
        Post(
            title: "Cleaner, Safer Code with Swift KeyPaths",
            intro: """
            Swift KeyPaths are a way to write a little cleaner and safer code. In this video I explain what a KeyPath is and breakdown the syntax as well as so you a very common example with filter and map that you will almost certainly be able to improve your code with.
            """,
            author: "Sean Allen",
            urlString: "https://www.youtube.com/watch?v=qSdCw7YxQhA",
            postPlatform: .youtube,
            postDate: Date.from(year: 2023, month: 10, day: 30),
            studyLevel: .advanced,
            origin: .statical,
        ),

        Post(
            title: "Send Push Notifications using CloudKit in SwiftUI",
            intro: """
            CloudKit makes it extremely easy to send real, live push notifications to your users! In this video we will set up a ""subscription"" which will then allow users to receive push notification in real-time! This is one of the EASIEST ways to add push notification capability to an iOS project.
            """,
            author: "Swiftful Thinking/Nick Sarno",
            urlString: "https://www.youtube.com/watch?v=vr5CBfaK14A",
            postPlatform: .youtube,
            postDate: Date.from(year: 2021, month: 11, day: 18),
            studyLevel: .advanced,
            origin: .statical,
        ),
        Post(
            title: "Styling SwiftUI Text Views",
            intro: """
            In this video we are going to explore how we can stylize text for our Text views in SwiftUI.
            
            We will start by looking at how we can create a `Text` view with the Markdown-formatted base postLanguage version of the string as the localization key.
            
            We will also see how we can utilize string interpolation to combine and stylize our strings and present them in a text view.
            
            And finally, we will take a quick look at the power of Attributed strings in SwiftUI.
            """,
            author: "Stewart Lynch",
            urlString: "https://www.youtube.com/watch?v=rbtIcKKxQ38/",
            postPlatform: .youtube,
            postDate: Date.from(year: 2021, month: 5, day: 7),
            studyLevel: .middle,
            origin: .statical,
        ),
        Post(
            title: "SwiftUI",
            intro: """
                SwiftUI helps you build great-looking apps across all Apple platforms with the power of Swift — and surprisingly little code. You can bring even better experiences to everyone, on any Apple device, using just one set of tools and APIs.
                """,
            author: "Apple Inc.",
            postType: .post,
            urlString: "https://developer.apple.com/swiftui/",
            postPlatform: .website,
            studyLevel: .beginner,
            favoriteChoice: .no,
            notes: "",
            origin: .statical,
        ),
        Post(
            title: "SwiftUI Documentation",
            intro: """
                SwiftUI documentation webpage.
                """,
            author: "Apple Inc.",
            postType: .post,
            urlString: "https://developer.apple.com/documentation/swiftui/",
            postPlatform: .website,
            studyLevel: .beginner,
            favoriteChoice: .no,
            notes: "",
            origin: .statical,
        ),
        Post(
            title: "SwiftUI Tutorials",
            intro: """
                **Introducing SwiftUI**
                
                SwiftUI is a modern way to declare user interfaces for any Apple platform. Create beautiful, dynamic apps faster than ever before.
                """,
            author: "Apple Inc.",
            postType: .post,
            urlString: "https://developer.apple.com/tutorials/swiftui/",
            postPlatform: .website,
            studyLevel: .beginner,
            favoriteChoice: .no,
            notes: "",
            origin: .statical,
        ),
        Post(
            title: "SwiftUI Sample Apps",
            intro: """
                **Exploring SwiftUI Sample Apps**
                
                Explore these SwiftUI samples using Swift Playgrounds on iPad or in Xcode to learn about defining user interfaces, responding to user interactions, and managing data flow.
                """,
            author: "Apple Inc.",
            postType: .post,
            urlString: "https://developer.apple.com/tutorials/Sample-Apps/",
            postPlatform: .website,
            studyLevel: .beginner,
            favoriteChoice: .no,
            notes: "",
            origin: .statical,
        ),
        Post(
            title: "What’s new in SwiftUI",
            intro: """
                Dive into the latest features and capabilities.
                """,
            author: "Apple Inc.",
            postType: .post,
            urlString: "https://developer.apple.com/swiftui/whats-new/",
            postPlatform: .website,
            studyLevel: .beginner,
            favoriteChoice: .no,
            notes: "",
            origin: .statical,
        ),
        Post(
            title: "Apple Developer Forums: SwiftUI",
            intro: """
                Forums for SwiftUIdeveloper.
                """,
            author: "Apple Inc.",
            postType: .post,
            urlString: "https://developer.apple.com/forums/topics/ui-frameworks-topic/ui-frameworks-topic-swiftui",
            postPlatform: .website,
            studyLevel: .beginner,
            favoriteChoice: .no,
            notes: "",
            origin: .statical,
        )
        ]
}

