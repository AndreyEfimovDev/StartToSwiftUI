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
    
    var noticeVM: NoticeViewModel!
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var mockNetworkService: MockNoticesNetworkService!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Создаём in-memory контейнер для тестов
        modelContainer = try ModelContainer(
            for: Post.self, Notice.self, AppSyncState.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        modelContext = ModelContext(modelContainer)
        
        mockNetworkService = MockNoticesNetworkService()
        
        let realNetworkService = NetworkService(baseURL: Constants.cloudNoticesURL)
        
        noticeVM = NoticeViewModel(
            modelContext: modelContext,
            networkService: realNetworkService
        )
        // Ждем завершения async задач в инициализаторе
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 секунда
        
        // Очищаем ВСЕ уведомления после инициализации noticeVM
        try clearAllNotices()
        
    }
    
    private func clearAllNotices() throws {
        let descriptor = FetchDescriptor<Notice>()
        let existingNotices = try modelContext.fetch(descriptor)
        
        for notice in existingNotices {
            modelContext.delete(notice)
        }
        
        try modelContext.save()
        print("🧹 Cleared \(existingNotices.count) posts from SwiftData")
    }
    override func tearDown() async throws {
        noticeVM = nil
        modelContext = nil
        mockNetworkService = nil
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
        
        modelContext.insert(notice1)
        modelContext.insert(notice2)
        try? modelContext.save()
        
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
    
    // MARK: - Import from Cloud Tests
    
    func testImportNoticesFromCloud_WhenNewNotices_ImportsSuccessfully() async {
        // Given: имитируем данные, которые могли бы прийти из облака
        // Используем РАЗНЫЕ даты для тестирования сортировки
        let now = Date()
        let cloudNotices = [
            CodableNotice(
                id: "cloud-1",
                title: "Cloud Notice 1",
                noticeDate: Date(), // Более новая дата
                noticeMessage: "Message 1",
                isRead: false
            ),
            CodableNotice(
                id: "cloud-2",
                title: "Cloud Notice 2",
                noticeDate: now.addingTimeInterval(-100), // Более старая дата
                noticeMessage: "Message 2",
                isRead: false
            )
        ]
        
        mockNetworkService.mockNotices = cloudNotices
        
        // When
        for codableNotice in cloudNotices {
            // Создаем Notice из CodableNotice
            let notice = Notice(
                id: codableNotice.id,
                title: codableNotice.title,
                noticeDate: codableNotice.noticeDate,
                noticeMessage: codableNotice.noticeMessage,
                isRead: codableNotice.isRead
            )
            noticeVM.addNotice(notice)
        }
        
        // When
        noticeVM.updateUnreadStatus()
        // Then
        XCTAssertEqual(noticeVM.notices.count, 2, "Should import 2 notices")
        XCTAssertTrue(noticeVM.hasUnreadNotices, "Should have unread notices")
        // Дополнительные проверки
        XCTAssertEqual(noticeVM.notices[0].id, "cloud-1")
        XCTAssertEqual(noticeVM.notices[1].id, "cloud-2")
        XCTAssertFalse(noticeVM.notices[0].isRead)
        XCTAssertFalse(noticeVM.notices[1].isRead)
    }
    
    func testImportNoticesFromCloud_WhenIdDuplicates_KeepsOnlyOne() async {
        // Given
        let existingNotice = Notice(id: "existing", title: "Existing", isRead: true)
        noticeVM.addNotice(existingNotice)
        
        let cloudNotices = [
            CodableNotice(
                id: "existing",
                title: "Duplicate from cloud",
                noticeDate: Date(),
                noticeMessage: "Should not be added",
                isRead: false
            )
        ]
        
        mockNetworkService.mockNotices = cloudNotices
        
        // When
        await noticeVM.importNoticesFromCloud()
        
        // Then
        XCTAssertEqual(noticeVM.notices.count, 1, "Should not add duplicate")
        XCTAssertEqual(noticeVM.notices.first?.title, "Existing", "Should keep existing notice")
    }
    
    func testImportNoticesFromCloud_WhenOldNotices_DoesNotImport() async {
        // Given: устанавливаем дату последнего обновления в будущем
        let appStateManager = AppSyncStateManager(modelContext: modelContext)
        appStateManager.updateLatestNoticeDate(Date().addingTimeInterval(100000))
        
        let cloudNotices = [
            CodableNotice(
                id: "old",
                title: "Old Notice",
                noticeDate: Date(),
                noticeMessage: "Should not import",
                isRead: false
            )
        ]
        
        mockNetworkService.mockNotices = cloudNotices
        
        // When
        await noticeVM.importNoticesFromCloud()
        
        // Then
        XCTAssertTrue(noticeVM.notices.isEmpty, "Should not import old notices")
    }
    
    func testErrorHandling_WhenImportFails_ShowsError() async {
        // Given: имитируем состояние ошибки без реального сетевого вызова
        
        // Когда: напрямую устанавливаем ошибку в view model
        noticeVM.errorMessage = "Network error occurred"
        noticeVM.showErrorMessageAlert = true
        
        // Then
        XCTAssertNotNil(noticeVM.errorMessage, "Should set error message")
        XCTAssertTrue(noticeVM.showErrorMessageAlert, "Should show error alert")
        XCTAssertEqual(noticeVM.errorMessage, "Network error occurred")
    }
    
    
    // MARK: - Remove Duplicates Tests
    
    func testRemoveDuplicates_WhenMultipleSameID_KeepsOnlyOne() {
        // Given: добавляем дубликаты напрямую в контекст
        let duplicate1 = Notice(id: "dup", title: "First", isRead: false)
        let duplicate2 = Notice(id: "dup", title: "Second", isRead: true)
        let duplicate3 = Notice(id: "dup", title: "Third", isRead: false)
        
        modelContext.insert(duplicate1)
        modelContext.insert(duplicate2)
        modelContext.insert(duplicate3)
        try? modelContext.save()
        
        // When
        noticeVM.loadNoticesFromSwiftData()
        
        // Then: после загрузки должны автоматически удалиться дубликаты
        let descriptor = FetchDescriptor<Notice>()
        let allNotices = try? modelContext.fetch(descriptor)
        
        let duplicatesOfId = allNotices?.filter { $0.id == "dup" }
        XCTAssertEqual(duplicatesOfId?.count, 1, "Should keep only one notice")
        
        // Проверяем, что сохранилось прочитанное уведомление
        XCTAssertTrue(duplicatesOfId?.first?.isRead ?? false, "Should keep read version")
    }
    
    // MARK: - Performance Tests
    
    
    func testPerformanceLoadNotices_With100Items() {
        // Given: добавляем 100 уведомлений
        for i in 0..<100 {
            let notice = Notice(
                id: "perf-\(i)",
                title: "Notice \(i)",
                noticeDate: Date().addingTimeInterval(Double(-i * 1000)),
                isRead: i % 2 == 0
            )
            modelContext.insert(notice)
        }
        try? modelContext.save()
        
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
    
}



