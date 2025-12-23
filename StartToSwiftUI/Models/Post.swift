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
    var urlString: String = "https://"
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
        urlString: String = "https://",
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
        self.startedDateStamp = startedDateStamp
        self.studiedDateStamp = studiedDateStamp
        self.practicedDateStamp = practicedDateStamp
    }
}


//struct Post: Identifiable, Hashable, Codable {
//    let id: String
//    var category: String // post category, e.g. "SwiftUI", "C++", "JavaScript", etc.
//    var title: String // post title
//    var intro: String // short post intro/description
//    var author: String // author of the post
//    var postType: PostType // single post, course/collection/playlist, solution, bug or other
//    var urlString: String // url link on the post
//    var postPlatform: Platform // platform location - website, youtube/video, etc
//    var postDate: Date? // date of the post
//    var studyLevel: StudyLevel // study level of the post
//    var progress: StudyProgress // progress in learning
//    var favoriteChoice: FavoriteChoice // to mark favourite posts
//    var postRating: PostRating? // for rating post
//    var notes: String // free text field/notes to enter everything you wish
//    let origin: PostOrigin // origin source of the post: local created/ downloaded from cloud/ static
//    var draft: Bool // draft -> true
//    let date: Date // creation post date
//    var startedDateStamp: Date? // date when the materila is marked as "Studied"
//    var studiedDateStamp: Date? // date when the materila is marked as "Studied"
//    var practicedDateStamp: Date? // date when the materila is marked as "Practiced"
//    
//    init(
//        id: String = UUID().uuidString,
//        category: String = "SwiftUI",
//        title: String = "",
//        intro: String = "",
//        author: String = "",
//        postType: PostType = .post,
//        urlString: String = "https://",
//        postPlatform: Platform = .youtube,
//        postDate: Date? = nil,
//        studyLevel: StudyLevel = .beginner,
//        progress: StudyProgress = .fresh,
//        favoriteChoice: FavoriteChoice = .no,
//        postRating: PostRating? = nil,
//        notes: String = "",
//        origin: PostOrigin = .cloud,
//        draft: Bool = false,
//        date: Date = .now,
//        startedDateStamp: Date? = nil,
//        studiedDateStamp: Date? = nil,
//        practicedDateStamp: Date? = nil
//    ) {
//        self.id = id
//        self.category = category
//        self.title = title
//        self.intro = intro
//        self.author = author
//        self.postType = postType
//        self.urlString = urlString
//        self.postPlatform = postPlatform
//        self.postDate = postDate
//        self.studyLevel = studyLevel
//        self.progress = progress
//        self.favoriteChoice = favoriteChoice
//        self.postRating = postRating
//        self.notes = notes
//        self.origin = origin
//        self.draft = draft
//        self.date = date
//        self.startedDateStamp = startedDateStamp
//        self.studiedDateStamp = studiedDateStamp
//        self.practicedDateStamp = practicedDateStamp
//    }
//}


