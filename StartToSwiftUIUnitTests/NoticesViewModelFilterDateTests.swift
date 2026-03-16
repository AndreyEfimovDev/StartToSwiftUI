//
//  NoticesViewModelFilterDateTests.swift
//  StartToSwiftUI
//
//  Tests for filterDate logic in importNoticesFromFirebase
//  Covers the bug: .rounded(.down) + addingTimeInterval(1) caused notices to disappear
//

import XCTest
@testable import StartToSwiftUI

// MARK: - Helpers
private func makeNotice(id: String, date: Date) -> FBNoticeModel {
    FBNoticeModel(
        noticeId: id,
        title: "Notice \(id)",
        message: "Body",
        noticeDate: date
    )
}
private func makeStoredNotice(id: String) -> Notice {
    let n = Notice()
    n.id = id
    return n
}

// MARK: - Tests
@MainActor
final class NoticesViewModelFilterDateTests: XCTestCase {

    var sut: NoticesViewModel!
    var mockFB: MockFBNoticesManager!
    var mockState: MockAppSyncStateManager!
    var mockDataSource: MockNoticesDataSource!

    override func setUp() {
        super.setUp()
        mockFB = MockFBNoticesManager()
        mockState = MockAppSyncStateManager()
        mockDataSource = MockNoticesDataSource()

        sut = NoticesViewModel(
            dataSource: mockDataSource,
            appStateManager: mockState,
            fbNoticesManager: mockFB
        )
    }

    // MARK: - filterDate = max(lastNoticeDate, firstLaunchDate)

    /// lastNoticeDate > firstLaunchDate → filterDate should equal lastNoticeDate exactly
    func test_filterDate_usesLastNoticeDate_whenItIsGreater() async {
        let lastNotice = Date(timeIntervalSince1970: 1_700_000_100)
        let firstLaunch = Date(timeIntervalSince1970: 1_700_000_000)

        mockState.stubbedLastNoticeDate = lastNotice
        mockState.stubbedFirstLaunchDate = firstLaunch

        await sut.importNoticesFromFirebase()

        XCTAssertEqual(mockFB.capturedFilterDate, lastNotice,
            "filterDate должен равняться lastNoticeDate без округления")
    }

    /// firstLaunchDate > lastNoticeDate → filterDate should equal firstLaunchDate exactly
    func test_filterDate_usesFirstLaunchDate_whenItIsGreater() async {
        let lastNotice = Date(timeIntervalSince1970: 1_700_000_000)
        let firstLaunch = Date(timeIntervalSince1970: 1_700_000_500)

        mockState.stubbedLastNoticeDate = lastNotice
        mockState.stubbedFirstLaunchDate = firstLaunch

        await sut.importNoticesFromFirebase()

        XCTAssertEqual(mockFB.capturedFilterDate, firstLaunch,
            "filterDate должен равняться firstLaunchDate без округления")
    }

    /// Both dates nil → filterDate should be Unix epoch (load everything)
    func test_filterDate_usesEpoch_whenBothDatesNil() async {
        mockState.stubbedLastNoticeDate = nil
        mockState.stubbedFirstLaunchDate = nil

        await sut.importNoticesFromFirebase()

        XCTAssertEqual(mockFB.capturedFilterDate, Date(timeIntervalSince1970: 0),
            "filterDate должен быть Unix Epoch если обе даты nil")
    }

    // MARK: - Regression: no .rounded(.down) precision loss

    /// Notice with sub-second date must NOT be cut off by rounding
    func test_filterDate_preservesSubSecondPrecision() async throws {
        // Date with fractional seconds — was lost by .rounded(.down)
        let preciseDate = Date(timeIntervalSince1970: 1_700_000_100.75)
        mockState.stubbedLastNoticeDate = preciseDate
        mockState.stubbedFirstLaunchDate = Date(timeIntervalSince1970: 0)

        await sut.importNoticesFromFirebase()

        let capturedInterval = try XCTUnwrap(mockFB.capturedFilterDate?.timeIntervalSince1970)
        XCTAssertEqual(capturedInterval,
                       preciseDate.timeIntervalSince1970,
                       accuracy: 0.001,
                       "Долевые секунды не должны теряться при округлении")
    }

    // MARK: - Regression: no addingTimeInterval(+1) gap

    /// Notice dated exactly at lastNoticeDate must NOT be skipped
    func test_noticeAtExactLastNoticeDateIsNotSkipped() async {
        let exactDate = Date(timeIntervalSince1970: 1_700_000_100)

        mockState.stubbedLastNoticeDate = exactDate
        mockState.stubbedFirstLaunchDate = Date(timeIntervalSince1970: 0)

        // Firebase returns a notice with date == filterDate
        // (Firestore uses isGreaterThan so it won't return it, but the +1s bug
        //  caused the filter window to *start* at exactDate+1, skipping real new notices)
        let newNotice = makeNotice(id: "new-001", date: exactDate.addingTimeInterval(0.5))
        mockFB.noticesToReturn = [newNotice]

        await sut.importNoticesFromFirebase()

        XCTAssertEqual(mockDataSource.insertedNotices.count, 1,
            "Notice с датой чуть больше lastNoticeDate не должен пропасть")
    }

