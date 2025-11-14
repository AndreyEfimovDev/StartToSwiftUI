//
//  Notification.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 14.11.2025.
//

import Foundation


struct Notice: Codable, Equatable {
    
    let id: String
    let noticeDate: Date
    let noticeMessage: String
    var isRead: Bool
    
    init(
        id: String = UUID().uuidString,
        noticeDate: Date,
        noticeMessage: String,
        isRead: Bool = false
    ) {
        self.id = id
        self.noticeDate = noticeDate
        self.noticeMessage = noticeMessage
        self.isRead = isRead
    }
}
