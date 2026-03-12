//
//  Notification.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 14.11.2025.
//

import Foundation
import SwiftData

@Model
final class Notice {
    var id: String = UUID().uuidString // CloudKit DOES NOT support @Attribute(.unique)
    var title: String = ""
    var noticeDate: Date = Date()
    var noticeMessage: String  = ""
    var isRead: Bool = false
    
    init(
        id: String = UUID().uuidString,
        title: String = "",
        noticeDate: Date = Date(),
        noticeMessage: String = "",
        isRead: Bool = false
    ) {
        self.id = id
        self.title = title
        self.noticeDate = noticeDate
        self.noticeMessage = noticeMessage
        self.isRead = isRead
    }
}

// MARK: Converts JSON codable notice to a SwiftData notice
struct NoticeMigrationHelper {
    static func convertFromCodable(_ codableNotice: CodableNotice) -> Notice {
        return Notice(
            id: codableNotice.id,
            title: codableNotice.title,
            noticeDate: codableNotice.noticeDate,
            noticeMessage: codableNotice.noticeMessage,
            isRead: false
        )
    }
    static func convertFromFirebase(_ firebaseNotice: FBNoticeModel) -> Notice {
        return Notice(
            id: firebaseNotice.noticeId,
            title: firebaseNotice.title,
            noticeDate: firebaseNotice.noticeDate,
            noticeMessage: firebaseNotice.message,
            isRead: false
        )
    }

}

