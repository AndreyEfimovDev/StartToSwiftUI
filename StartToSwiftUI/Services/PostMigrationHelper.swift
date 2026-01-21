//
//  PostMigrationHelper.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 17.12.2025.
//

import SwiftUI

struct PostMigrationHelper {
    
    /// Converts an old Codable Post to a SwiftData Post
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
            date: codablePost.date,
            addedDateStamp: codablePost.addedDateStamp,
            startedDateStamp: codablePost.startedDateStamp,
            studiedDateStamp: codablePost.studiedDateStamp,
            practicedDateStamp: codablePost.practicedDateStamp
        )
    }
}
