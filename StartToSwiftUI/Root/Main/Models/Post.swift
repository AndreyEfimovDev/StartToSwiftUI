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
//    var postLanguage: LanguageOptions // Language of the post
    var postType: PostType
    var urlString: String // url link of the post
    var postPlatform: Platform // platform location
    var postDate: Date? // date of the post
    var studyLevel: StudyLevel // study level of the post
    var favoriteChoice: FavoriteChoice
    var additionalText: String // free text field to enter everything you wish
    
    init(
        id: UUID = UUID(),
        title: String,
        intro: String,
        author: String,
//        postLanguage: LanguageOptions = .english,
        postType: PostType = .post,
        urlString: String = "www.apple.com",
        postPlatform: Platform = .youtube,
        postDate: Date? = nil,
        studyLevel: StudyLevel = .beginner,
        favoriteChoice: FavoriteChoice = .no,
        additionalText: String = "",
    ) {
        self.id = id
        self.title = title
        self.intro = intro
        self.author = author
//        self.postLanguage = postLanguage
        self.postType = postType
        self.urlString = urlString
        self.postPlatform = postPlatform
        self.postDate = postDate
        self.studyLevel = studyLevel
        self.favoriteChoice = favoriteChoice
        self.additionalText = additionalText
    }
}


