//
//  DataModel.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.08.2025.
//

import Foundation
import SwiftUI
import SwiftData

@Model
final class Post {
    var id: String = UUID().uuidString // CloudKit НЕ поддерживает @Attribute(.unique)
    var category: String = "SwiftUI"
    var title: String = ""
    var intro: String = ""
    var author: String = ""
    var postTypeRawValue: String = "post"
    var urlString: String = Constants.urlStart
    var postPlatformRawValue: String = "youtube"
    var postDate: Date?
    var studyLevelRawValue: String = "beginner"
    var progressRawValue: String = "fresh"
    var favoriteChoiceRawValue: String = "no"
    var postRatingRawValue: String?
    var notes: String = ""
    var originRawValue: String = "cloud"
    var draft: Bool = false
    var date: Date = Date() // Дата создание данной записи
    var addedDateStamp: Date?
    var startedDateStamp: Date?
    var studiedDateStamp: Date?
    var practicedDateStamp: Date?
    
    // Computed properties for ease of working with enumerations
    var postType: PostType {
        get { PostType(rawValue: postTypeRawValue) ?? .post }
        set { postTypeRawValue = newValue.rawValue }
    }
    
    var postPlatform: Platform {
        get { Platform(rawValue: postPlatformRawValue) ?? .youtube }
        set { postPlatformRawValue = newValue.rawValue }
    }
    
    var studyLevel: StudyLevel {
        get { StudyLevel(rawValue: studyLevelRawValue) ?? .beginner }
        set { studyLevelRawValue = newValue.rawValue }
    }
    
    var progress: StudyProgress {
        get { StudyProgress(rawValue: progressRawValue) ?? .fresh }
        set { progressRawValue = newValue.rawValue }
    }
    
    var favoriteChoice: FavoriteChoice {
        get { FavoriteChoice(rawValue: favoriteChoiceRawValue) ?? .no }
        set { favoriteChoiceRawValue = newValue.rawValue }
    }
    
    var postRating: PostRating? {
        get {
            guard let raw = postRatingRawValue else { return nil }
            return PostRating(rawValue: raw)
        }
        set { postRatingRawValue = newValue?.rawValue }
    }
    
    var origin: PostOrigin {
        get { PostOrigin(rawValue: originRawValue) ?? .cloud }
        set { originRawValue = newValue.rawValue }
    }
    
    init(
        id: String = UUID().uuidString,
        category: String = "SwiftUI",
        title: String = "",
        intro: String = "",
        author: String = "",
        postType: PostType = .post,
        urlString: String = Constants.urlStart,
        postPlatform: Platform = .youtube,
        postDate: Date? = nil,
        studyLevel: StudyLevel = .beginner,
        progress: StudyProgress = .fresh,
        favoriteChoice: FavoriteChoice = .no,
        postRating: PostRating? = nil,
        notes: String = "",
        origin: PostOrigin = .cloud,
        draft: Bool = false,
        date: Date = .now,
        addedDateStamp: Date? = nil,
        startedDateStamp: Date? = nil,
        studiedDateStamp: Date? = nil,
        practicedDateStamp: Date? = nil
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.intro = intro
        self.author = author
        self.postTypeRawValue = postType.rawValue
        self.urlString = urlString
        self.postPlatformRawValue = postPlatform.rawValue
        self.postDate = postDate
        self.studyLevelRawValue = studyLevel.rawValue
        self.progressRawValue = progress.rawValue
        self.favoriteChoiceRawValue = favoriteChoice.rawValue
        self.postRatingRawValue = postRating?.rawValue
        self.notes = notes
        self.originRawValue = origin.rawValue
        self.draft = draft
        self.date = date
        self.addedDateStamp = addedDateStamp
        self.startedDateStamp = startedDateStamp
        self.studiedDateStamp = studiedDateStamp
        self.practicedDateStamp = practicedDateStamp
    }
}

// MARK: - Codable версия Post для JSON

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

    // MARK: For AddEditPostSheet module: compare only those fields that the user can edit
extension Post {
    func isEqual(to other: Post) -> Bool {
        return self.category == other.category &&
        self.title == other.title &&
        self.intro == other.intro &&
        self.author == other.author &&
        self.postTypeRawValue == other.postTypeRawValue &&
        self.urlString == other.urlString &&
        self.postPlatformRawValue == other.postPlatformRawValue &&
        self.postDate == other.postDate &&
        self.studyLevelRawValue == other.studyLevelRawValue &&
        self.notes == other.notes
    }
}


extension Post {
    func copy() -> Post {
        return Post(
            id: self.id,
            category: self.category,
            title: self.title,
            intro: self.intro,
            author: self.author,
            postType: self.postType,
            urlString: self.urlString,
            postPlatform: self.postPlatform,
            postDate: self.postDate,
            studyLevel: self.studyLevel,
            progress: self.progress,
            favoriteChoice: self.favoriteChoice,
            postRating: self.postRating,
            notes: self.notes,
            origin: self.origin,
            draft: self.draft,
            date: self.date,
            addedDateStamp: self.addedDateStamp,
            startedDateStamp: self.startedDateStamp,
            studiedDateStamp: self.studiedDateStamp,
            practicedDateStamp: self.practicedDateStamp
        )
    }
    
    func update(with post: Post) {
//        self.id = post.id
        self.category = post.category
        self.title = post.title
        self.intro = post.intro
        self.author = post.author
        self.postType = post.postType
        self.urlString = post.urlString
        self.postPlatform = post.postPlatform
        self.postDate = post.postDate
        self.studyLevel = post.studyLevel
//        self.progress = post.progress
//        self.favoriteChoice = post.favoriteChoice
//        self.postRating = post.postRating
        self.notes = post.notes
//        self.origin = post.origin
        self.draft = post.draft
//        self.date = post.date
//        self.addedDateStamp = post.addedDateStamp
//        self.startedDateStamp = post.startedDateStamp
//        self.studiedDateStamp = post.studiedDateStamp
//        self.practicedDateStamp = post.practicedDateStamp
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
    
    // Предустановленные моки для типичных сценариев
    
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

