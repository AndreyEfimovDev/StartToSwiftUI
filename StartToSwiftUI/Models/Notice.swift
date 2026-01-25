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
    var id: String = UUID().uuidString // CloudKit НЕ поддерживает @Attribute(.unique)
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

