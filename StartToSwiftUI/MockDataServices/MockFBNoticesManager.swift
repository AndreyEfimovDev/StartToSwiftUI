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
    
    // MARK: - Factory Methods
    static func mockNotices(_ notices: [FBNoticeModel]) -> MockFBNoticesManager {
        let mock = MockFBNoticesManager()
        mock.noticesToReturn = notices
        return mock
    }
    
    static func mockEmpty() -> MockFBNoticesManager {
        MockFBNoticesManager()
    }
    
    // MARK: - Protocol Implementation
    func getAllNotices(after: Date) async -> [FBNoticeModel] {
        fetchCallCount += 1
        if shouldSimulateDelay {
            try? await Task.sleep(nanoseconds: 500_000_000)
        }
        return noticesToReturn.filter { $0.noticeDate > after }
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
