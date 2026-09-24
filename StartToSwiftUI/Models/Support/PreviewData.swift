//
//  PreviewData.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.08.2025.
//

import Foundation
import SwiftUI

struct PreviewData {

    /// Фиксированная дата для тестовых данных.
    ///
    /// id и даты в `PreviewData` намеренно стабильны между запусками: эти
    /// данные служат ещё и "содержимым Firestore" для моков в DEBUG (см.
    /// `DebugConfig`). С `.now` и случайным UUID мок-посты на каждом запуске
    /// выглядели бы новыми, и проверка обновлений всегда отвечала бы "да".
    private static func fixedDate(day: Int) -> Date {
        // Date.from возвращает Optional, но внутри уже есть fallback — nil
        // не бывает; ?? нужен только чтобы развернуть тип.
        Date.from(year: 2026, month: 1, day: day) ?? .distantPast
    }

    static let sampleNotices: [Notice] = [sampleNotice1, sampleNotice2, sampleNotice3]
        
    static let sampleNotice1 = Notice(
        id: "001",
        title: "Update is available",
        noticeDate: fixedDate(day: 1),
        noticeMessage: "New Update includes the following:",
        isRead: true
    )
    static let sampleNotice2 = Notice(
        id: "002",
        title: "New App release 01.01.02 is availavle New App release 01.01.02 is available",
        noticeDate: fixedDate(day: 2),
        noticeMessage: """
            New release includes the following:
            Line 1
            Line 2
            Line 3
            """,
        isRead: true
    )
    static let sampleNotice3 = Notice(
        id: "003",
        title: "New App release 01.01.03 is available",
        noticeDate: fixedDate(day: 3),
        noticeMessage: """
            New release includes the following:
            Line 1
            Line 2
            Line 3
            """
    )
    
    
    static let samplePosts: [Post] = [samplePost1, samplePost2, samplePost3]
        

    static let samplePost1 = Post(
        id: "preview-post-1",
        title: "Property Wrappers",
        intro: "В этом видео я расскажу вам обо всех оболочках, которые нам предлагает SwiftUI для хранения временных данных. Так же вы поймете, в чем отличие между такими оболочки как @State, @StateObject, @ObservedObject, @EnvironmentObject. Эти оболочки очень похожи друг на друга и знание того, когда и какую лучше использовать, имеет решающее значение.",
        author: "Evgenia Bruyko",
        urlString: "https://youtu.be/ExwwrvOT8mI?si=SU__YwU8UlR461Zb",
        postPlatform: .youtube,
        postDate: Date.from(year: 2021, month: 3, day: 26),
        studyLevel: .beginner,
        progress: .added , // added, learning, studied, practiced
        favoriteChoice: .yes,
        postRating: .good, // good, great, excellent
        notes: """
        In this video we are going to explore how we can stylize text for our Text views in SwiftUI.
        We will start by looking at how we can create a `Text` view with the Markdown-formatted base postLanguage version of the string as the localization key,
        We will also see how we can utilize string interpolation to combine and stylize our strings and present them in a text view.
        And finally, we will take a quick look at the power of Attributed strings in SwiftUI.
        
        In this video we are going to explore how we can stylize text for our Text views in SwiftUI.
        We will start by looking at how we can create a `Text` view with the Markdown-formatted base postLanguage version of the string as the localization key,
        We will also see how we can utilize string interpolation to combine and stylize our strings and present them in a text view.
        And finally, we will take a quick look at the power of Attributed strings in SwiftUI.
        
        In this video we are going to explore how we can stylize text for our Text views in SwiftUI.
        We will start by looking at how we can create a `Text` view with the Markdown-formatted base postLanguage version of the string as the localization key,
        We will also see how we can utilize string interpolation to combine and stylize our strings and present them in a text view.
        And finally, we will take a quick look at the power of Attributed strings in SwiftUI.
        """,
        origin: .cloud,
        date: fixedDate(day: 1)
    )
    
    static let samplePost2 = Post(
        id: "preview-post-2",
        title: "SwiftUI Advanced Learning",
        intro: """
            Learn how to build custom views, animations, and transitions. Get familiar with coding techniques such as Dependency Injection and Protocol-Oriented Programming. Write your first unit tests and connect to CloudKit.
            """,
        author: "Nick Sarno",
        postType: .course,
        urlString: "https://www.youtube.com/playlist?list=PLwvDm4Vfkdphc1LLLjCaEd87BEg07M97y",
        postDate: nil,
        studyLevel: .advanced,
        progress: .added, // added, learning, studied, practiced
        postRating: .great, // good, great, excellent
        origin: .local,
        date: fixedDate(day: 2)
    )
    
