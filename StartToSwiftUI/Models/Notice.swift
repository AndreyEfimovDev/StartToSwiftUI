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
    @Attribute(.unique) var id: String
    var title: String
    var noticeDate: Date
    var noticeMessage: String
    var isRead: Bool
    
    init(
        id: String = UUID().uuidString,
        title: String,
        noticeDate: Date,
        noticeMessage: String,
        isRead: Bool = false
    ) {
        self.id = id
        self.title = title
        self.noticeDate = noticeDate
        self.noticeMessage = noticeMessage
        self.isRead = isRead
    }
}


//struct Notice: Identifiable, Codable, Equatable, Hashable {
//    
//    let id: String
//    let title: String
//    let noticeDate: Date
//    let noticeMessage: String
//    var isRead: Bool
//    
//    init(
//        id: String,
//        title: String,
//        noticeDate: Date,
//        noticeMessage: String,
//        isRead: Bool = false
//    ) {
//        self.id = id
//        self.title = title
//        self.noticeDate = noticeDate
//        self.noticeMessage = noticeMessage
//        self.isRead = isRead
//    }
//}
