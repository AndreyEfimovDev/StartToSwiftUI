//
//  NoticeMigrationHelper.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 17.12.2025.
//

import Foundation

struct NoticeMigrationHelper {
    
    /// Конвертирует старый Codable Notice в SwiftData Notice
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
