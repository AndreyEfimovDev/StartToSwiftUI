//
//  NoticesTests.swift
//  StartToSwiftUIUnitTests
//
//  Created by Andrey Efimov on 21.01.2026.
//

import XCTest
import SwiftData
@testable import StartToSwiftUI

@MainActor
final class NoticeViewModelTests: XCTestCase {
    
    var dataSource: MockNoticesDataSource!
    var networkService: MockFBNoticesManager!
    var noticeVM: NoticeViewModel!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Сбросить UserDefaults
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        
        // Используем Mock DataSource вместо реального SwiftData
        dataSource = MockNoticesDataSource(notices: [])
        
        // Используем Mock NetworkService
        networkService = MockFBNoticesManager.mockNotices([])
        
        // Инициализируем ViewModel с моками
        noticeVM = NoticeViewModel(
            dataSource: dataSource
        )
        
        // Небольшая задержка для async операций
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 секунда
    }
    
    override func tearDown() async throws {
        noticeVM = nil
        dataSource = nil
        networkService = nil
        try await super.tearDown()
    }
    
    // MARK: - Network Tests
    
    func testImportNoticesFromFirebase_WhenNewNotices_ImportsSuccessfully() async throws {
        // Given
        let mockNotices = [
            FBNoticeModel.mock(noticeId: "1", title: "Notice 1", noticeDate: Date()),
            FBNoticeModel.mock(noticeId: "2", title: "Notice 2", noticeDate: Date())
        ]
        let mockFB = MockFBNoticesManager.mockNotices(mockNotices)
        let testVM = NoticeViewModel(
            dataSource: MockNoticesDataSource(notices: []),
            fbNoticesManager: mockFB
        )
        
        // When
        await testVM.importNoticesFromFirebase()
        
        // Then
        XCTAssertEqual(testVM.notices.count, 2)
        XCTAssertEqual(mockFB.fetchCallCount, 1)
    }
    
    func testImportNoticesFromFirebase_WhenDuplicates_SkipsDuplicates() async {
        // Given
        let existingNotice = Notice(id: "existing", title: "Existing", isRead: true)
        let dataSource = MockNoticesDataSource(notices: [existingNotice])
        
        let mockNotices = [
            FBNoticeModel.mock(noticeId: "existing", title: "Duplicate"),
            FBNoticeModel.mock(noticeId: "new", title: "New Notice")
        ]
        let mockFB = MockFBNoticesManager.mockNotices(mockNotices)
        let testVM = NoticeViewModel(
            dataSource: dataSource,
            fbNoticesManager: mockFB
        )
        
        // When
        await testVM.importNoticesFromFirebase()
        testVM.loadNoticesFromSwiftData()
        
        // Then
        XCTAssertEqual(testVM.notices.count, 2)
        let existingInArray = testVM.notices.first { $0.id == "existing" }
        XCTAssertEqual(existingInArray?.title, "Existing") // оригинал не перезаписан
    }
    
    func testImportNoticesFromFirebase_WhenEmpty_DoesNotAddNotices() async {
        // Given
        let mockFB = MockFBNoticesManager.mockEmpty()
        let testVM = NoticeViewModel(
            dataSource: MockNoticesDataSource(notices: []),
            fbNoticesManager: mockFB
        )
        
        // When
        await testVM.importNoticesFromFirebase()
        
        // Then
        XCTAssertEqual(testVM.notices.count, 0)
    }
    
    func testImportNoticesFromFirebase_WithDelay_HandlesCorrectly() async throws {
        // Given
        let mockNotices = [FBNoticeModel.mockUnread]
        let mockFB = MockFBNoticesManager.mockNotices(mockNotices)
        mockFB.shouldSimulateDelay = true
        
        let testVM = NoticeViewModel(
            dataSource: MockNoticesDataSource(notices: []),
            fbNoticesManager: mockFB
        )
        
        // When
        let start = Date()
        await testVM.importNoticesFromFirebase()
        let duration = Date().timeIntervalSince(start)
        
        // Then
        XCTAssertGreaterThan(duration, 0.5)
        XCTAssertEqual(testVM.notices.count, 1)
    }
}
