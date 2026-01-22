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
    var networkService: MockNetworkService!
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
        networkService = MockNetworkService.mockNotices([])
        
        // Инициализируем ViewModel с моками
        noticeVM = NoticeViewModel(
            dataSource: dataSource,
            networkService: networkService
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
    
    // MARK: - Load Notices Tests
    
    func testLoadNoticesFromSwiftData_WhenEmpty_ReturnsEmptyArray() {
        // Given: пустая база данных
        
        // When
        noticeVM.loadNoticesFromSwiftData()
        
        // Then
        XCTAssertTrue(noticeVM.notices.isEmpty, "Notices should be empty")
        XCTAssertFalse(noticeVM.hasUnreadNotices, "Should have no unread notices")
    }
    
    func testLoadNoticesFromSwiftData_WhenHasData_LoadsCorrectly() {
        // Given
        let notice1 = Notice(id: "1", title: "First", noticeDate: Date(), isRead: false)
        let notice2 = Notice(id: "2", title: "Second", noticeDate: Date().addingTimeInterval(-100), isRead: true)
        
        dataSource = MockNoticesDataSource(notices: [notice1, notice2])
        noticeVM = NoticeViewModel(
            dataSource: dataSource,
            networkService: networkService
        )
        
        // When
        noticeVM.loadNoticesFromSwiftData()
        noticeVM.updateUnreadStatus()
        
        // Then
        XCTAssertEqual(noticeVM.notices.count, 2, "Should load 2 notices")
        XCTAssertTrue(noticeVM.hasUnreadNotices, "Should have unread notices")
        // Проверяем сортировку по дате (сначала новые)
        XCTAssertEqual(noticeVM.notices.first?.id, "1", "First notice should be the newest")
    }
    
    // MARK: - Add Notice Tests
    
    func testAddNotice_WhenNewNotice_AddsSuccessfully() {
        // Given
        let newNotice = Notice(id: "new-1", title: "New Notice", isRead: false)
        
        // When
        noticeVM.addNotice(newNotice)
        
        // Then
        XCTAssertEqual(noticeVM.notices.count, 1, "Should have 1 notice")
        XCTAssertEqual(noticeVM.notices.first?.id, "new-1")
        XCTAssertTrue(noticeVM.hasUnreadNotices, "Should have unread notices")
    }
    
    func testAddNotice_WhenDuplicateID_DoesNotAdd() {
        // Given
        let notice1 = Notice(id: "same-id", title: "First", isRead: false)
        let notice2 = Notice(id: "same-id", title: "Duplicate", isRead: false)
        
        // When
        noticeVM.addNotice(notice1)
        noticeVM.addNotice(notice2)
        
        // Then
        XCTAssertEqual(noticeVM.notices.count, 1, "Should not add duplicate")
        XCTAssertEqual(noticeVM.notices.first?.title, "First", "Should keep first notice")
    }
    
    // MARK: - Delete Notice Tests
    
    func testDeleteNotice_WhenValidNotice_DeletesSuccessfully() {
        // Given
        let notice = Notice(id: "to-delete", title: "Delete Me")
        noticeVM.addNotice(notice)
        XCTAssertEqual(noticeVM.notices.count, 1)
        
        // When
        noticeVM.deleteNotice(notice: notice)
        
        // Then
        XCTAssertTrue(noticeVM.notices.isEmpty, "Notice should be deleted")
    }
    
    func testDeleteNotice_WhenNilNotice_ShowsError() {
        // When
        noticeVM.deleteNotice(notice: nil)
        
        // Then
        XCTAssertNotNil(noticeVM.errorMessage, "Should set error message")
        XCTAssertTrue(noticeVM.showErrorMessageAlert, "Should show error alert")
    }
    
    // MARK: - Mark as Read Tests
    
    func testMarkAsRead_WhenValidID_MarksSuccessfully() {
        // Given
        let notice = Notice(id: "unread", title: "Unread Notice", isRead: false)
        noticeVM.addNotice(notice)
        XCTAssertTrue(noticeVM.hasUnreadNotices)
        
        // When
        noticeVM.markAsRead(noticeId: "unread")
        
        // Then
        XCTAssertTrue(notice.isRead, "Notice should be marked as read")
        XCTAssertFalse(noticeVM.hasUnreadNotices, "Should have no unread notices")
    }
    
    func testMarkAsRead_WhenInvalidID_ShowsError() {
        // When
        noticeVM.markAsRead(noticeId: "non-existent")
        
        // Then
        XCTAssertNotNil(noticeVM.errorMessage, "Should set error message")
        XCTAssertTrue(noticeVM.showErrorMessageAlert, "Should show error alert")
    }
    
    func testMarkAsRead_WhenAlreadyRead_DoesNothing() {
        // Given
        let notice = Notice(id: "read", title: "Already Read", isRead: true)
        noticeVM.addNotice(notice)
        
        // When
        noticeVM.markAsRead(noticeId: "read")
        
        // Then
        XCTAssertTrue(notice.isRead, "Should remain read")
    }
    
    // MARK: - Toggle Read Status Tests
    
    func testIsReadToggle_WhenValidNotice_TogglesSuccessfully() {
        // Given
        let notice = Notice(id: "toggle", title: "Toggle Me", isRead: false)
        noticeVM.addNotice(notice)
        
        // When
        noticeVM.isReadToggle(notice: notice)
        
        // Then
        XCTAssertTrue(notice.isRead, "Should toggle to read")
        
        // When (toggle again)
        noticeVM.isReadToggle(notice: notice)
        
        // Then
        XCTAssertFalse(notice.isRead, "Should toggle back to unread")
    }
    
    func testIsReadToggle_WhenNilNotice_ShowsError() {
        // When
        noticeVM.isReadToggle(notice: nil)
        
        // Then
        XCTAssertNotNil(noticeVM.errorMessage, "Should set error message")
        XCTAssertTrue(noticeVM.showErrorMessageAlert, "Should show error alert")
    }
    
    // MARK: - Mark All as Read Tests
    
    func testMarkAllAsRead_WhenMultipleUnread_MarksAllSuccessfully() {
        // Given
        let notice1 = Notice(id: "1", title: "Unread 1", isRead: false)
        let notice2 = Notice(id: "2", title: "Unread 2", isRead: false)
        let notice3 = Notice(id: "3", title: "Read", isRead: true)
        
        noticeVM.addNotice(notice1)
        noticeVM.addNotice(notice2)
        noticeVM.addNotice(notice3)
        
        XCTAssertTrue(noticeVM.hasUnreadNotices)
        
        // When
        noticeVM.markAllAsRead()
        
        // Then
        XCTAssertTrue(notice1.isRead, "Notice 1 should be read")
        XCTAssertTrue(notice2.isRead, "Notice 2 should be read")
        XCTAssertTrue(notice3.isRead, "Notice 3 should remain read")
        XCTAssertFalse(noticeVM.hasUnreadNotices, "Should have no unread notices")
    }
    
    // MARK: - Update Unread Status Tests
    
    func testUpdateUnreadStatus_WhenHasUnread_SetsTrue() {
        // Given
        let unreadNotice = Notice(id: "unread", isRead: false)
        noticeVM.addNotice(unreadNotice)
        
        // When
        noticeVM.updateUnreadStatus()
        
        // Then
        XCTAssertTrue(noticeVM.hasUnreadNotices, "Should have unread notices")
    }
    
    func testUpdateUnreadStatus_WhenAllRead_SetsFalse() {
        // Given
        let readNotice = Notice(id: "read", isRead: true)
        noticeVM.addNotice(readNotice)
        
        // When
        noticeVM.updateUnreadStatus()
        
        // Then
        XCTAssertFalse(noticeVM.hasUnreadNotices, "Should have no unread notices")
    }
    
    // MARK: - Network Tests
    
    func testImportNoticesFromCloud_WhenNewNotices_ImportsSuccessfully() async throws {
        print("\n🧪 === TEST START: testImportNoticesFromCloud_WhenNewNotices_ImportsSuccessfully ===")
        // Given
        let mockNotices = [
            CodableNotice.mock(id: "cloud-1", title: "Cloud Notice 1", isRead: false),
            CodableNotice.mock(id: "cloud-2", title: "Cloud Notice 2", isRead: false)
        ]
        
        print("📋 Created \(mockNotices.count) mock CodableNotices:")
        for notice in mockNotices {
            print("   - id: \(notice.id), title: \(notice.title)")
        }

        let mockNetwork = MockNetworkService.mockNotices(mockNotices)
        let testVM = NoticeViewModel(
            dataSource: MockNoticesDataSource(notices: []),
            networkService: mockNetwork
        )
        print("\n📊 Initial state:")
        print("   notices.count: \(testVM.notices.count)")
        print("   hasUnreadNotices: \(testVM.hasUnreadNotices)")
        
        // When
        print("\n🔄 Calling importNoticesFromCloud()...")
        await testVM.importNoticesFromCloud()
        
        print("\n📊 After import:")
        print("   notices.count: \(testVM.notices.count)")
        print("   hasUnreadNotices: \(testVM.hasUnreadNotices)")
        print("   fetchCallCount: \(mockNetwork.fetchCallCount)")
        print("   errorMessage: \(testVM.errorMessage ?? "nil")")
        print("   showErrorMessageAlert: \(testVM.showErrorMessageAlert)")
        
        if !testVM.notices.isEmpty {
            print("\n📝 Imported notices:")
            for notice in testVM.notices {
                print("   - id: \(notice.id), title: \(notice.title), isRead: \(notice.isRead)")
            }
        }

        // Небольшая задержка для обновления UI
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        print("🧪 Test Debug:")
        print("   notices.count: \(testVM.notices.count)")
        print("   hasUnreadNotices: \(testVM.hasUnreadNotices)")
        print("   fetchCallCount: \(mockNetwork.fetchCallCount)")
        print("   errorMessage: \(testVM.errorMessage ?? "nil")")
        
        XCTAssertEqual(testVM.notices.count, 2, "Should import 2 notices")
        XCTAssertTrue(testVM.hasUnreadNotices, "Should have unread notices")
        XCTAssertEqual(mockNetwork.fetchCallCount, 1)
    }
    
    func testImportNoticesFromCloud_WhenDuplicates_SkipsDuplicates() async {
        // Given
        let existingNotice = Notice(id: "existing", title: "Existing", isRead: true)
        let dataSource = MockNoticesDataSource(notices: [existingNotice])
        
        let mockNotices = [
            CodableNotice.mock(id: "existing", title: "Duplicate", isRead: false),
            CodableNotice.mock(id: "new", title: "New Notice", isRead: false)
        ]
        
        let mockNetwork = MockNetworkService.mockNotices(mockNotices)
        let testVM = NoticeViewModel(
            dataSource: dataSource,
            networkService: mockNetwork
        )
        
        // When
        await testVM.importNoticesFromCloud()
        
        // Then
        XCTAssertEqual(testVM.notices.count, 2, "Should add only new notice")
        let existingInArray = testVM.notices.first { $0.id == "existing" }
        XCTAssertEqual(existingInArray?.title, "Existing", "Should keep original")
    }
    
    func testImportNoticesFromCloud_WhenNetworkError_ShowsError() async {
        // Given
        let mockNetwork = MockNetworkService.mockError()
        let testVM = NoticeViewModel(
            dataSource: MockNoticesDataSource(notices: []),
            networkService: mockNetwork
        )
        
        // When
        await testVM.importNoticesFromCloud()
        
        // Then
        XCTAssertNotNil(testVM.errorMessage, "Should set error message")
        XCTAssertTrue(testVM.showErrorMessageAlert, "Should show error alert")
        XCTAssertEqual(testVM.notices.count, 0, "Should not add any notices")
    }
    
    func testImportNoticesFromCloud_WithDelay_HandlesCorrectly() async throws {
        // Given
        let mockNotices = [
            CodableNotice.mockUnread,
            CodableNotice.mockRead
        ]
        
        let mockNetwork = MockNetworkService.mockWithDelay(mockNotices, delay: 0.5)
        let testVM = NoticeViewModel(
            dataSource: MockNoticesDataSource(notices: []),
            networkService: mockNetwork
        )
        
        // When
        let start = Date()
        await testVM.importNoticesFromCloud()
        let duration = Date().timeIntervalSince(start)
        
        // Then
        XCTAssertGreaterThan(duration, 0.5, "Should wait for network delay")
        XCTAssertEqual(testVM.notices.count, 2)
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceLoadNotices_With100Items() {
        // Given: создаем 100 уведомлений
        var notices: [Notice] = []
        for i in 0..<100 {
            let notice = Notice(
                id: "perf-\(i)",
                title: "Notice \(i)",
                noticeDate: Date().addingTimeInterval(Double(-i * 1000)),
                isRead: i % 2 == 0
            )
            notices.append(notice)
        }
        
        dataSource = MockNoticesDataSource(notices: notices)
        noticeVM = NoticeViewModel(
            dataSource: dataSource,
            networkService: networkService
        )
        
        // When/Then: измеряем производительность загрузки
        measure {
            noticeVM.loadNoticesFromSwiftData()
        }
    }
    
    func testPerformanceMarkAllAsRead_With100Items() {
        // Given
        for i in 0..<100 {
            let notice = Notice(id: "perf-\(i)", title: "Notice \(i)", isRead: false)
            noticeVM.addNotice(notice)
        }
        
        // When/Then
        measure {
            noticeVM.markAllAsRead()
        }
    }
    
    // MARK: - Edge Cases
    
    func testAddNotice_WhenEmpty_UpdatesUnreadStatus() {
        // Given
        XCTAssertFalse(noticeVM.hasUnreadNotices)
        
        // When
        let notice = Notice(id: "1", title: "First", isRead: false)
        noticeVM.addNotice(notice)
        
        // Then
        XCTAssertTrue(noticeVM.hasUnreadNotices)
    }
    
    func testDeleteLastNotice_UpdatesUnreadStatus() {
        // Given
        let notice = Notice(id: "last", title: "Last One", isRead: false)
        noticeVM.addNotice(notice)
        XCTAssertTrue(noticeVM.hasUnreadNotices)
        
        // When
        noticeVM.deleteNotice(notice: notice)
        
        // Then
        XCTAssertFalse(noticeVM.hasUnreadNotices)
    }
    
    func testMarkAllAsRead_WhenEmpty_DoesNotCrash() {
        // When/Then
        XCTAssertNoThrow(noticeVM.markAllAsRead())
        XCTAssertFalse(noticeVM.hasUnreadNotices)
    }
}
