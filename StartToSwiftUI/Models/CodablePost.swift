//
//  CodablePost.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.01.2026.
//

import Foundation

// MARK: - Codable version of Post for JSON

struct CodablePost: Codable {
    let id: String
    var category: String
    var title: String
    var intro: String
    var author: String
    var postType: PostType
    var urlString: String
    var postPlatform: Platform
    var postDate: Date?
    var studyLevel: StudyLevel
    var progress: StudyProgress
    var favoriteChoice: FavoriteChoice
    var postRating: PostRating?
    var notes: String
    let origin: PostOrigin
    var draft: Bool
    let date: Date
    var addedDateStamp: Date?
    var startedDateStamp: Date?
    var studiedDateStamp: Date?
    var practicedDateStamp: Date?
}

extension CodablePost {
    init(from post: Post) {
        self.init(
            id: post.id,
            category: post.category,
            title: post.title,
            intro: post.intro,
            author: post.author,
            postType: post.postType,
            urlString: post.urlString,
            postPlatform: post.postPlatform,
            postDate: post.postDate,
            studyLevel: post.studyLevel,
            progress: post.progress,
            favoriteChoice: post.favoriteChoice,
            postRating: post.postRating,
            notes: post.notes,
            origin: post.origin,
            draft: post.draft,
            date: post.date,
            addedDateStamp: post.addedDateStamp,
            startedDateStamp: post.startedDateStamp,
            studiedDateStamp: post.studiedDateStamp,
            practicedDateStamp: post.practicedDateStamp
        )
    }
}

// MARK: - Test Helpers

extension CodablePost {
    static func mock(
        id: String = UUID().uuidString,
        category: String = "SwiftUI",
        title: String = "Test Post",
        intro: String = "Test Content",
        author: String = "Test Author",
        postType: PostType = .post,
        urlString: String = "https://example.com",
        postPlatform: Platform = .youtube,
        postDate: Date? = nil,
        studyLevel: StudyLevel = .beginner,
        progress: StudyProgress = .fresh,
        favoriteChoice: FavoriteChoice = .no,
        postRating: PostRating? = nil,
        notes: String = "",
        origin: PostOrigin = .cloud,
        draft: Bool = false,
        date: Date = Date(),
        addedDateStamp: Date? = nil,
        startedDateStamp: Date? = nil,
        studiedDateStamp: Date? = nil,
        practicedDateStamp: Date? = nil
    ) -> CodablePost {
        CodablePost(
            id: id,
            category: category,
            title: title,
            intro: intro,
            author: author,
            postType: postType,
            urlString: urlString,
            postPlatform: postPlatform,
            postDate: postDate,
            studyLevel: studyLevel,
            progress: progress,
            favoriteChoice: favoriteChoice,
            postRating: postRating,
            notes: notes,
            origin: origin,
            draft: draft,
            date: date,
            addedDateStamp: addedDateStamp,
            startedDateStamp: startedDateStamp,
            studiedDateStamp: studiedDateStamp,
            practicedDateStamp: practicedDateStamp
        )
    }
    
    // Predefined mocks for typical scenarios
    
    static var mockBeginner: CodablePost {
        mock(
            id: "beginner-1",
            title: "SwiftUI Basics",
            intro: "Learn the fundamentals of SwiftUI",
            studyLevel: .beginner,
            progress: .fresh
        )
    }
    
    static var mockMiddle: CodablePost {
        mock(
            id: "middle-1",
            title: "Advanced SwiftUI",
            intro: "Deep dive into SwiftUI",
            studyLevel: .middle,
            progress: .started,
            startedDateStamp: Date()
        )
    }
    
    static var mockAdvanced: CodablePost {
        mock(
            id: "advanced-1",
            title: "SwiftUI Architecture",
            intro: "Master SwiftUI patterns",
            studyLevel: .advanced,
            progress: .studied,
            studiedDateStamp: Date()
        )
    }
    
    static var mockFavorite: CodablePost {
        mock(
            id: "favorite-1",
            title: "My Favorite Post",
            intro: "Amazing content",
            favoriteChoice: .yes,
            postRating: .excellent
        )
    }
    
    static var mockCourse: CodablePost {
        mock(
            id: "course-1",
            title: "Complete SwiftUI Course",
            intro: "Full course on SwiftUI",
            postType: .course,
            progress: .practiced,
            practicedDateStamp: Date()
        )
    }
    
    static var mockDraft: CodablePost {
        mock(
            id: "draft-1",
            title: "Draft Post",
            intro: "Work in progress",
            origin: .local,
            draft: true
        )
    }
}

