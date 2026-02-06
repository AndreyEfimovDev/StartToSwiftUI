//
//  DevData.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 24.11.2025.
//

import Foundation

struct DevData {
#warning("Delete this file before deployment to App Store")
    static let postsForCloud = [
        
// 2026-02-02
        Post(
            title: "Swift Basics",
            intro: """
                    Start with the Swift programming language writing a first line of code and learn the fundamentals.
                """,
            author: "Swiftful Thinking",
            postType: .course,
            urlString: "https://www.youtube.com/playlist?list=PLwvDm4VfkdpiLvzZFJI6rVIBtdolrJBVB",
            postPlatform: .youtube,
            postDate: Date.from(year: 2023, month: 7, day: 14),
            origin: .cloudNew
        ),
        Post(
            title: "iOS Dev Beginner Course",
            intro: """
                The first 7 videos from the iOS dev beginner course.
                """,
            author: "Sean Allen",
            postType: .course,
            urlString: "https://www.youtube.com/playlist?list=PL8seg1JPkqgHtditjG_y2DuYuj9FJommY",
            postPlatform: .youtube,
            postDate: Date.from(year: 2020, month: 4, day: 20),
            origin: .cloudNew
        ),
        Post(
            title: "Swift for Complete Beginners",
            intro: """
                All the core concepts required to get started building apps with Swift and SwiftUI.
                """,
            author: "Paul Hudson",
            postType: .course,
            urlString: "https://www.youtube.com/playlist?list=PLuoeXyslFTuaYpVr3S9wG6PkIvYn_yHbg",
            postPlatform: .youtube,
            postDate: Date.from(year: 2021, month: 10, day: 14),
            origin: .cloudNew
        ),

        Post(
            title: "Mastering Xcode",
            intro: """
                Master Xcode through tutorials.
                """,
            author: "Stewart Lynch",
            postType: .course,
            urlString: "https://www.youtube.com/playlist?list=PLBn01m5Vbs4CUCcA3fqvsRtx153akAJU1",
            postPlatform: .youtube,
            postDate: Date.from(year: 2023, month: 8, day: 13),
            studyLevel: .beginner,
            origin: .cloudNew
        ),
        Post(
            title: "SwiftUI Bootcamp",
            intro: """
                Learning SwiftUI by building beautiful screens and other UI components.
                """,
            author: "Swiftful Thinking",
            postType: .course,
            urlString: "https://www.youtube.com/playlist?list=PLwvDm4VfkdphqETTBf-DdjCoAvhai1QpO",
            postPlatform: .youtube,
            postDate: Date.from(year: 2024, month: 8, day: 24),
            studyLevel: .beginner,
            origin: .cloudNew
        ),
        Post(
            title: "SwiftUI Todo List",
            intro: """
                Building a real application with MVVM app architecture.
                """,
            author: "Swiftful Thinking",
            postType: .course,
            urlString: "https://www.youtube.com/playlist?list=PLwvDm4VfkdpheGqemblOIA7v3oq0MS30i",
            postPlatform: .youtube,
            postDate: Date.from(year: 2021, month: 3, day: 20),
            studyLevel: .beginner,
            origin: .cloudNew
        ),
        Post(
            title: "Swift Keywords",
            intro: """
                The playlist explains many Swift Language keywords.
                """,
            author: "Sean Allen",
            postType: .course,
            urlString: "https://www.youtube.com/playlist?list=PL8seg1JPkqgHx8DgGsHB4Dh_H_78x8oQE",
            postPlatform: .youtube,
            postDate: Date.from(year: 2019, month: 10, day: 30),
            studyLevel: .beginner,
            origin: .cloudNew
        ),
        Post(
            title: "Swift Programming Tutorial",
            intro: """
                Swift Programming Tutorial - full course for absolute beginner ~ 10,5 hours.
                """,
            author: "Sean Allen",
            postType: .course,
            urlString: "https://www.youtube.com/watch?v=CwA1VWP0Ldw",
            postPlatform: .youtube,
            postDate: Date.from(year: 2022, month: 10, day: 8),
            studyLevel: .beginner,
            origin: .cloudNew
        ),
        Post(
            title: "SwiftUI Fundamentals",
            intro: """
                A full course for absolute beginner ~ 12 hours.
                """,
            author: "Sean Allen",
            postType: .course,
            urlString: "https://www.youtube.com/watch?v=b1oC7sLIgpI",
            postPlatform: .youtube,
            postDate: Date.from(year: 2023, month: 9, day: 6),
            studyLevel: .beginner,
            origin: .cloudNew
        ),
        Post(
            title: "Git & Source Control",
            intro: """
                A complete guide for learning how to use git. Practice using Source Control within Xcode, GitKraken, and Github. Get familiar with Git Flow.
                """,
            author: "Swiftful Thinking",
            postType: .course,
            urlString: "https://www.youtube.com/playlist?list=PLwvDm4VfkdpiALKk34l9mUS2f4mdJPvXq",
            postPlatform: .youtube,
            postDate: Date.from(year: 2024, month: 5, day: 20),
            studyLevel: .beginner,
            origin: .cloudNew
        ),
        Post(
            title: "SwiftUI Map App",
            intro: """
                Building a map app to showcase real destinations around the world. Get familiar with data management and transitions.
                """,
            author: "Swiftful Thinking",
            postType: .course,
            urlString: "https://www.youtube.com/playlist?list=PLwvDm4Vfkdpha5eVTjLM0eRlJ7-yDDwBk",
            postPlatform: .youtube,
            postDate: Date.from(year: 2021, month: 12, day: 29),
            studyLevel: .beginner,
            origin: .cloudNew
        ),
//        Post(
//            title: "SwiftData",
//            intro: """
//                A series on learning how to build an application using SwiftData as your persistence layer.
//                """,
//            author: "Stewart Lynch",
//            postType: .course,
//            urlString: "https://www.youtube.com/playlist?list=PLBn01m5Vbs4Ck-JEF2nkcFTF_2rhGBMKX",
//            postPlatform: .website,
//            postDate: nil,
//            studyLevel: .middle,
//            origin: .cloudNew
//        ),
//
//        Post(
//            title: "JSON and Codable Protocol - Swift",
//            intro: """
//                7 part series on learning how to use Xcode to manage Git version control.
//                """,
//            author: "Stewart Lynch",
//            postType: .course,
//            urlString: "https://www.youtube.com/playlist?list=PLBn01m5Vbs4DADQtPjCfXrBHuPHLO80oU",
//            postPlatform: .youtube,
//            postDate: nil,
//            studyLevel: .middle,
//            origin: .cloudNew,
//        ),
//        Post(
//            title: "SwiftUI Continued Learning",
//            intro: """
//                Building professional apps requires knowledge of data persistence and networking. This bootcamp builds on your existing knowledge of SwiftUI.
//                """,
//            author: "Nick Sarno",
//            postType: .course,
//            urlString: "https://www.youtube.com/playlist?list=PLwvDm4VfkdpiagxAXCT33Rkwnc5IVhTar",
//            postDate: nil,
//            studyLevel: .middle,
//            origin: .cloudNew
//        ),
//        Post(
//            title: "SwiftUI Crypto App",
//            intro: """
//                Build a cryptocurrency app that downloads live price data from an API and saves the current user's portfolio. Get comfortable with Combine, Core Data, and MVVM.
//                """,
//            author: "Nick Sarno",
//            postType: .course,
//            urlString: "https://www.youtube.com/playlist?list=PLwvDm4Vfkdphbc3bgy_LpLRQ9DDfFGcFu",
//            postPlatform: .youtube,
//            postDate: nil,
//            studyLevel: .middle,
//            origin: .cloudNew
//        ),
//        Post(
//            title: "SwiftUI + Firebase",
//            intro: """
//            Become an expert at using Google Firebase. Set up user authentication, connect to a remote database, and track your app's performance in real-time.
//            
//            Learn how to integrate Firebase into your iOS app with Swift code in our comprehensive tutorial series. Our step-by-step guide will teach you everything you need to know about using Firebase in your mobile app development, perfect for developers of all levels.
//            """,
//            author: "Nick Sarno",
//            postType: .course,
//            urlString: "https://www.youtube.com/playlist?list=PLwvDm4Vfkdphl8ly0oi0aHx0v2B7UvDK0",
//            postPlatform: .youtube,
//            postDate: nil,
//            studyLevel: .middle,
//            origin: .cloudNew,
//        ),
//        Post(
//            title: "Swift Concurrency",
//            intro: """
//                Swift Concurrency is a major upgrade to the Swift language that completely changes how to write asynchronous code in Swift. Learn everything that you need to know.
//                """,
//            author: "Nick Sarno",
//            postType: .course,
//            urlString: "https://www.youtube.com/playlist?list=PLwvDm4Vfkdphr2Dl4sY4rS9PLzPdyi8PM",
//            postDate: nil,
//            studyLevel: .middle,
//            origin: .cloudNew
//        ),
//
//        Post(
//            title: "SwiftUI Advanced Learning",
//            intro: """
//                Learn how to build custom views, animations, and transitions. Get familiar with coding techniques such as Dependency Injection and Protocol-Oriented Programming. Write your first unit tests and connect to CloudKit.
//                """,
//            author: "Nick Sarno",
//            postType: .course,
//            urlString: "https://www.youtube.com/playlist?list=PLwvDm4Vfkdphc1LLLjCaEd87BEg07M97y",
//            studyLevel: .advanced,
//            origin: .cloudNew
//        ),
    ]
        
    
    
    
    // MARK: My Private Posts
    
    
    
    
    static let myPrivatePosts = [
        Post(
            title: "iOS Dev Interview Prep - Take Home Project - UIKit - Programmatic UI",
            intro: """
                This course walks through a mock take home project that is very common in the iOS dev job interview process. We start from the project brief, design, and we build the entire thing together so you can practice for the real thing.
                """,
            author: "Sean Allen",
            postType: .course,
            urlString: "https://www.youtube.com/watch?v=JzngncpZLuw",
            studyLevel: .advanced,
            origin: .cloudNew
        ),
        Post(
            title: "Swift Concurrency",
            intro: """
                6 part series on iOS Concurrency.
                """,
            author: "Stewart Lynch",
            postType: .course,
            urlString: "https://www.youtube.com/playlist?list=PLBn01m5Vbs4BKxvt7d4kyIr1ZUNlOdYTe",
            studyLevel: .advanced,
            origin: .cloudNew
        ),

        Post(
            title: "Realm",
            intro: """
                A Series of videos demonstrating how to incorporate Realm into as SwiftUI Project.
                """,
            author: "Stewart Lynch",
            postType: .course,
            urlString: "https://www.youtube.com/playlist?list=PLBn01m5Vbs4B8xgS_iEEuJtM_3BuZ7fiV",
            studyLevel: .advanced,
            origin: .cloudNew
        ),


        
        
// 2025-10-30
        Post(
            title: "Property Wrappers",
            intro: "В этом видео я расскажу вам обо всех оболочках, которые нам предлагает SwiftUI для хранения временных данных. Так же вы поймете, в чем отличие между такими оболочки как @State, @StateObject, @ObservedObject, @EnvironmentObject. Эти оболочки очень похожи друг на друга и знание того, когда и какую лучше использовать, имеет решающее значение.",
            author: "Evgenia Bruyko",
            urlString: "https://youtu.be/ExwwrvOT8mI?si=SU__YwU8UlR461Zb",
            postPlatform: .youtube,
            postDate: Date.from(year: 2021, month: 3, day: 26),
            origin: .cloudNew
        ),
        Post(
            title: "Combine – швейцарский нож iOS-разработчика. Или нет?",
            intro: """
                Привет! Меня зовут Антон, я iOS-разработчик в Банки.ру. Когда я только начинал изучать Combine, он казался для меня магией. Пара команд и вот у тебя уже есть какие-то данные. Чтобы Combine перестал оставаться черным ящиком давайте заглянем внутрь. Эта статья – мое виденье этого фреймворка.
                """,
            author: "Anton @Toshhhh",
            postType: .post,
            urlString: "https://habr.com/ru/companies/banki/articles/958650/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 10, day: 22),
            studyLevel: .middle,
            origin: .cloudNew
        ),
        Post(
            title: "Xcode: ключевые инструменты для ручного тестирования мобильных приложений",
            intro: """
                Привет! Я – Андрей, QA-лид из компании «Совкомбанк Технологии». Хочу поделиться опытом тестировании мобильных приложений в Xcode — среде, которую многие используют только для разработки. По внутренним данным нашей компании, примерно 65% критических багов в iOS-приложениях можно выловить ещё на этапе разработки, если грамотно использовать встроенные инструменты Xcode.
                """,
            author: "Andrey @SovcomTech",
            postType: .post,
            urlString: "https://habr.com/ru/companies/sovcombank_technologies/articles/956112/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 10, day: 14),
            studyLevel: .middle,
            origin: .cloudNew
        ),
        
 // Create With Swift: www.createwithswift.com
        Post(
            title: "SwiftUI",
            intro: """
                A collection of SwiftUI materials.
            """,
            author: "Create With Swift",
            postType: .course,
            urlString: "https://www.createwithswift.com/tag/swiftui/",
            postPlatform: .website,
            studyLevel: .beginner,
            origin: .cloudNew
        ),
        Post(
            title: "Swift 6.2: Расширяем границы производительности и безопасности",
            intro: """
                Мы рады представить выпуск Swift 6.2! Это обновление призвано повысить производительность каждого разработчика, независимо от того, над каким проектом он работает. От улучшенных инструментов и библиотек до серьёзных продвижений в параллелизме и производительности — Swift 6.2 предлагает богатый набор функций для реальных задач на всех уровнях программного стека.
                
                В этой статье мы расскажем о ключевых изменениях в языке, библиотеках, инструментах и поддержке платформ, а также о том, как начать работу с новой версией.
                """,
            author: "@Chidorin",
            postType: .post,
            urlString: "https://habr.com/ru/articles/957390/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 10, day: 17),
            studyLevel: .advanced,
            origin: .cloudNew
        ),
        Post(
            title: "Combine",
            intro: """
                A collection of posts about Combine.
                """,
            author: "Create With Swift",
            postType: .course,
            urlString: "https://www.createwithswift.com/tag/combine/",
            postPlatform: .website,
            studyLevel: .middle,
            origin: .cloudNew
        ),
        Post(
            title: "@propertyWrapper: Encoding Strings to Valid URL Characters",
            intro: """
                @propertyWrapper code snippet given will wrap String values into wrapped values of url safe characters.
                
                Porperty wrappers serve as a new type to wrap properties and add additional logic if needed. It's part of Swift since version 5.1 and can be useful to validate values woth a set of rules or tranform values to match certain requirements etc.
                
                As a simple example, you might want to ensure that String is using upper case, for example to correctly describe the abbreviation of federal states in the U.S. like California (CA) or New York (NY) or you could ensure that a url provided as a String includes only valid url characters.
                """,
            author: "Moritz Philip Recke",
            postType: .post,
            urlString: "https://www.createwithswift.com/propertywrapper-reference-encoding-strings-to-valid-urls/",
            postPlatform: .website,
            postDate: Date.from(year: 2021, month: 6, day: 24),
            studyLevel: .middle,
            notes: """
                The Swift Programming Language (6.2)
                Properties
                https://docs.swift.org/swift-book/documentation/the-swift-programming-language/properties/
                """,
            origin: .cloudNew
        ),
        Post(
            title: "Combine: Combining Operators",
            intro: """
                With these short code snippets you will be able to combine operators when configuring publishers in Combine.
            
                This brief overview will demonstrate some basic features that may come in handy when working with publishers in Combine, Apple's framework to handle asynchronous events by combining event-processing operators. The Publisher protocol declares a type that transmits a sequence of values over time that subscribers can receive as input by adopting the Subscriber protocol.
            
                Using a sequence as values to publish, Combine allows typical operators available in Swift to shape the values that will be published or received. These operators can also be combined to customize results to your liking.
            """,
            author: "Moritz Philip Recke",
            postType: .post,
            urlString: "https://www.createwithswift.com/reference-combine-combining-operators/",
            postPlatform: .website,
            postDate: Date.from(year: 2021, month: 9, day: 1),
            studyLevel: .middle,
            origin: .cloudNew
        ),
        Post(
            title: "Combine: switchToLatest",
            intro: """
                With this short reference code snippet, you will be able to use the convenient switchToLatest() operator when configuring subscribers in Combine.
                
                This brief overview will demonstrate some basic features that may come in handy when working with publishers in Combine, Apple's framework to handle asynchronous events by combining event-processing operators. The Publisher protocol declares a type that transmits a sequence of values over time that subscribers can receive as input by adopting the Subscriber protocol.
                
                A common use case would be that multiple requests for asynchronous work may be issued, but only the latest request is really needed. For example, requests could be aimed at loading images from a remote source. A user might tap on a button to load the image but may decide to move on and tap on another button to load another image before the first request is even completed. In this case, subscriptions in Combine can be configured with a .switchToLatest() operator to receive a new publisher from the upstream publisher and cancel its previous subscription.
                """,
            author: "Moritz Philip Recke",
            postType: .post,
            urlString: "https://www.createwithswift.com/reference-combine-switchtolatest/",
            postPlatform: .website,
            postDate: Date.from(year: 2022, month: 1, day: 27),
            studyLevel: .middle,
            origin: .cloudNew
        ),
        Post(
            title: "Publishing DocC Documentation as a Static Website on GitHub Pages",
            intro: """
                This tutorial shows how to generate DocC documentation archives, how to process them for static hosting and deploy the on GitHub Pages.
                
                At WWDC 2021, Apple introduced DocC. It is an amazing framework to create rich API reference documentation and interactive tutorials for Swift projects, frameworks, or packages. With a custom DocC Markdown syntax - documentation markup - the compiler can create rich documentation for Swift projects and displays it right in the Xcode documentation window.
                
                Even better, you can also host the generated documentation on a website with the same look and feel as the official Apple Developer Documentation. While this was a bit complicated in the beginning, as of Xcode 13.3, exporting DocC documentation for static websites has become pretty straightforward. So let's have a look.
                """,
            author: "Moritz Philip Recke",
            postType: .post,
            urlString: "https://www.createwithswift.com/publishing-docc-documention-as-a-static-website-on-github-pages/",
            postPlatform: .website,
            postDate: Date.from(year: 2022, month: 2, day: 22),
            studyLevel: .beginner,
            origin: .cloudNew
        ),
        Post(
            title: "Using SF Symbols in SwiftUI",
            intro: """
                This reference article covers how to use SF Symbols in SwiftUI and the most common modifiers associated with them.
                """,
            author: "Tiago Gomes Pereira",
            postType: .post,
            urlString: "https://www.createwithswift.com/using-sf-symbols-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2022, month: 4, day: 5),
            studyLevel: .beginner,
            notes: """
                SF Symbols is a library of icons designed to be used with the San Francisco font, the system font for Apple platforms. You can have access to the library of over 3,000 symbols by downloading the mac app available on the official Apple Website.

                https://developer.apple.com/sf-symbols/?ref=createwithswift.com

                And for guidelines on how to use them on your applications check the Human Interface Guidelines page dedicated to them. In there you can see all the different properties you can change and even how to create your custom symbols.

                https://developer.apple.com/design/human-interface-guidelines/sf-symbols/overview/?ref=createwithswift.com
                """,
            origin: .cloudNew
        ),
        Post(
            title: "Using ViewThatFits to replace GeometryReader in SwiftUI",
            intro: """
                This article shows how to use the new ViewThatFits released at WWDC 2022 to replace GeometryReader when building views in SwiftUI.
                """,
            author: "Marco Falanga",
            postType: .post,
            urlString: "https://www.createwithswift.com/using-viewthatfits-to-replace-geometryreader-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2022, month: 6, day: 16),
            studyLevel: .beginner,
            origin: .cloudNew
        ),
        Post(
            title: "Adaptive layouts with ViewThatFits",
            intro: """
                In iOS 16 SwiftUI introduces a new API to create adaptive layouts ViewThatFits. This API allows us to provide alternative views when a certain view doesn't fit into available space.
                
                I've been experimenting with ViewThatFits to see what kind of layouts we can achieve and I would like to share my findings so far in this post.
                """,
            author: "Natalia Panferova",
            postType: .post,
            urlString: "https://nilcoalescing.com/blog/AdaptiveLayoutsWithViewThatFits/?ref=createwithswift.com",
            postPlatform: .website,
            postDate: Date.from(year: 2022, month: 7, day: 11),
            studyLevel: .beginner,
            origin: .cloudNew
        ),
        Post(
            title: "How to check if Text is truncated in SwiftUI?",
            intro: """
                When displaying text of various lengths, our design needs to be clear on whether there should be a maximum number of displayable lines, or if the full text should always be shown.
                
                Text doesn't always behave predictably: sometimes the text gets truncated for no apparent reason, despite having plenty of space at our disposal (e.g. within Forms and Lists).
                
                In this article, let's have a look at how we can deal with these scenarios, and more.
                """,
            author: "Federico Zanetello",
            postType: .post,
            urlString: "https://www.fivestars.blog/articles/trucated-text/",
            postPlatform: .website,
            postDate: Date.from(year: 2021, month: 1, day: 12),
            studyLevel: .beginner,
            origin: .cloudNew
        ),
        Post(
            title: "Prototyping SwiftUI interfaces with OpenAI's ChatGPT",
            intro: """
                Understand how to use OpenAI's ChatGPT conversational machine learning model to create working code for SwitfUI apps within a few minutes.
                
                In recent months and years, OpenAI released many artificial intelligence APIs and machine learning models that support use cases from text summarization, translation, parsing unstructured data, clasification, text composition and many more. The latest addition is a model called ChatGPT which is implemented as an conversational tool.
                """,
            author: "Moritz Philip Recke",
            postType: .post,
            urlString: "https://www.createwithswift.com/building-a-swiftui-app-to-interact-with-the-openai-chatgpt-api/",
            postPlatform: .website,
            postDate: Date.from(year: 2022, month: 12, day: 3),
            studyLevel: .advanced,
            origin: .cloudNew
        ),
        Post(
            title: "Creating a SwiftUI App to interact with the OpenAI ChatGPT API",
            intro: """
                Understand how to use the OpenAISwift Package to easily connect with the OpenAI API to create your own ChaptGPT SwiftUI app.
                
                The internet is overflowing with many examples of OpenAI's ChatGPT use cases, ranging from funny to mindblowing 🤯. We already explored its ability to create usable Swift code based on simple prompts. Today we want to help you to get started with creating your own ChatGPT-based app.
                """,
            author: "Moritz Philip Recke",
            postType: .post,
            urlString: "https://www.createwithswift.com/building-a-swiftui-app-to-interact-with-the-openai-chatgpt-api/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 2, day: 14),
            studyLevel: .advanced,
            origin: .cloudNew
        ),
        Post(
            title: "Creating a SwiftUI App to generate Text Completions with GPT-3.5 through the OpenAI API",
            intro: """
                Understand how to use the OpenAI Swift Package to connect with the OpenAI API to generate text completions within your SwiftUI app.
                
                Since the release of ChatGPT, OpenAI is as hot as ever within the field of artificial intelligence. Yet, OpenAI has many more capabiltites to offer beyond the conversational chatbot. For example, the ability to generate text completions with GPT-3.5 or even GTP-4 from natural language prompts.
                
                MacPaw recently published an open-source OpenAI Swift Package that abstracts access to the OpenAI HTTP API and allows you to create apps that interface with the OpenAI capabilities easily. The library allow you to use GTP-3.5 or GPT-4 through the different model families, Dalle-E and other OpenAI features. Register at openai.com/api and obtain an API key to get started.
                
                Follow along to learn how to generate responses with GPT-3.5, also called completions, through the OpenAI API with just a few lines of code.
                """,
            author: "Moritz Philip Recke",
            postType: .post,
            urlString: "https://www.createwithswift.com/creating-a-swiftui-app-to-generate-text-completions-with-gpt-3-5-through-the-openai-api/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 5, day: 23),
            studyLevel: .advanced,
            origin: .cloudNew
        ),
        Post(
            title: "Updating the User’s Location with Core Location and Swift Concurrency in SwiftUI",
            intro: """
                Learn how to create an asynchronous API to access Core Location on a SwiftUI app.
                
                You can create your own wrappers to manage access to iOS core services, taking advantage of the features of the Swift language to create modern and flexible APIs for your application.
                
                One of the services you can work with is Core Location, using Swift Concurrency to create a simple and elegant approach to accessing the user location. With a CheckedContinuation object, we can interface between synchronous and asynchronous code, so we can update the location of the user once the location manager can retrieve it using delegation.
                """,
            author: "Tiago Gomes Pereira",
            postType: .post,
            urlString: "https://www.createwithswift.com/updating-the-users-location-with-core-location-and-swift-concurrency-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 10, day: 10),
            studyLevel: .advanced,
            origin: .cloudNew
        ),
        Post(
            title: "Animating numeric text in SwiftUI with the Content Transition modifier",
            intro: """
                Learn how to use the content transition modifier to animate numeric text in SwiftUI.
                
                ContentTransition is a simple modifier you can use to create animated transitions upon content change in your SwiftUI applications. For example, when you have a numeric value that changes over time or upon an action triggering the change, like the time on a timer or a currency that updates live.
                """,
            author: "Tiago Gomes Pereira",
            postType: .post,
            urlString: "https://www.createwithswift.com/animating-numeric-text-in-swiftui-with-the-content-transition-modifier/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 11, day: 17),
            studyLevel: .beginner,
            origin: .cloudNew
        ),
        Post(
            title: "Accessing the app life cycle within a SwiftUI app",
            intro: """
                Learn how to have access to the application life cycle of a SwiftUI-based app.
                
                There are procedures within the execution of an application that must be executed at a specific moment of its life-cycle, for example when the app finishes launching, when it goes to the background, or right before it is closed.
                
                Within the App protocol in SwiftUI, the launch options are limited in defining the entry point of our application. In order to access different moments of the life cycle of the application we must use an object that conforms to the UIApplicationDelegate protocol, which is defined as the default entry point of a UIKit-based application.
                
                In this reference article, we will disclose how to work with the life cycle of a SwiftUI app.
                """,
            author: "Matteo Altobello, Tiago Gomes Pereira",
            postType: .post,
            urlString: "https://www.createwithswift.com/accessing-the-app-life-cycle-within-a-swiftui-app/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 11, day: 28),
            studyLevel: .middle,
            origin: .cloudNew
        ),
        Post(
            title: "Picking an Image from the Photos Library in a SwiftUI App",
            intro: """
                Learn how to use the photos picker to allow users to select a photo from their photo library.
                
                The PhotosPicker component enables users to import photos or videos from their photos library directly within a SwiftUI app. This reference will guide you through the implementation of this component.
                """,
            author: "Tiago Gomes Pereira, Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/picking-an-image-from-the-photos-library-in-a-swiftui-app/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 1, day: 16),
            studyLevel: .middle,
            origin: .cloudNew
        ),
        Post(
            title: "Create an animated transition with Matched Geometry Effect in SwiftUI",
            intro: """
                Learn how to use matched geometry effect to animate views in SwiftUI.
                
                In SwiftUI we can create smooth transitions between views from one state to another with the Matched Geometry Effect. Using unique identifiers we can blend the geometry of two views with the same identifier creating an animated transition. Transitions like this can be useful for navigation or changing the state of UI elements.
                """,
            author: "Tiago Gomes Pereira, Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/create-an-animated-transition-with-matched-geometry-effect-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 2, day: 9),
            studyLevel: .advanced,
            origin: .cloudNew
        ),
        Post(
            title: "Using Swift Charts on a SwiftUI app",
            intro: """
                Learn how to use the Swift Charts framework to present charts on a SwiftUI app.
                
                Introduced at WWDC22, Swift Charts allows you to create rich charts in your SwiftUI application. With this framework, developers can represent data in different forms of visualization with just a few lines of code.
                This tutorial will explore the Swift Charts framework to plot your data with the available chart views and how to customize them to represent data effectively.
                """,
            author: "Tiago Gomes Pereira, Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/using-swift-charts-on-a-swiftui-app/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 3, day: 1),
            studyLevel: .middle,
            origin: .cloudNew
        ),
        Post(
            title: "Sign in with Apple on a SwiftUI application",
            intro: """
                Learn how to add Sign in with Apple to a SwiftUI project using the Authentication Services framework.
                
                Sign in with Apple is an authentication service that leverages Apple ID credentials for login, eliminating the need to create and manage separate passwords. This service integrates deeply into the Apple ecosystem and offers a secure, fast, and user-friendly authentication experience. It offers a quick and private method for signing into apps and provides users with a consistent and immediate experience.
                
                In this article, we will guide you through implementing the Sign in with Apple button in a SwiftUI app.
                """,
            author: "Tiago Gomes Pereira, Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/sign-in-with-apple-on-a-swiftui-application/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 3, day: 5),
            studyLevel: .advanced,
            origin: .cloudNew
        ),
        Post(
            title: "Creating a custom view modifier in SwiftUI",
            intro: """
                Learn how to create custom view modifiers on SwiftUI.
                
                Let’s understand how to create custom View Modifiers in a SwiftUI app project.
                
                From the official Apple documentation, a modifier is what you apply to a view or another view modifier, producing a different version of the original value.
                
                In SwiftUI, modifiers are one of the building blocks of how we create our user interfaces. They allow us to modify the Views we place on the UI visually, to add behaviors to our interface components, and to insert a view into another view structure.
                """,
            author: "Tiago Gomes Pereira, Pasquale Vittoriosi",
            postType: .post,
            urlString: "https://www.createwithswift.com/creating-a-custom-view-modifier-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 3, day: 21),
            studyLevel: .middle,
            origin: .cloudNew
        ),
        Post(
            title: "Camera capture setup in a SwiftUI app",
            intro: """
                In this short tutorial you will learn how to set a camera feed capture in a SwiftUI app.
                
                There are numerous guides discussing how to obtain a camera feed on an iOS app. Let’s explore a method that works on all devices that have at least one integrated camera.
                You will learn the easiest and quickest method to obtain a live feed and use it in an app created with SwiftUI. It serves as a foundation for incorporating a camera feed into projects that need so.
                """,
            author: "Gianluca Orpello",
            postType: .post,
            urlString: "https://www.createwithswift.com/camera-capture-setup-in-a-swiftui-app/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 4, day: 4),
            studyLevel: .middle,
            notes: """
                AVFoundation
                """,
            origin: .cloudNew
        ),
        Post(
            title: "Display empty states with ContentUnavailableView in SwiftUI",
            intro: """
                Learn how to use the ContentUnavailableView to represent empty states in a SwiftUI application.
                
                If you've ever encountered an iOS app that fails to display content due to network issues or empty data sets you might have seen a "content unavailable" view.
                
                This view was introduced in iOS 17 both in SwiftUI and UIKit to indicate that the content cannot be displayed.
                
                It's typically displayed in the following scenarios:
                - When you have an empty list of elements
                - When the detail view of a NavigationSplitView has nothing selected
                - When a search doesn't return any results
                - When there is no internet connection
                
                In this article, we'll take a closer look at when to use this view and how to use it correctly in SwiftUI.
                """,
            author: "Pasquale Vittoriosi",
            postType: .post,
            urlString: "https://www.createwithswift.com/display-empty-states-with-contentunavailableview-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 4, day: 9),
            studyLevel: .beginner,
            origin: .cloudNew
        ),
        Post(
            title: "Making your lists searchable in a SwiftUI app",
            intro: """
                Learn how to make a list searchable in a SwiftUI application.
                
                When listing information on our application interfaces one of the most common actions a user expects to be able to do is to filter that list in order to find the specific data they are looking for, without having to scroll through the whole list.
                
                Enabling search on your lists in a SwiftUI application is made possible by using the searchable(text:placement:prompt:) modifier. It automatically configures the user interface to display the search field.
                
                In this short tutorial, we will implement a simple search by filtering functionality on a List view on SwiftUI using the searchable(text:placement:prompt:) modifier.
                """,
            author: "Tiago Gomes Pereira",
            postType: .post,
            urlString: "https://www.createwithswift.com/making-your-lists-searchable-in-a-swiftui-app/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 4, day: 16),
            studyLevel: .beginner,
            notes: """
                The searchable modifier has many variations and you can find them all on the official page for search in the Apple documentation:

                https://developer.apple.com/documentation/swiftui/search?ref=createwithswift.com
                """,
            origin: .cloudNew
        ),
        Post(
            title: "Using gradients in SwiftUI",
            intro: """
                Learn how to use the different types of gradients to color your SwiftUI views.
                
                In this article, we will explore the world of gradients in SwiftUI, including the different types and properties for creating customized gradient effects in our View.
                
                The different ways of creating gradients we will explore are:
                - Simple gradient
                - Custom gradient
                - Linear gradient
                - Angular gradient
                - Angular gradient
                """,
            author: "Tiago Gomes Pereira, Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/using-gradients-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 5, day: 7),
            studyLevel: .beginner,
            origin: .cloudNew
        ),
        Post(
            title: "Using materials with SwiftUI",
            intro: """
                Learn how to use materials in a SwiftUI app interface.
                
                To improve the readability of our content we can create a visual separation between background and foreground using a Material, a translucent layer that serves to blur the background while maintaining the clarity of the foreground content.
                
                In augmented reality apps for example, by using materials we ensure that symbols and labels remain legible in every frame.
                
                Materials are also fundamental when our app features an image as background, like the Weather app, where separating the content from the background is crucial to accessing the information effectively.
                """,
            author: "Tiago Gomes Pereira, Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/using-materials-with-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 5, day: 14),
            studyLevel: .beginner,
            origin: .cloudNew
        ),
        Post(
            title: "Providing feedback with the sensory feedback modifier",
            intro: """
                Learn how to easily add haptic feedback to your app using the sensory feedback modifier in SwiftUI.
                
                Feedback is one of the key design principles behind iOS. Receiving a visual, audio, or haptic response to the actions performed improves the user experience of an app and you can find them all around the operational system.
                
                From unlocking the iPhone with Face ID to using toggles, menus, and all the native components, this type of feedback enriches the user experience and guides the user in understanding what's happening and the result of certain operations.
                
                Incorporating haptic feedback into our app has never been easier using the new sensoryFeedback(trigger:_:) modifier. After the user performs an action, we can specify the type of feedback to be delivered to the user.
                """,
            author: "Tiago Gomes Pereira, Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/providing-feedback-sensory-feedback-modifier/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 5, day: 21),
            studyLevel: .middle,
            origin: .cloudNew
        ),
        Post(
            title: "Using App Intents in a SwiftUI app",
            intro: """
                Learn how to add App Intents to your SwiftUI app enabling users to reach its main functionalities from anywhere on the phone.
                
                Released with iOS 16, the AppIntents framework enables developers to extend the core functionality of an app to system services like Siri, Spotlight, Shortcut, and the new Action Button. In this way, users can use your app features almost everywhere in the system.
                
                In this tutorial, we will guide you on how to integrate the AppIntents framework within a SwiftUI app by building a simple movie tracker. In this app, users will be able to add a new movie and mark a movie as seen, complete with a rating, by only using actions in the Shortcut app.
                
                By the end of this tutorial, you will understand how to expose your app's logic and entities to the operative system and create useful actions that are available in the system.
                """,
            author: "Tiago Gomes Pereira, Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/using-app-intents-swiftui-app/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 6, day: 4),
            studyLevel: .advanced,
            origin: .cloudNew
        ),
        Post(
            title: "Using multi-step animations in SwiftUI",
            intro: """
                Explore how to define and use a multi-step animation in your SwiftUI app.
                
                Animations can serve as visual indicators that inform users about activities within your app. They are especially useful when the user interface state changes, such as when loading new content or revealing new actions, improving the overall look of your app.
                
                We will utilize the PhaseAnimator container to define a multi-step animation for our view. This is especially beneficial when we require an animation that loops continuously and responds to events.
                """,
            author: "Tiago Gomes Pereira, Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/using-multi-step-animations-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 6, day: 25),
            studyLevel: .middle,
            origin: .cloudNew
        ),
        Post(
            title: "Formatting time in a Text view in SwiftUI",
            intro: """
                Discover how to format data about time to be displayed in a SwiftUI app.                
                Rendering the data of your application on the user’s interface used to require parsing the data as text yourself, but the Text view makes our lives easier with the Text(_:format:) initializer.
                
                New format styles were introduced in iOS 18 to support rendering information about time, including format style for:
                - Date Offsets
                - Date References
                - Stopwatches
                - Timers
                """,
            author: "Tiago Gomes Pereira",
            postType: .post,
            urlString: "https://www.createwithswift.com/formatting-time-in-a-text-view-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 6, day: 23),
            studyLevel: .beginner,
            notes: """
                TimelineView()
                .Date.FormatStyle
                SystemFormatStyle.DateOffset
                SystemFormatStyle.DateReference
                SystemFormatStyle.Stopwatch
                SystemFormatStyle.Timer
                .addingTimeInterval
            """,
            origin: .cloudNew
        ),
        Post(
            title: "Formatting data in a Text view in SwiftUI",
            intro: """
                Learn how to format different types of data within the Text view in SwiftUI.   
                
                SwiftUI’s Text view offers a wide range of options for formatting text, allowing us to display currencies, dates, measurements, and other types of data in a user-friendly manner.
                """,
            author: "Tiago Gomes Pereira, Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/formatting-data-as-text-in-a-text-view-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 6, day: 7),
            studyLevel: .beginner,
            notes: """
                Measurement()
                Measurement.FormatStyle
                .measurement
                Date.FormatStyle
                ListFormatStyle
                PersonNameComponents
                inflect
            """,
            origin: .cloudNew
        ),
        Post(
            title: "Converting between image formats",
            intro: """
                Discover how to convert between CIImage, CGImage, and UIImage and use them within an Image view.                
                
                When working with images in your app development projects, you may have to convert between different types to use the image for the intended purposes.
                
                A common use case for example can be switching between using the UIImage class, commonly used in UIKit to assign images to a UIImageView and the Image view used to present pictures in a SwiftUI app.
                """,
            author: "Moritz Philip Recke",
            postType: .post,
            urlString: "https://www.createwithswift.com/converting-between-image-formats/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 6, day: 17),
            studyLevel: .middle,
            origin: .cloudNew
        ),
        Post(
            title: "Preparing your App Icon for dark and tinted appearance",
            intro: """
                Discover the new requirements for app icons introduced with iOS 18.                
                
                During WWDC24, Apple announced major changes to how App Icons are displayed on the Home Screen. Users can now customize the App Icons to adapt to a fixed Dark Mode or apply a color tint to them.
                """,
            author: "Flora Damiano",
            postType: .post,
            urlString: "https://www.createwithswift.com/preparing-your-app-icon-for-dark-and-tinted-appearance/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 6, day: 20),
            studyLevel: .middle,
            origin: .cloudNew
        ),
        Post(
            title: "Animating SF Symbols with the symbol effect modifier",
            intro: """
                Explore the different ways you can animate SF Symbols with SwiftUI.                
                One of the latest enhancements Apple introduced for SF Symbols is the ability to play dynamic animations and visual effects using the symbolEffect(_:) modifier. For example, when connecting to Wi-Fi or mirroring a screen, these subtle animations help users understand the current status or progress of the action.
                
                In this guide, we will see the various types of animations available and show how to implement them in our SF Symbols.
                """,
            author: "Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/animating-sf-symbols-with-the-symbol-effect-modifier/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 6, day: 26),
            studyLevel: .beginner,
            notes: """
                symbolEffect(_:options:value:)
            
                Appear (AppearSymbolEffect)
                Disappear (DisappearSymbolEffect)
                Bounce (BounceSymbolEffect)
                Scale (ScaleSymbolEffect)
                Variable Color (VariableColorSymbolEffect)
                Pulse (PulseSymbolEffect)
                Replace (ReplaceSymbolEffect)
            
                Wiggle (WiggleSymbolEffect)
                Rotate (RotateSymbolEffect)
                Breath (BreatheSymbolEffect)
            
                DiscreteSymbolEffect
                IndefiniteSymbolEffect
                TransitionSymbolEffect
                ContentTransitionSymbolEffect
            """,
            origin: .cloudNew
        ),
        Post(
            title: "Translating text in your SwiftUI app with the Translation framework",
            intro: """
                Discover how to use the Translation framework to provide text translation features within a SwiftUI app.
                
                The Translation API is one of the new tools introduced during WWDC24, and it is available for developers to natively translate content inside their apps using machine learning models that run locally on the device without requiring an internet connection. Until now this option was only available in Safari and some native apps like Messages.
                
                IIn this reference, we will cover how to integrate the translation API overlay within a simple SwiftUI View.
                """,
            author: "Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/translating-text-in-your-swiftui-app-with-the-translation-framework/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 8, day: 1),
            studyLevel: .middle,
            notes: """
                translationPresentation
            """,
            origin: .cloudNew
        ),
        Post(
            title: "Using the Translation framework for language-to-language translation",
            intro: """
                Learn how to translate text to a specific language using on-device models with the Translation framework.

                The article "Translating text in your SwiftUI app with the Translation framework" covers adding a presentation overlay to enable basic translation in an application.
                
                To have a deeper translation integration in our app we can utilize the translationTask(_:action:) modifier from the Translation framework. This modifier allows us to translate our app's content using local ML models even when offline.
                """,
            author: "Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/using-the-translation-framework-for-language-to-language-translation/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 8, day: 2),
            studyLevel: .middle,
            notes: """
                TranslationSession.Configuration
                translationTask
                translate
                prepareTranslation
            """,
            origin: .cloudNew
        ),
        Post(
            title: "Text Effects using TextRenderer in SwiftUI",
            intro: """
                Explore the TextRenderer protocol and learn how to make text effects in a SwiftUI app.

                When you find yourself limited by the built-in SwiftUI Text modifiers and want to create more dynamic, animated, or custom-rendered text, you’ll be happy to know that Apple introduced a powerful new API in iOS 18 and aligned releases: TextRenderer.
                
                With TextRenderer, we can take complete control over how text is drawn, enabling effects ranging from subtle highlights to full character animations.
                """,
            author: "Letizia Granata",
            postType: .post,
            urlString: "https://www.createwithswift.com/text-effects-using-textrenderer-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 10, day: 28),
            studyLevel: .middle,
            notes: """
                The key is combining:
                - TextRenderer -> custom drawing logic;
                - Animatable -> time-based changes;
                - TextAttribute -> selective emphasis;
                - Transition -> integration into SwiftUI animations.
            
                a text gradually fading out
                pulse effect
                bounce effect
                BounceAttribute
                BounceRenderer
            """,
            origin: .cloudNew
        ),
        Post(
            title: "Using the zoom navigation transition in SwiftUI",
            intro: """
                Learn how to use the zoom navigation transition from iOS 18 in a SwiftUI app.

                The NavigationTransition protocol allows developers to customize transitions between Views using the .navigationTransition(_:) modifier. Beyond the typical left-to-right movement, a new zoom transition effect has been introduced that can be particularly useful for presenting UI items on a full screen.
                
                In this reference, we will integrate the new Zoom transition to push a View within a NavigationStack.
                """,
            author: "Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/using-the-zoom-navigation-transition-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 9, day: 26),
            studyLevel: .middle,
            notes: """
                @Namespace
                .zoom
                .matchedTransitionSource
            """,
            origin: .cloudNew
        ),
        Post(
            title: "Giving depth to your App Icons",
            intro: """
                Learn how to enhance your App Icon’s design by adding depth effects.

                Icons have always lived in our displays, serving as the first point of contact between the user and the interface. They encapsulate the greatest value of your product at a glance and act as the business card of your application across different contexts.
                """,
            author: "Flora Damiano",
            postType: .post,
            urlString: "https://www.createwithswift.com/giving-depth-to-your-app-icons/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 10, day: 3),
            studyLevel: .middle,
            notes: """
                @Namespace
                .zoom
                .matchedTransitionSource
            """,
            origin: .cloudNew
        ),
        Post(
            title: "Applying visual effects combined with scrolling in SwiftUI",
            intro: """
                Learn how to apply visual effects to your views while scrolling with SwiftUI.

                Visual effects are powerful tools used for improving the aesthetics and usability of applications. Their usage is crucial when it comes to creating engaging and visually appealing interfaces while keeping them dynamic and responsive to interactions, ensuring both clarity and accessibility.
                
                Visual effects are used on application and operational system levels in more places than we imagine. Here are some examples of how visual effects improve the user experience:
                
                - Adjusting blurs, shadows, materials, or the scaling of UI components can create a sense of depth and layering. It establishes a clear visual hierarchy by highlighting key elements on the screen, maintaining context, and enhancing readability.
                
                - The visual feedback from user interactions - rendered as adjusting brightness, contrast, hue, saturation, opacity, scaling, rotation, etc. - emphasizes user actions or changes in the app's state.
                
                - They are also employed in the creation of smooth transitions between different parts of the app, making navigation feel natural and fluid.
                
                Let's explore how to use the visualEffect(_:) modifier to implement visual effects in a SwiftUI view.
                """,
            author: "Antonella Giugliano",
            postType: .post,
            urlString: "https://www.createwithswift.com/applying-visual-effects-combined-with-scrolling-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 10, day: 10),
            studyLevel: .middle,
            notes: """
                visualEffect
                .hueRotation
            """,
            origin: .cloudNew
        ),
        Post(
            title: "Plotting math equations using Swift Charts",
            intro: """
                Discover how to plot math equations using Swift Charts in a SwiftUI app.

                The tutorial Using Swift Charts in a SwiftUI app shows how to represent data in different forms of visualization with just a few lines of code. Since this WWDC24 the Swift Charts framework also supports mathematical equation plotting introducing two new charts components, LinePlot and AreaPlot.
                """,
            author: "Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/plotting-math-equation-using-swift-charts/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 10, day: 11),
            studyLevel: .middle,
            origin: .cloudNew
        ),
        Post(
            title: "Creating view transitions in SwiftUI",
            intro: """
                Learn how to use create animated transitions in a SwiftUI using the transition and animation modifiers.

                Transitions are animated visual effects that smoothen the change between different views or layouts when UI elements change state, preventing abrupt shifts.
                
                They enhance the user experience by making interactions more fluid and polished. By providing visual feedback during interface changes the connection between different UI elements and actions is visually highlighted. Examples are:
                - when navigating between screens;
                - when adding or removing items from a list;
                - when displaying modal views.
                
                This guidance makes the app feel more cohesive, responsive, and easier to use.
                
                We will explore how to implement built-in transitions and how to create custom ones for more tailored behaviors, using the transition(_:) method and the Transition protocol.
                """,
            author: "Antonella Giugliano",
            postType: .post,
            urlString: "https://www.createwithswift.com/creating-view-transitions-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 10, day: 24),
            studyLevel: .middle,
            notes: """
                Transition
                TransitionPhase
                move, slide, push, scale
                combined
                """,
            origin: .cloudNew
        ),
        Post(
            title: "Implement blurring when multitasking in SwiftUI",
            intro: """
                Learn how to implement automatic screen blurring in SwiftUI apps to enhance user privacy when the app enters multitasking mode.

                Enhancing user privacy is critical in modern app development. This tutorial explains how to build a SwiftUI app that automatically blurs its screen when it enters multitasking or background mode, a useful privacy feature for protecting sensitive content.
                
                We'll explore how to implement this concept with a playful example involving developer "secrets," which get blurred when the app isn’t active. Following this step-by-step short tutorial, you'll learn how to apply this privacy technique in your SwiftUI apps.
                """,
            author: "Giovanni Monaco",
            postType: .post,
            urlString: "https://www.createwithswift.com/implement-blurring-when-multitasking-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 10, day: 29),
            studyLevel: .middle,
            notes: """
                blur
                """,
            origin: .cloudNew
        ),
        Post(
            title: "Prevent screenshot capture of sensitive SwiftUI views",
            intro: """
                Learn to build a SwiftUI modifier that hides sensitive content from screenshots and screen recordings, which is ideal for apps prioritizing user privacy.

                This short tutorial will guide you through implementing a privacy feature in SwiftUI to prevent sensitive content from appearing in both screenshots and screen recordings. Such a feature is valuable for apps handling private user data, like financial, healthcare, or messaging apps.
                """,
            author: "Giovanni Monaco",
            postType: .post,
            urlString: "https://www.createwithswift.com/prevent-screenshot-capture-of-sensitive-swiftui-views/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 11, day: 5),
            studyLevel: .middle,
            origin: .cloudNew
        ),
        Post(
            title: "Exploring Interactive Bottom Sheets in SwiftUI",
            intro: """
                Explore how to effectively use presentation detents to create interactive customized sheets like those in the Apple Maps, Find My and Stocks apps.

                In this article, we’ll explore how to effectively use presentationDetents and related modifiers to create interactive customized sheets like those in the mentioned apps.
                """,
            author: "Pasquale Vittoriosi",
            postType: .post,
            urlString: "https://www.createwithswift.com/exploring-interactive-bottom-sheets-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 11, day: 19),
            studyLevel: .beginner,
            origin: .cloudNew
        ),
        Post(
            title: "Implementing search suggestions in SwiftUI",
            intro: """
                Learn how to provide suggestions when searching in a SwiftUI app by building an example app with real-time filtering, search suggestions, and recent search tracking.

                SwiftUI's searchSuggestions(_:) modifier is a powerful feature that enhances the search experience in iOS applications. When combined with the tracking of recent searches, it creates an intuitive interface that helps users quickly find what they're looking for and easily return to previously viewed items.
                
                Let’s create an Apple Products catalog app that showcases SwiftUI's search capabilities. We'll implement a smart search system that not only filters products in real-time but also provides search suggestions and keeps track of recently viewed items.
                
                By the end of this tutorial, you'll learn how to:
                -Implement real-time search filtering
                -Display dynamic search suggestions
                -Track and show recent searches
                -Create a seamless navigation experience
                """,
            author: "Giovanni Monaco",
            postType: .post,
            urlString: "https://www.createwithswift.com/implementing-search-suggestions-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 11, day: 26),
            studyLevel: .middle,
            origin: .cloudNew
        ),
        Post(
            title: "Mastering Forms in SwiftUI: Creating and Styling",
            intro: """
                Learn how to create and customize the appearance of data-entry interfaces using forms in SwiftUI apps.

                Applications, in order to deliver value to their user, often rely on user-generated data to work with. A reminders app needs reminders, a calendar app needs events, a contacts app needs contact information, and apps that rely on tracking, in general, need the user to input the information in the app.
                
                User-created content comes in many shapes and forms and one of the most common use cases for user input is by presenting a form for them to fill.
                
                Forms serve as the backbone of user interaction, presenting an interface for data entry. They are everywhere, whether it’s signing up for a service, making a purchase, or providing feedback.
                
                On SwiftUI the Form container provides a standardized look and feel for data input experiences, very similar to the List container. The different types of views and controls you place inside it will be organized in a list-like fashion, with scrolling working and the ability to create sections.
                """,
            author: "Tiago Gomes Pereira",
            postType: .post,
            urlString: "https://www.createwithswift.com/mastering-forms-in-swiftui-creating-and-styling/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 12, day: 8),
            studyLevel: .beginner,
            origin: .cloudNew
        ),
        Post(
            title: "Mastering Forms in SwiftUI: Selecting Information",
            intro: """
                Learn how to use picker, date picker and color picker controls to provide a proper single data selection data-entry experience in a form in SwiftUI apps.

                When creating data-entry experiences in iOS apps, SwiftUI's Picker view offers a solution that allows users to select from a list of distinct options. This component enhances form interfaces by providing an intuitive and efficient way to make selections across various app contexts like settings screens and profile configurations.
                
                SwiftUI has three controls for single-value selection: Picker, DatePicker and ColorPicker. They present multiple visual configurations so you as a developer can choose the one that better adapts to the needs of your user experience.
                """,
            author: "Tiago Gomes Pereira",
            postType: .post,
            urlString: "https://www.createwithswift.com/mastering-forms-in-swiftui-selecting-information//",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 12, day: 11),
            studyLevel: .beginner,
            notes: """
                TextField
                """,
            origin: .cloudNew
        ),
        Post(
            title: "Mastering Forms in SwiftUI: Creating and Styling",
            intro: """
                Learn how to use text fields and secure field controls in forms in SwiftUI apps.

                An essential type of information collected by filling out forms is text. It could be a simple entry, like the username for an account, or a longer text entry, like the bio for a user profile. SwiftUI has multiple types of views to support form-based data-entry experiences.
                
                The importance of providing a good user experience for collecting text-based information cannot be overlooked, and when it is it communicates to the user a lack of care by the developer. Apple’s Human Interface Guidelines provide a set of best practices and platform considerations when using text fields in your application user interface.
                """,
            author: "Tiago Gomes Pereira",
            postType: .post,
            urlString: "https://www.createwithswift.com/mastering-forms-in-swiftui-text-fields/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 12, day: 17),
            studyLevel: .beginner,
            origin: .cloudNew
        ),
        Post(
            title: "Enhance UI/UX with the confirmation dialog component",
            intro: """
                Understand how to use confirmation dialogs within a SwiftUI app.

                The confirmationDialog sheet is a SwiftUI component that presents a temporary dialog to confirm an action or provide a set of related options. It appears from the bottom of the screen and offers buttons for users to make a choice which can include destructive actions, multiple choices, or simply canceling the operation.

                In the Apple ecosystem, it is used when you want to:
                - Present the user with a set of options or a specific context;
                - Confirm their intent before proceeding with an action that can be potentially destructive;
                - Offering a way to cancel or back out of an action.
                """,
            author: "Antonella Giugliano",
            postType: .post,
            urlString: "https://www.createwithswift.com/enhance-ui-ux-with-the-confirmation-dialog-component/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 1, day: 7),
            studyLevel: .beginner,
            notes: """
                    .confirmationDialog(
                        // 1. The title of the Sheet
                        "Title for the confirmation Dialog Sheet",
                        
                        // 2. The bool to enable the presentation of the sheet
                        isPresented: $isPresented,
                        
                        // 3. The visibility of the title
                        titleVisibility: .visible,
                        
                        // 4. Data to be presented
                        presenting: dataToPresent
                        
                    ) { data in
                        // 5. Buttons for different types of actions
                        // a. A destructive action
                        Button("Confirm", role: .destructive) {
                            // Do something
                        }
                        // b. Different Options Actions
                        Button("An action") {
                            // Do something
                        }
                        Button("Another action") {
                            // Do something
                        }
                        
                        // c. Cancel the action
                        Button("Cancel", role: .cancel) {
                            isPresented = false
                        }
                    }
            """,
            origin: .cloudNew
        ),
        Post(
            title: "Keyboard-driven actions in SwiftUI with onKeyPress",
            intro: """
                Learn how to capture and respond to the pressed keys in a hardware keyboard in a SwiftUI app.
            
                In iOS 17 and later, you can use the onKeyPress(_:action:) method to make a view respond to a physical keyboard event. It detects when a key is pressed and lets you perform actions based on it.
            
                To take advantage of this method, be sure the view is focusable.
            """,
            author: "Antonella Giugliano",
            postType: .post,
            urlString: "https://www.createwithswift.com/keyboard-driven-actions-in-swiftui-with-onkeypress/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 1, day: 9),
            studyLevel: .beginner,
            notes: """
                @FocusState
                .focusable
                .focused
                .onKeyPress
                """,
            origin: .cloudNew
        ),
        Post(
            title: "Controlling keyboard events with keys and phases",
            intro: """
                Learn how to respond to pressed keys and phases in a hardware keyboard in a SwiftUI app.

                The onKeyPress(_:action:) method is present in several variations, providing complete control over triggering actions. These variations allow the developer to specify exactly how and when actions should be executed in response to key presses.

                The behavior can be customized by specifying:
                - particular keys being pressed;
                - the phase of a key press;
                - a combination of both keys and their phases;
                - the characters produced by the pressed keys.
                """,
            author: "Antonella Giugliano",
            postType: .post,
            urlString: "https://www.createwithswift.com/controlling-keyboard-events-with-keys-and-phases/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 1, day: 10),
            studyLevel: .beginner,
            notes: """
                @FocusState
                .focusable
                .focused
                .onKeyPress
                KeyEquivalent
                KeyPress.Phases
                CharacterSet
                """,
            origin: .cloudNew
        ),
        Post(
            title: "Implementing tab bar in a SwiftUI app",
            intro: """
                Learn how to implement tab bar navigation with SwiftUI on iOS, iPadOS, macOS and visionOS.
            
                When designing our app, we must carefully choose the components to implement, understand their purpose, and determine when and how they should be used. One of the most commonly used components for app navigation is the tab bar. This enables what is often called flat navigation, allowing users to access different sections of the app by simply tapping on a specific tab.
            
                With the SwiftUI framework, implementing this type of component is as straightforward as it gets because developers can use the built-in tab bar with just a few lines of code. This not only simplifies our work but also ensures users enjoy a consistent experience across all apps installed on their devices.
            
                Of course, different devices require different kinds of experiences. We will have an overview of how tabs behave in the different operating systems and how to implement the tab bar within an app.
            """,
            author: "Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/implementing-tab-bar-in-a-swiftui-app/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 1, day: 30),
            studyLevel: .beginner,
            notes: """
                When you use custom symbol in tab bar remember to have a look at the Human Interface Guidelines to export them in the correct size.

                https://developer.apple.com/design/human-interface-guidelines/tab-bars?ref=createwithswift.com#Target-dimensions

                Additionally to automatically enable the accent color for your custom symbol set the"Render As" option as "Template Image, you can find this option in the Attribute Inspector section.
                """,
            origin: .cloudNew
        ),
        Post(
            title: "Grouping Controls with ControlGroup",
            intro: """
                Understand how to use control groups, improving the user experience of your SwiftUI apps.
            
                ControlGroup is a SwiftUI component introduced with iOS 15 that allows arranging together semantically connected controls. This container view helps to improve the app user experience by adding:
                - clarity - as visual organization enables easier understanding;
                - discoverability - as it makes related actions easier to be found and used;
                - consistency - as it provides a consistent visual pattern for related actions.
            
                All resulting in a more intuitive and user-friendly interface.
            """,
            author: "Antonella Giugliano",
            postType: .post,
            urlString: "https://www.createwithswift.com/grouping-controls-with-controlgroup/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 2, day: 6),
            studyLevel: .beginner,
        notes: """
            ImageResource
            .controlGroupStyle
            """,
            origin: .cloudNew
        ),
        Post(
            title: "Enabling Interaction with Table View in SwiftUI",
            intro: """
                Discover how to enable single-selection, multi-selection and collapsible rows on a Table view in a SwiftUI app.
            
                Representing data within an app using tables offers users a clear and effective overview at a glance. A significant enhancement is enabling users to interact with the table rows, allowing them to perform actions like copying or sharing data with other apps.
            """,
            author: "Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/enabling-interaction-with-table-view-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 2, day: 18),
            studyLevel: .middle,
            notes: """
                Table
                TableColumn
                TableRow
                .contextMenu
                DisclosureTableRow
                """,
            origin: .cloudNew
        ),
        Post(
            title: "Creating Custom SF Symbols",
            intro: """
                Learn everything you need to know to create custom SF Symbols for your applications.
            
                Introduced in 2019 with 1,000 symbols, the SF Symbols library has since grown exponentially, reaching a substantial 6,000 symbols over six years. These symbols are designed to integrate seamlessly with Apple’s San Francisco font, ensuring visual consistency across apps. This enhances user familiarity, promotes intuitive navigation, and creates a smoother experience across devices.
            
                With the extensive variety SF Symbols offers, it's rare not to find a symbol that fits your app's needs. The comprehensive collection caters to a wide range of use cases, reducing the necessity to design icons from scratch.
            
                However, there is always room for customization: if a specific symbol isn't available, for instance, icons can be exported into vector graphics editing tools, modified, or created entirely from scratch, maintaining the shared design language and accessibility features of the existing library. This flexibility ensures that app interfaces can be unique and consistent with Apple's design standards.
            
                There are many ways to create a new custom symbol and despite which of these ways is going to be used, the process always follows the same structure:
                - Create the symbol.
                    = Optionally, you can customize it to have more control over its rendering behavior.
                - Get the file ready to be used in the Xcode.
                - Use the symbols in a SwiftUI view.
            
                Let’s explore this process.
            """,
            author: "Antonella Giugliano",
            postType: .post,
            urlString: "https://www.createwithswift.com/creating-custom-sf-symbols/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 2, day: 20),
            studyLevel: .middle,
            origin: .cloudNew
        ),
        Post(
            title: "Grouping Controls with ControlGroup",
            intro: """
                Understand how to use control groups, improving the user experience of your SwiftUI apps.
            
                ControlGroup is a SwiftUI component introduced with iOS 15 that allows arranging together semantically connected controls. This container view helps to improve the app user experience by adding:
                - clarity - as visual organization enables easier understanding;
                - discoverability - as it makes related actions easier to be found and used;
                - consistency - as it provides a consistent visual pattern for related actions.
            
                All resulting in a more intuitive and user-friendly interface.
            """,
            author: "Antonella Giugliano",
            postType: .post,
            urlString: "https://www.createwithswift.com/grouping-controls-with-controlgroup/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 2, day: 6),
            studyLevel: .beginner,
            notes: """
                ImageResource
                .controlGroupStyle
                """,
            origin: .cloudNew
        ),
        Post(
            title: "Enabling Interaction with Table View in SwiftUI",
            intro: """
                Discover how to enable single-selection, multi-selection and collapsible rows on a Table view in a SwiftUI app.
            
                Representing data within an app using tables offers users a clear and effective overview at a glance. A significant enhancement is enabling users to interact with the table rows, allowing them to perform actions like copying or sharing data with other apps.
            """,
            author: "Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/enabling-interaction-with-table-view-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 2, day: 18),
            studyLevel: .middle,
            notes: """
                Table
                TableColumn
                TableRow
                .contextMenu
                DisclosureTableRow
                """,
            origin: .cloudNew
        ),
        Post(
            title: "Generating images programmatically with Image Playground",
            intro: """
                Learn how to use the ImageCreator API to create images programmatically within a SwiftUI app.
            
                The ImageCreator API is available in beta for Apple Intelligence compatible devices with at least iOS 18.4, iPadOS 18.4, MacOS 15.4 and visionOS 2.4 or higher.
            
                By using the new ImageCreator API, developers can programmatically generate images using Apple’s local models without relying on the Image Playground interface. This provides greater flexibility and integration possibilities within applications while ensuring that image generation remains efficient and secure.
            
                To generate images, we need to provide three parameters:
                -A textual prompt for the image
                -The desired style
                -The maximum number of images to be generated
            
                By understanding and optimizing these parameters, we can fully leverage the API’s capabilities to create high-quality, customized images that meet our needs. Let’s explore how to make the most of this powerful tool.
            """,
            author: "Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/generating-images-programmatically-with-image-playground/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 2, day: 26),
            studyLevel: .middle,
            origin: .cloudNew
        ),
        Post(
            title: "Generating images programmatically with Image Playground",
            intro: """
                Learn how to use the ImageCreator API to create images programmatically within a SwiftUI app.
            
                The ImageCreator API is available in beta for Apple Intelligence compatible devices with at least iOS 18.4, iPadOS 18.4, MacOS 15.4 and visionOS 2.4 or higher.
            
                By using the new ImageCreator API, developers can programmatically generate images using Apple’s local models without relying on the Image Playground interface. This provides greater flexibility and integration possibilities within applications while ensuring that image generation remains efficient and secure.
            
                To generate images, we need to provide three parameters:
                -A textual prompt for the image
                -The desired style
                -The maximum number of images to be generated
            
                By understanding and optimizing these parameters, we can fully leverage the API’s capabilities to create high-quality, customized images that meet our needs. Let’s explore how to make the most of this powerful tool.
            """,
            author: "Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/generating-images-programmatically-with-image-playground/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 2, day: 26),
            studyLevel: .middle,
            origin: .cloudNew
        ),
        Post(
            title: "Symmetrical and asymmetrical transitions in SwiftUI with the Scroll Transition modifier",
            intro: """
                Learn how to implement animated scroll transitions when the view enters and exits the visible area in a SwiftUI application.
            """,
            author: "Antonella Giugliano",
            postType: .post,
            urlString: "https://www.createwithswift.com/symmetrical-and-asymmetrical-transitions-in-swiftui-with-the-scroll-transition-modifier/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 2, day: 27),
            studyLevel: .middle,
        notes: """
            scrollTransition
            ScrollTransitionConfiguration
            ScrollTransitionPhase
            """,
            origin: .cloudNew
        ),
        Post(
            title: "Placing UI components within the Safe Area Inset",
            intro: """
                Learn how to place views and controls on the borders of a view container in a SwiftUI app.
            """,
            author: "Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/placing-ui-components-within-the-safe-area-inset/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 3, day: 13),
            studyLevel: .beginner,
            origin: .cloudNew
        ),
        Post(
            title: "Dynamically adapting to available space with ViewThatFits",
            intro: """
                Learn how to create views that adapt their size in order to fill the available space on the UI with SwiftUI.
            
                ViewThatFits is a SwiftUI component introduced from iOS 16 that allows your view to become responsive according to the available space that will contain it.
            
                By providing a series of possible views to display - ordered by preference, the component will use the @ViewBuilder to build the first one that fits the space available.
            
                This is very useful when the parent’s container size is not fixed and you want the child view to adapt based on that size.
            """,
            author: "Antonella Giugliano",
            postType: .post,
            urlString: "https://www.createwithswift.com/dynamically-adapting-to-available-space-with-viewthatfits/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 3, day: 20),
            studyLevel: .advanced,
            notes: """
                ViewThatFits
                @ViewBuilder 
            """,
            origin: .cloudNew
        ),
        Post(
            title: "Presenting an Inspector with SwiftUI",
            intro: """
                Learn how to use the inspector API to provide details in your user interface in SwiftUI.
            
                Introduced with iOS 17, iPadOS 17 and macOS 14, the inspector is a SwiftUI element that displays extra information about selected content. It can be implemented by using the inspector(isPresented:content:) modifier. It is usually used when you need to inspect, edit or customize properties of an object, actions or files in a more detailed and structured way.
            """,
            author: "Antonella Giugliano",
            postType: .post,
            urlString: "https://www.createwithswift.com/presenting-an-inspector-with-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 4, day: 1),
            studyLevel: .advanced,
            notes: """
                iPad
                NavigationStack
                NavigationSplitView
                navigationBar 
            """,
            origin: .cloudNew
        ),
        Post(
            title: "Mastering Forms in SwiftUI: Toggles",
            intro: """
                Learn how to create and customize the appearance of toggles in a form-based experience with SwiftUI.
            
                A constant presence in any form-based experience is to provide answers to yes-or-no questions. They can also be found within an app user interface, most commonly on settings or customization panels, as options to turn on or off.
            
                The toggle is the UI element that translates this use case in the user interface, and it can be visually represented as a switch (on mobile interfaces and when representing an on and off state), a toggled button, or a checkbox (on desktop interfaces or when representing a metaphor of “inclusion”)
            """,
            author: "Tiago Gomes Pereira",
            postType: .post,
            urlString: "https://www.createwithswift.com/mastering-forms-in-swiftui-toggles/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 4, day: 4),
            studyLevel: .advanced,
            notes: """
                Toggling multiple options at once
                isOn
                bundle
                toggleStyle(.switch)
                toggleStyle(.button)
                toggleStyle(.checkbox)
            """,
            origin: .cloudNew
        ),
        Post(
            title: "Create flexible interfaces in SwiftUI",
            intro: """
                Learn how to bind your view’s size to its container in a SwiftUI app.
            
                When building interfaces, we want them to look good on different devices or screen sizes. Starting from iOS 17, views have been enriched with a new modifier, containerRelativeFrame(_:alignment:_:), which makes it easier to create user interfaces that automatically adjust based on the size of its nearest container.
            """,
            author: "Antonella Giugliano",
            postType: .post,
            urlString: "https://www.createwithswift.com/create-flexible-interfaces-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 4, day: 1),
            studyLevel: .advanced,
            notes: """
                containerRelativeFrame
            """,
            origin: .cloudNew
        ),
        Post(
            title: "Integrating TimelineView in a SwiftUI app",
            intro: """
                Learn how to periodically refresh and update UI components, enabling smooth and efficient animations in your SwiftUI app.
            
                The TimelineView is a powerful container view in SwiftUI designed to build dynamic, time-based interfaces. Unlike traditional views that update only when state changes, TimelineView allows updates to occur on a defined schedule, making it ideal for smooth, continuous animations and building interactive elements that respond to the passage of time.
            """,
            author: "Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/integrating-timelineview-in-a-swiftui-app/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 4, day: 10),
            studyLevel: .middle,
            origin: .cloudNew
        ),
        Post(
            title: "Donate content to Spotlight and open it using NSUserActivity",
            intro: """
                Learn how to expose the content of your app to Spotlight.
            
                In this article, we’ll explore how to make your app content discoverable in Spotlight and navigate users directly to detailed views using a combination of CSSearchableItem and NSUserActivity.
            """,
            author: "Antonella Giugliano",
            postType: .post,
            urlString: "https://www.createwithswift.com/donate-content-to-spotlight-and-open-it-using-nsuseractivity/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 6, day: 10),
            studyLevel: .advanced,
            notes: """
                CoreSpotlight
                AppIntent
                IndexedEntity
                OpenIntent
                CSSearchableItem
                CSSearchableIndex
                indexSearchableItems
                Deep Link
                NSUserActivity
                CSSearchableItemActionType
                IndexedEntity
                CSSearchableItemAttributeSet 
            """,
            origin: .cloudNew
        ),
        Post(
            title: "Creating valid dates using the Swift language",
            intro: """
                Learn how to convert DateComponents into a valid Date using a Calendar instance.
            
                Date is the type we use to handle calendar information in Swift. It stores all the information needed to represent a specific point in time, independent of any calendar or time zone, by representing a time interval relative to an absolute reference date.
            
            In an application’s user interface, it is common to handle dates and times by picking specific calendar values to represent the date. A user will usually choose a day, a month, an hour, or a minute, for example and then your application will have to transform that value into a valid Date value.
            
            That’s where DateComponents comes in handy. It allows you to represent a date or time in terms of units, which can then be evaluated in a calendar system and time zone.
            """,
            author: "Gabriel Fernandes Thomaz, Tiago Gomes Pereira",
            postType: .post,
            urlString: "https://www.createwithswift.com/creating-valid-dates-using-the-swift-language/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 6, day: 19),
            studyLevel: .middle,
            origin: .cloudNew
        ),
        Post(
            title: "Triggering actions after a time interval with Timers",
            intro: """
                Learn how to trigger actions or emit a message after a certain period of time in the Swift language.
            
               If you need to trigger an action or send a message after a certain period of time, use the Timer class, which lets you schedule actions to run in the future, with or without repetition.
            """,
            author: "Gabriel Fernandes Thomaz, Tiago Gomes Pereira",
            postType: .post,
            urlString: "https://www.createwithswift.com/triggering-actions-after-a-time-interval-with-timers/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 6, day: 17),
            studyLevel: .middle,
            origin: .cloudNew
        ),
        Post(
            title: "Implementing advanced speech-to-text in your SwiftUI app",
            intro: """
                Learn how to integrate real-time voice transcription into your application using SpeechAnalyzer.
            
                Apple has recently introduced speech-to-text functionality across many of its apps, including Notes and Voice Memos, reflecting a broader shift toward voice as a primary input method. In line with this, Apple has released a new API called SpeechAnalyzer, which leverages a faster, more efficient model specifically fine-tuned for processing longer audio recordings and handling speech from distant speakers.
            
                By the end of this tutorial, you will understand how to access an audio buffer using the microphone and then make it available for the new SpeechAnalyzer class to process and convert into text.
            """,
            author: "Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/implementing-advanced-speech-to-text-in-your-swiftui-app/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 8, day: 5),
            studyLevel: .advanced,
            notes: """
                Speech
                AVFoundation
                AVAudioApplication
                AVAudioPCMBuffer
                .measurement
                .duckOthers
                stopAudioStream()
                SFSpeechRecognizer
               SpeechTranscriber
            """,
            origin: .cloudNew
        ),
        Post(
            title: "Making the tab bar collapse while scrolling",
            intro: """
                Learn how to make tab bar minimize when responding to scrolling gesture using the new minimize behavior modifier.
            
                With iOS 26 and the Liquid Glass design system, Apple introduced a new way the tab bar can respond to scrolling. Compliant to its Liquid Glass core principle, content first, TabView can now collapse as you scroll, letting the tab bar step out of the way so your content can take center stage.
            
                The modifier that enables this behavior is tabBarMinimizeBehavior(_:).
            """,
            author: "Antonella Giugliano",
            postType: .post,
            urlString: "https://www.createwithswift.com/making-the-tab-bar-collapse-while-scrolling/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 8, day: 28),
            studyLevel: .middle,
            origin: .cloudNew
        ),
        Post(
            title: "Exploring Concentricity in SwiftUI",
            intro: """
                Learn about the concept of concentricity applied to UI elements in a SwiftUI app.
                
                Concentricity is one of the key design principles Apple highlighted at the last WWDC. It’s a concept already present in many parts of their operating systems. A clear example is the Dynamic Island, where its corner radius perfectly mirrors the rounded corners of the device’s bezel.
                """,
            author: "Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/exploring-concentricity-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 9, day: 5),
            studyLevel: .beginner,
            origin: .cloudNew
        ),
        Post(
            title: "Displaying web content in SwiftUI",
            intro: """
                At WWDC 2025, Apple unveiled a new SwiftUI native view for displaying web content directly in SwiftUI, without the need to bridge with UIKit, the WebView, available for iOS 26, macOS 26, and more.
                
                Part of the WebKit framework, SwiftUI's view WebView offers two distinct approaches depending on your needs:
                - Simple URL-based loading
                - Advanced control with WebPage
                """,
            author: "Alfonso Tarallo",
            postType: .post,
            urlString: "https://www.createwithswift.com/displaying-web-content-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 9, day: 11),
            studyLevel: .beginner,
            origin: .cloudNew
        ),
        Post(
            title: "Creating custom layouts with SwiftUI",
            intro: """
                Understand how to create custom layouts with the Layout protocol in SwiftUI.
            
                When you find yourself struggling with GeometryReader to position views exactly where you want them, or when HStack and VStack just can't create the layout you're envisioning because you have complex positioning requirements that built-in layouts can't handle... maybe you need custom layouts.
            
                Built-in layouts work great for common patterns, but they have limitations. For example, VStack and HStack only allow linear arrangements, LazyVGrid allows fixed column structures, ZStack is only about simple layering without intelligent positioning and GeometryReader can give performance issues and requires complex calculations.
            
                Custom layouts in SwiftUI are types that define the geometry of a collection of views. Instead of relying on the predefined behavior of built-in layouts, you can create your own layout logic that positions views exactly where you want them.
            """,
            author: "Letizia Granata",
            postType: .post,
            urlString: "https://www.createwithswift.com/creating-custom-layouts-with-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 9, day: 16),
            studyLevel: .middle,
            notes: """
                CNContactStore
                requestAccess
                authorizationStatus
                CNAuthorizationStatus
            """,
            origin: .cloudNew
        ),
        Post(
            title: "Presenting critical information in SwiftUI with alerts",
            intro: """
                Learn how to create and use alerts within a SwiftUI app.
            
                There are different ways to present information in a modal experience, one of which is through alerts. An alert interrupts the user with critical information they need immediately and presents different actions that can be triggered directly from the alert itself.
            
                Use alerts for important messages, such as communicating errors, requesting confirmations (especially for destructive actions), or requesting permission.
            
                SwiftUI provides several variations of the alert modifier, each designed for different use cases. By understanding these different alert presentations, you can choose the most appropriate approach for each situation in your SwiftUI applications, creating better user experiences that provide the right information at the right time.
            """,
            author: "Alfonso Tarallo",
            postType: .post,
            urlString: "https://www.createwithswift.com/presenting-critical-information-in-swiftui-with-alerts/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 9, day: 30),
            studyLevel: .beginner,
            origin: .cloudNew
        ),
        Post(
            title: "Getting started with the Contacts framework",
            intro: """
                Learn how to get access to the user contacts for your SwiftUI applications.
            
                If you need to trigger an action or send a message after a certain period of time, use the Timer class, which lets you schedule actions to run in the future, with or without repetition.
            """,
            author: "Gabriel Fernandes Thomaz, Tiago Gomes Pereira",
            postType: .post,
            urlString: "https://www.createwithswift.com/getting-started-with-the-contacts-framework/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 10, day: 18),
            studyLevel: .middle,
            notes: """
                CNContactStore
                requestAccess
                authorizationStatus
                CNAuthorizationStatus
            """,
            origin: .cloudNew
        ),
        Post(
            title: "Listing contacts with the Contacts framework",
            intro: """
                Learn how to fetch contact information with the Contacts framework.
            
                The Contacts framework provides you with he tools necessary for listing, reading, and displaying contact information from the user’s virtual address book.
            """,
            author: "Gabriel Fernandes Thomaz, Tiago Gomes Pereira",
            postType: .post,
            urlString: "https://www.createwithswift.com/listing-contacts-with-the-contacts-framework/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 10, day: 19),
            studyLevel: .middle,
            notes: """
                CNContactStore
                requestAccess
                authorizationStatus
                CNAuthorizationStatus
            """,
            origin: .cloudNew
        ),
        Post(
            title: "Implementing draw animations for SF Symbols in SwiftUI",
            intro: """
                Learn how to apply the new draw animations of SF Symbols 7 in a SwiftUI app.
            
                When adding visuals to your SwiftUI app, SF Symbols have always been a reliable choice to maintain consistency with Apple's Human Interface Guidelines in iconography. With SF Symbols 7 and iOS 26, Apple introduces draw animations, a new feature that brings icons to life.
            """,
            author: "Letizia Granata",
            postType: .post,
            urlString: "https://www.createwithswift.com/implementing-draw-animations-for-sf-symbols-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 10, day: 30),
            studyLevel: .beginner,
            origin: .cloudNew
        ),
        Post(
            title: "Programmatic navigation with navigation destination in SwiftUI",
            intro: """
                Learn how to use the navigation destination modifier for triggering navigation in a SwiftUI app.
            
                SwiftUI’s modern NavigationStack isolates the logic of how navigation is triggered from how the UI handles it. While NavigationLink(destination:label:) can directly navigate to a view, the navigation destination modifiers provide a more flexible, data-driven approach. Let's explore the different variations of the modifier and when to use each of them.
            """,
            author: "Alfonso Tarallo",
            postType: .post,
            urlString: "https://www.createwithswift.com/programmatic-navigation-with-navigation-destination-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 10, day: 3),
            studyLevel: .beginner,
            notes: """
                navigationDestination
                NavigationPath
            """,
            origin: .cloudNew
        ),
        Post(
            title: "Taking control of your navigation in SwiftUI with NavigationPath",
            intro: """
                Understand how to perform data-driven navigation in a SwiftUI app.
            
                SwiftUI's NavigationStack and NavigationPath provide a powerful and flexible way to perform programmatic navigation in your app. When managing navigation in a SwiftUI app, you often want to push and pop views programmatically, and NavigationPath enables this while also maintaining strong type-safety and flexibility.
            
                The NavigationStack(root:) default initializer sets the root of your navigation hierarchy and handles the navigation path behind the scenes. If you want more control over the navigation path and enable a programmatic approach to your navigation, you can store it with a @State variable and pass it to the NavigationStack(path:root:) initializer. The path parameter needs to be of Binding<Data> type and there are two ways you can use it.
            """,
            author: "Alfonso Tarallo",
            postType: .post,
            urlString: "https://www.createwithswift.com/taking-control-of-your-navigation-in-swiftui-with-navigationpath/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 10, day: 9),
            studyLevel: .beginner,
            notes: """
                navigationDestination
                NavigationPath
                """,
            origin: .cloudNew
        ),
        Post(
            title: "Using rich text in the TextEditor with SwiftUI",
            intro: """
                Explore the usage of rich text within the TextEditor in SwiftUI using AttributedString.
            
                When you need to display and edit long-form text in SwiftUI, TextEditor is often the natural choice. By default, it works with a simple String and behaves as a plain text editor, making it ideal for simple notes or basic input fields.
            
                But starting with iOS 26, macOS 26, and related platforms, TextEditor gained first-class support for AttributedString. With this change, you can transition from editing plain text to creating fully formatted rich text, complete with Markdown, links, attribute transformations, and more.
            """,
            author: "Alfonso Tarallo",
            postType: .post,
            urlString: "https://www.createwithswift.com/using-rich-text-in-the-texteditor-with-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 10, day: 17),
            studyLevel: .beginner,
            notes: """
                AttributedString
                AttributeContainer
                AttributedTextSelection
                typingAttributes
                transformAttributes
                """,
            origin: .cloudNew
        ),
// 2025-10-31
        Post(
            title: "Swift Codable",
            intro: """
                Swift Codable - протокол, позволяющий преобразовывать структуры в бинарные данные и обратно. В этой cтатье раскрыт механизм его работы "под капотом".
                """,
            author: "Grandschtien",
            postType: .post,
            urlString: "https://habr.com/ru/articles/953560/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 10, day: 5),
            studyLevel: .beginner),
        Post(
            title: "Swift: Dead Simple Formatting (Dates, Numbers, Currency, Measurement, Time)",
            intro: """
                In this video I show you the power of the FormatStyle API as well as a resource that shows examples of all the ways you can format numbers, currency, dates, measurements, time, and more. You can now easily create any format you like with this powerful API.
                """,
            author: "Sean Allen",
            postType: .post,
            urlString: "https://habr.com/ru/articles/953560/",
            postPlatform: .youtube,
            postDate: Date.from(year: 2025, month: 1, day: 2),
            studyLevel: .beginner,
            notes: """
                https://fuckingformatstyle.com/
                https://github.com/brettohland/fuckingformatstyle
                """,
            origin: .cloudNew
        ),
        Post(
            title: "Format Styles In Excruciating Detail",
            intro: """
                Swift’s FormatStyle and ParseableFormatStyle are the easiest way to convert Foundation data types to and from localized strings. Unfortunately Apple hasn’t done a great job in documenting just what it can do, or how to use them.

                This site is going to help you do just that.
            """,
            author: "Ampersandsoftworks",
            postType: .post,
            urlString: "https://fuckingformatstyle.com/#the-basics",
            postPlatform: .website,
            postDate: nil,
            studyLevel: .beginner,
            origin: .cloudNew
        ),
        
        
        
        
        
        
        
    ]
    
    

}
