//
//  TestMocks.swift
//  StartToSwiftUIUnitTests
//
//  Created by Andrey Efimov on 13.03.2026.
//
import XCTest
@testable import StartToSwiftUI

// MARK: - Mock: AppSyncStateManager
final class MockAppSyncStateManager: AppSyncStateManagerProtocol {
    var stubbedLastNoticeDate: Date?
    var stubbedFirstLaunchDate: Date?
    var savedLatestNoticeDate: Date?

    func getLastNoticeDate() -> Date? { stubbedLastNoticeDate }
    func getAppFirstLaunchDate() -> Date? { stubbedFirstLaunchDate }
    func updateLatestNoticeDate(_ date: Date) { savedLatestNoticeDate = date }
}

// MARK: - Mock: FBNoticesManager
final class MockFBNoticesManager: FBNoticesManagerProtocol {

    var noticesToReturn: [FBNoticeModel] = []
    var capturedFilterDate: Date?
    var fetchCallCount = 0
    var shouldSimulateDelay = false

    func fetchFBNotices(after date: Date) async -> Result<[FBNoticeModel], FBFetchError> {
        capturedFilterDate = date
        fetchCallCount += 1
        if shouldSimulateDelay {
            try? await Task.sleep(nanoseconds: 600_000_000)
        }
        return .success(noticesToReturn)
    }

    static func mockNotices(_ notices: [FBNoticeModel]) -> MockFBNoticesManager {
        let mock = MockFBNoticesManager()
        mock.noticesToReturn = notices
        return mock
    }

    static func mockEmpty() -> MockFBNoticesManager {
        MockFBNoticesManager()
    }
}

//// MARK: - Mock: NoticesDataSource
//final class MockNoticesDataSource: NoticesDataSourceProtocol {
//
//    var storedNotices: [Notice] = []
//    var insertedNotices: [Notice] = []
//    var deletedNotices: [Notice] = []
//    var saveCallCount = 0
//
//    init(notices: [Notice] = []) {
//        self.storedNotices = notices
//    }
//
//    func fetchNotices() throws -> [Notice] {
//        storedNotices
//    }
//
//    func insert(_ notice: Notice) {
//        insertedNotices.append(notice)
//        storedNotices.append(notice)
//    }
//
//    func delete(_ notice: Notice) {
//        deletedNotices.append(notice)
//        storedNotices.removeAll { $0.id == notice.id }
//    }
//
//    func save() throws {
//        saveCallCount += 1
//    }
//}

//// MARK: - FBNoticeModel Test Helpers
//extension FBNoticeModel {
//    static func mock(
//        noticeId: String = UUID().uuidString,
//        title: String = "Test",
//        noticeDate: Date = Date()
//    ) -> FBNoticeModel {
//        FBNoticeModel(noticeId: noticeId, title: title, message: "Message", noticeDate: noticeDate)
//    }
//
//    static var mockUnread: FBNoticeModel {
//        mock(noticeId: "unread-001", title: "Unread Notice")
//    }
//}