    static let samplePost3 = Post(
        id: "preview-post-3",
        title: "TEST SwiftUI Advanced Learning",
        intro: """
            TEST TEST TEST
            Learn how to build custom views, animations, and transitions. Get familiar with coding techniques such as Dependency Injection and Protocol-Oriented Programming. Write your first unit tests and connect to CloudKit.
            """,
        author: "Nick Sarno",
        postType: .course,
        urlString: "https://www.youtube.com/playlist?list=PLwvDm4Vfkdphc1LLLjCaEd87BEg07M97y",
        postDate: nil,
        studyLevel: .advanced,
        progress: .studied, // added, learning, studied, practiced
        postRating: .excellent, // good, great, excellent
        origin: .local,
        date: fixedDate(day: 3)
    )
    
    static let samplePost4 = Post(
        id: "preview-post-4",
        title: "How we can stylize text for our Text views in SwiftUI",
        intro: """
        In this video we are going to explore how we can stylize text for our Text views in SwiftUI.
        We will start by looking at how we can create a `Text` view with the Markdown-formatted base postLanguage version of the string as the localization key,
        We will also see how we can utilize string interpolation to combine and stylize our strings and present them in a text view.
        And finally, we will take a quick look at the power of Attributed strings in SwiftUI.
        """,
        author: "Stewart Lynch",
        postType: .other,
        urlString: "https://www.youtube.com/watch?v=rbtIcKKxQ38/",
        postPlatform: .website,
        postDate: Date.from(year: 2022, month: 8, day: 11),
        studyLevel: .middle,
        progress: .practiced, // added, learning, studied, practiced
        favoriteChoice: .no,
        notes: """
        In this video we are going to explore how we can stylize text for our Text views in SwiftUI.
        We will start by looking at how we can create a `Text` view with the Markdown-formatted base postLanguage version of the string as the localization key,
        We will also see how we can utilize string interpolation to combine and stylize our strings and present them in a text view.
        And finally, we will take a quick look at the power of Attributed strings in SwiftUI.
        
        In this video we are going to explore how we can stylize text for our Text views in SwiftUI.
        We will start by looking at how we can create a `Text` view with the Markdown-formatted base postLanguage version of the string as the localization key,
        We will also see how we can utilize string interpolation to combine and stylize our strings and present them in a text view.
        And finally, we will take a quick look at the power of Attributed strings in SwiftUI.
        
        In this video we are going to explore how we can stylize text for our Text views in SwiftUI.
        We will start by looking at how we can create a `Text` view with the Markdown-formatted base postLanguage version of the string as the localization key,
        We will also see how we can utilize string interpolation to combine and stylize our strings and present them in a text view.
        And finally, we will take a quick look at the power of Attributed strings in SwiftUI.
        """,
        origin: .local,
        date: fixedDate(day: 4)
    )
    
    static let sampleDraft1 = Post(
        title: "Draft: Property Wrappers",
        intro: "Черновик статьи о Property Wrappers в SwiftUI...",
        author: "Author Name",
        urlString: "https://example.com",
        postPlatform: .youtube,
        postDate: .now,
        studyLevel: .beginner,
        progress: .added,
        origin: .local,
        draft: true,
    )

    static let sampleDraft2 = Post(
        title: "Draft: SwiftUI Navigation",
        intro: "Черновик о навигации в SwiftUI...",
        author: "Author Name",
        urlString: "https://example.com",
        postPlatform: .website,
        postDate: .now,
        studyLevel: .middle,
        progress: .added,
        origin: .local,
        draft: true,
    )

    static let samplePostsWithDrafts: [Post] = [
        samplePost1, samplePost2, samplePost3, sampleDraft1, sampleDraft2
    ]


}

extension PreviewData {
    
    // MARK: - Codable Posts для Network Mock
    
    static let sampleCodablePosts: [CodablePost] = [
        .mockBeginner,
        .mockMiddle,
        .mockAdvanced,
        .mockFavorite,
        .mockCourse,
        .mockDraft
    ]
    
    // MARK: - Codable Notices для Network Mock
    
    static let sampleCodableNotices: [CodableNotice] = [
        .mockUnread,
        .mockRead,
        .mock(
            id: "3",
            title: "Maintenance Notice",
            noticeDate: Date().addingTimeInterval(-172800),
            noticeMessage: "Scheduled maintenance tomorrow",
            isRead: false
        )
    ]
}





