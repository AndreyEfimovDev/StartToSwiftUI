//
//  Untitled.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 20.02.2026.
//

import Foundation
import FirebaseFirestore

// MARK: - Firestore Notice Model
struct FBNoticeModel {
    let noticeId: String
    let title: String
    let message: String
    let noticeDate: Date
    
    init(
        noticeId: String,
        title: String,
        message: String,
        noticeDate: Date
    ) {
        self.noticeId = noticeId
        self.title = title
        self.message = message
        self.noticeDate = noticeDate
    }
}

// MARK: - Firestore Notice Mapping
extension FBNoticeModel {
    // Initialisation from the Firestore DocumentSnapshot
    init?(document: DocumentSnapshot) {
        guard
            let data = document.data(),
            let title = data["title"] as? String,
            let message = data["notice_message"] as? String,
            let timestamp = data["notice_date"] as? Timestamp
        else {
            return nil
        }
        self.noticeId = document.documentID
        self.title = title
        self.message = message
        // Truncate to seconds — remove nanoseconds from Firestore Timestamp
        let rawDate = timestamp.dateValue()
        self.noticeDate = Date(timeIntervalSince1970: rawDate.timeIntervalSince1970.rounded(.down))
    }
}



