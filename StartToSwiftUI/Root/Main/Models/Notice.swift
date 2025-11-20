//
//  Notification.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 14.11.2025.
//

import Foundation


struct Notice: Identifiable, Codable, Equatable, Hashable {
    
    let id: String
    let title: String
    let noticeDate: Date
    let noticeMessage: String
    var isRead: Bool
    
    init(
        id: String,
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
