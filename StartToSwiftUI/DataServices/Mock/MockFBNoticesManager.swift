//
//  MockFBNoticesManager.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 26.02.2026.
//

import Foundation

final class MockFBNoticesManager: FBNoticesManagerProtocol {
    
    // MARK: - Control Properties
    var noticesToReturn: [FBNoticeModel] = []
    var fetchCallCount = 0
    var shouldSimulateDelay = false
    var shouldSimulateNetworkError = false  // ← новое
    
    // MARK: - Factory Methods
    static func mockNotices(_ notices: [FBNoticeModel]) -> MockFBNoticesManager {
        let mock = MockFBNoticesManager()
        mock.noticesToReturn = notices
        return mock
    }
    
    static func mockEmpty() -> MockFBNoticesManager {
        MockFBNoticesManager()
    }
    
    static func mockNetworkError() -> MockFBNoticesManager {  // ← новое
        let mock = MockFBNoticesManager()
        mock.shouldSimulateNetworkError = true
        return mock
    }
    
    // MARK: - Protocol Implementation
    func fetchFBNotices(after: Date) async -> Result<[FBNoticeModel], FBFetchError> {
        fetchCallCount += 1
        if shouldSimulateDelay {
            try? await Task.sleep(nanoseconds: 500_000_000)
        }
        if shouldSimulateNetworkError {
            return .failure(.networkUnavailable)
        }
        return .success(noticesToReturn.filter { $0.noticeDate > after })
    }
}

// MARK: - FBNoticeModel Test Helpers
extension FBNoticeModel {
    static func mock(
        noticeId: String = UUID().uuidString,
        title: String = "Test Notice",
        message: String = "Test Message",
        noticeDate: Date = Date()
    ) -> FBNoticeModel {
        FBNoticeModel(
            noticeId: noticeId,
            title: title,
            message: message,
            noticeDate: noticeDate
        )
    }
    
    static let mockUnread = FBNoticeModel.mock(title: "Unread Notice", noticeDate: Date())
    static let mockOld = FBNoticeModel.mock(
        title: "Old Notice",
        noticeDate: Date(timeIntervalSince1970: 0)
    )
}