    /// Notice dated lastNoticeDate + 0.5s must be saved (was lost by +1s offset)
    func test_noticeWithHalfSecondAfterLastDate_isNotSkipped() async {
        let lastDate = Date(timeIntervalSince1970: 1_700_000_100)
        mockState.stubbedLastNoticeDate = lastDate
        mockState.stubbedFirstLaunchDate = Date(timeIntervalSince1970: 0)

        let slippedNotice = makeNotice(id: "slip-001", date: lastDate.addingTimeInterval(0.5))
        mockFB.noticesToReturn = [slippedNotice]

        await sut.importNoticesFromFirebase()

        XCTAssertTrue(mockDataSource.insertedNotices.contains(where: { $0.id == "slip-001" }),
            "Notice с датой lastNoticeDate+0.5s должен быть сохранён")
    }

    // MARK: - updateLatestNoticeDate saves exact date (no +1s)

    func test_latestNoticeDateSavedWithoutOffset() async throws {
        let noticeDate = Date(timeIntervalSince1970: 1_700_001_000)
        mockState.stubbedLastNoticeDate = Date(timeIntervalSince1970: 0)
        mockState.stubbedFirstLaunchDate = Date(timeIntervalSince1970: 0)
        mockFB.noticesToReturn = [makeNotice(id: "n1", date: noticeDate)]

        await sut.importNoticesFromFirebase()

        let capturedInterval = try XCTUnwrap(mockState.savedLatestNoticeDate?.timeIntervalSince1970)
        XCTAssertEqual(capturedInterval,
                       noticeDate.timeIntervalSince1970,
                       accuracy: 0.001,
                       "Сохранённая дата не должна иметь +1 смещение")
    }

    // MARK: - Duplicate protection via existingIDs

    /// A notice already in SwiftData must NOT be inserted again
    func test_existingNotice_isNotInsertedAgain() async {
        let stored = makeStoredNotice(id: "existing-001")
        mockDataSource.storedNotices = [stored]

        let duplicate = makeNotice(id: "existing-001", date: Date())
        mockFB.noticesToReturn = [duplicate]

        mockState.stubbedLastNoticeDate = Date(timeIntervalSince1970: 0)
        mockState.stubbedFirstLaunchDate = Date(timeIntervalSince1970: 0)

        await sut.importNoticesFromFirebase()

        XCTAssertTrue(mockDataSource.insertedNotices.isEmpty,
            "Дубликат не должен вставляться в SwiftData")
    }

    /// Only truly new notices should be inserted
    func test_onlyNewNoticesAreInserted() async {
        let stored = makeStoredNotice(id: "old-001")
        mockDataSource.storedNotices = [stored]

        mockFB.noticesToReturn = [
            makeNotice(id: "old-001", date: Date()),   // duplicate
            makeNotice(id: "new-001", date: Date()),   // new
            makeNotice(id: "new-002", date: Date()),   // new
        ]

        mockState.stubbedLastNoticeDate = Date(timeIntervalSince1970: 0)
        mockState.stubbedFirstLaunchDate = Date(timeIntervalSince1970: 0)

        await sut.importNoticesFromFirebase()

        XCTAssertEqual(mockDataSource.insertedNotices.count, 2,
            "Должны быть вставлены только 2 новых notice")
        XCTAssertFalse(mockDataSource.insertedNotices.contains(where: { $0.id == "old-001" }),
            "Дубликат 'old-001' не должен быть вставлен")
    }

    // MARK: - Empty result — no crash, no insert

    func test_emptyFirebaseResult_noInsert_noSave() async {
        mockFB.noticesToReturn = []
        mockState.stubbedLastNoticeDate = Date()
        mockState.stubbedFirstLaunchDate = Date()

        await sut.importNoticesFromFirebase()

        XCTAssertTrue(mockDataSource.insertedNotices.isEmpty)
        XCTAssertEqual(mockDataSource.saveCallCount, 0)
    }

    // MARK: - No appStateManager

    /// Without appStateManager, filterDate must be Unix epoch
    func test_withoutAppStateManager_filterDateIsEpoch() async {
        sut = NoticesViewModel(
            dataSource: mockDataSource,
            appStateManager: nil,
            fbNoticesManager: mockFB
        )

        await sut.importNoticesFromFirebase()

        XCTAssertEqual(mockFB.capturedFilterDate, Date(timeIntervalSince1970: 0))
    }
}
