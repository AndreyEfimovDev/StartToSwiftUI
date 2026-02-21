//
//  FBPostModel.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 21.02.2026.
//

import Foundation
import FirebaseFirestore

// MARK: - Firestore Notice Model
struct FBPostModel {
    let postId: String
    let category: String
    let title: String
    let intro: String
    let author: String
    let postType: PostType
    let urlString: String
    let postPlatform: Platform
    let postDate: Date
    let studyLevel: StudyLevel
    let date: Date
    
    init(
        postId: String,
        category: String,
        title: String,
        intro: String,
        author: String,
        postType: PostType,
        urlString: String,
        postPlatform: Platform,
        postDate: Date,
        studyLevel: StudyLevel,
        date: Date
    ) {
        self.postId = postId
        self.category = category
        self.title = title
        self.intro = intro
        self.author = author
        self.postType = postType
        self.urlString = urlString
        self.postPlatform = postPlatform
        self.postDate = postDate
        self.studyLevel = studyLevel
        self.date = date
    }
}

// MARK: - Firestore Post Mapping
extension FBPostModel {
    // Initialisation from the Firestore DocumentSnapshot
    init?(document: DocumentSnapshot) {
        guard
            let data = document.data(),
            let category = data["category"] as? String,
            let title = data["title"] as? String,
            let intro = data["intro"] as? String,
            let author = data["author"] as? String,
            let postType = data["post_type"] as? String,
            let urlString = data["url_string"] as? String,
            let postPlatform = data["post_platform"] as? String,
            let postDate = data["post_date"] as? Timestamp,
            let studyLevel = data["study_level"] as? String,
            let date = data["date"] as? Timestamp
        else {
            return nil
        }
        self.postId = document.documentID
        self.category = category
        self.title = title
        self.intro = intro
        self.author = author
        self.postType = PostType(rawValue: postType) ?? .other
        self.urlString = urlString
        self.postPlatform = Platform(rawValue: postPlatform) ?? .youtube
        self.postDate = postDate.dateValue() // apply dateValue() to Timestamp to get Date
        self.studyLevel = StudyLevel(rawValue: studyLevel) ?? .beginner
        // Truncate to seconds — remove nanoseconds from Firestore Timestamp
        let rawDate = date.dateValue()
        self.date = Date(timeIntervalSince1970: rawDate.timeIntervalSince1970.rounded(.down))
    }
}
