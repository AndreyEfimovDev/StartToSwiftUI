//
//  DataModel.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.08.2025.
//

import Foundation
import SwiftUI

struct Post: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String // title of the post
    var intro: String // description of the post
    var author: String // author of the post
    var postLanguage: LanguageOptions // Language of the post
    var urlString: String // url link of the post
    var postPlatform: Platform // platform the post is located
    var postDate: Date? // date of the post
    var studyLevel: StudyLevel // knownledge of the post
    var favoriteChoice: FavoriteChoice
    var additionalText: String // free text field to enter everything you wishe
    var date: Date // creation  date of the post
    
    init(
        id: UUID = UUID(),
        title: String = "",
        intro: String = "",
        author: String = "",
        postLanguage: LanguageOptions,
        urlString: String = "www.apple.com",
        postPlatform: Platform,
        postDate: Date? = nil,
        studyLevel: StudyLevel = .beginner,
        favoriteChoice: FavoriteChoice = .no,
        additionalText: String = "",
        date: Date = .now
    ) {
        self.id = id
        self.title = title
        self.intro = intro
        self.author = author
        self.postLanguage = postLanguage
        self.urlString = urlString
        self.postPlatform = postPlatform
        self.postDate = postDate
        self.studyLevel = studyLevel
        self.favoriteChoice = favoriteChoice
        self.additionalText = additionalText
        self.date = date
    }
}


