//
//  CodablePost.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 17.12.2025.
//

import Foundation

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
    var startedDateStamp: Date?
    var studiedDateStamp: Date?
    var practicedDateStamp: Date?
}

