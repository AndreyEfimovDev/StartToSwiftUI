//
//  NoticeMigrationHelper.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 17.12.2025.
//

import Foundation

struct NoticeMigrationHelper {
    
    /// Convert an old encoded notification to a SwiftData notification.
    static func convertFromCodable(_ codableNotice: CodableNotice) -> Notice {
        return Notice(
            id: codableNotice.id,
            title: codableNotice.title,
            noticeDate: codableNotice.noticeDate,
            noticeMessage: codableNotice.noticeMessage,
            isRead: codableNotice.isRead
        )
    }
}
