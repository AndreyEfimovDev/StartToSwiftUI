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
    var id: String = UUID().uuidString // CloudKit DO NOT support @Attribute(.unique)
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
    var statusRawValue: String = "active"
    var date: Date = Date() // Date this entry was created
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
    
    var status: PostStatus {
        get { PostStatus(rawValue: statusRawValue) ?? .active }
        set { statusRawValue = newValue.rawValue }
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
        status: PostStatus = .active,
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
        self.statusRawValue = status.rawValue
        self.date = date
        self.addedDateStamp = addedDateStamp
        self.startedDateStamp = startedDateStamp
        self.studiedDateStamp = studiedDateStamp
        self.practicedDateStamp = practicedDateStamp
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
            status: self.status,
            date: self.date,
            addedDateStamp: self.addedDateStamp,
            startedDateStamp: self.startedDateStamp,
            studiedDateStamp: self.studiedDateStamp,
            practicedDateStamp: self.practicedDateStamp
        )
    }

    // MARK: For AddEditPostView module: compare only those fields that the user can edit
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
    
    // MARK: For AddEditPostView module: update only those fields that the user can edit
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

struct PostMigrationHelper {
    
    /// Converts JSON codable post to a SwiftData post
    static func convertFromCodable(_ codablePost: CodablePost) -> Post {
        return Post(
            id: codablePost.id,
            category: codablePost.category,
            title: codablePost.title,
            intro: codablePost.intro,
            author: codablePost.author,
            postType: codablePost.postType,
            urlString: codablePost.urlString,
            postPlatform: codablePost.postPlatform,
            postDate: codablePost.postDate,
            studyLevel: codablePost.studyLevel,
            progress: codablePost.progress,
            favoriteChoice: codablePost.favoriteChoice,
            postRating: codablePost.postRating,
            notes: codablePost.notes,
            origin: codablePost.origin,
            draft: codablePost.draft,
            status: codablePost.status,
            date: codablePost.date,
            addedDateStamp: codablePost.addedDateStamp,
            startedDateStamp: codablePost.startedDateStamp,
            studiedDateStamp: codablePost.studiedDateStamp,
            practicedDateStamp: codablePost.practicedDateStamp
        )
    }
}


