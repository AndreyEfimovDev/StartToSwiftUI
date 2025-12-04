//
//  DataModel.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.08.2025.
//

import Foundation
import SwiftUI

struct Post: Identifiable, Hashable, Codable {
    let id: String
    var category: String // gategory the post belongs to, e.g. "SwiftUI", "C++", "JavaScript"
    var title: String // title of the post
    var intro: String // a short intro/description of the post
    var author: String // author of the post
    var postType: PostType // single post, course/collection/playlist, solution, bug or other
    var urlString: String // url link of the post
    var postPlatform: Platform // platform location - website, youtube/video, etc
    var postDate: Date? // date of the post
    var studyLevel: StudyLevel // study level of the post
    var progress: StudyProgress // progress in learning
    var favoriteChoice: FavoriteChoice // to mark favourite posts
    var postRating: PostRating? // for rating post
    var notes: String // free text field/notes to enter everything you wish
    let origin: PostOrigin // origin source of the post: local created or downloaded from cloud curated by the developer
    var draft: Bool // draft sign: true - draft, false - not draft
    let date: Date // date of creating the post
    
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
        progress: StudyProgress = .untapped,
        favoriteChoice: FavoriteChoice = .no,
        postRating: PostRating? = nil,
        notes: String = "",
        origin: PostOrigin = .cloud,
        draft: Bool = false,
        date: Date = .now
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.intro = intro
        self.author = author
        self.postType = postType
        self.urlString = urlString
        self.postPlatform = postPlatform
        self.postDate = postDate
        self.studyLevel = studyLevel
        self.progress = progress
        self.favoriteChoice = favoriteChoice
        self.postRating = postRating
        self.notes = notes
        self.origin = origin
        self.draft = draft
        self.date = date
    }
}


