//
//  CodableNotice.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.01.2026.
//

import Foundation

struct CodableNotice: Codable {
    let id: String
    let title: String
    let noticeDate: Date
    let noticeMessage: String
    var isRead: Bool
}

// MARK: - Notice Helper

extension CodableNotice {
    static func mock(
        id: String = UUID().uuidString,
        title: String = "Test Notice",
        noticeDate: Date = Date(),
        noticeMessage: String = "Test message",
        isRead: Bool = false
    ) -> CodableNotice {
        CodableNotice(
            id: id,
            title: title,
            noticeDate: noticeDate,
            noticeMessage: noticeMessage,
            isRead: isRead
        )
    }
    
    // Predefined mocks for some scenarios
    
    static var mockUnread: CodableNotice {
        mock(
            id: "unread-1",
            title: "New Update Available",
            noticeDate: Date(),
            noticeMessage: "Version 2.0 is ready",
            isRead: false
        )
    }
    
    static var mockRead: CodableNotice {
        mock(
            id: "read-1",
            title: "Welcome",
            noticeDate: Date().addingTimeInterval(-86400),
            noticeMessage: "Thanks for using our app",
            isRead: true
        )
    }
}
