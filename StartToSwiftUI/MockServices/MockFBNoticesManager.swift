//
//  MockFBNoticesManager.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 26.02.2026.
//

import Foundation

//#if DEBUG
// MARK: - MockFBNoticesManager
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

    // Factory methods для совместимости с NoticesTests
    static func mockNotices(_ notices: [FBNoticeModel]) -> MockFBNoticesManager {
        let mock = MockFBNoticesManager()
        mock.noticesToReturn = notices
        return mock
    }

    static func mockEmpty() -> MockFBNoticesManager {
        MockFBNoticesManager()
    }
}
//#endif
