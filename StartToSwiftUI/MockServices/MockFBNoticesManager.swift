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

    /// Мок с notices из `PreviewData` — composition root подставляет его
    /// вместо реального Firestore, когда `DebugConfig.useRealServices == false`.
    ///
    /// Мок отдаёт все notices без фильтра по дате (в отличие от Firestore) —
    /// так они видны в debug и после первого запуска; повторно они не
    /// добавляются, дубли отсекаются по id.
    static func previewData() -> MockFBNoticesManager {
        mockNotices(PreviewData.sampleNotices.map {
            FBNoticeModel(
                noticeId: $0.id,
                title: $0.title,
                message: $0.noticeMessage,
                noticeDate: $0.noticeDate
            )
        })
    }
}
//#endif
