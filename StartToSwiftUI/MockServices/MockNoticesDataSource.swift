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

    init(notices: [Notice] = []) {
        self.storedNotices = notices
    }

    func fetchNotices() throws -> [Notice] { storedNotices }
    func insert(_ notice: Notice) {
        insertedNotices.append(notice)
        storedNotices.append(notice)
    }
    func delete(_ notice: Notice) {
        deletedNotices.append(notice)
        storedNotices.removeAll { $0.id == notice.id }
    }
    func save() throws { saveCallCount += 1 }
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
