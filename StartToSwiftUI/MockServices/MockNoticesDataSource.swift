//
//  MockNoticesDataSource.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.01.2026.
//

import Foundation

//#if DEBUG
// MARK: - MockNoticesDataSource Mock Implementation
final class MockNoticesDataSource: NoticesDataSourceProtocol {

    var storedNotices: [Notice]
    var insertedNotices: [Notice] = []
    var deletedNotices: [Notice] = []
    var saveCallCount = 0
    /// true — save() бросает ошибку (для тестов сценария "сохранение не удалось").
    var shouldThrowOnSave = false

    init(notices: [Notice] = []) {
        self.storedNotices = notices
    }

    func fetchNotices() throws -> [Notice] { storedNotices }
    func insert(_ notice: Notice) {
        insertedNotices.append(notice)
        storedNotices.append(notice)
    }
    // Удаляем конкретный объект, а не все с тем же id — как SwiftData.
    // Иначе при очистке дублей вместе с копиями пропала бы и оставляемая.
    func delete(_ notice: Notice) {
        deletedNotices.append(notice)
        storedNotices.removeAll { $0 === notice }
    }
    func save() throws {
        saveCallCount += 1
        if shouldThrowOnSave { throw MockSaveError.saveFailed }
    }

    enum MockSaveError: Error {
        case saveFailed
    }
}

// MARK: - FBNoticeModel Test Helpers
extension FBNoticeModel {
    static func mock(
        noticeId: String = UUID().uuidString,
        title: String = "Test",
        noticeDate: Date = Date()
    ) -> FBNoticeModel {
        FBNoticeModel(noticeId: noticeId, title: title, message: "Message", noticeDate: noticeDate)
    }

    static var mockUnread: FBNoticeModel {
        mock(noticeId: "unread-001", title: "Unread Notice")
    }
}

//#endif
