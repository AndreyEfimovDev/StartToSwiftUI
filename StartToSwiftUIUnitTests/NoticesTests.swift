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
    var noticeVM: NoticesViewModel!
    
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
        noticeVM = NoticesViewModel(
            dataSource: dataSource,
            fbNoticesManager: networkService,
            services: .make()
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
        let testVM = NoticesViewModel(
            dataSource: MockNoticesDataSource(notices: []),
            fbNoticesManager: mockFB,
            services: .make()
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
        let testVM = NoticesViewModel(
            dataSource: dataSource,
            fbNoticesManager: mockFB,
            services: .make()
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
        let testVM = NoticesViewModel(
            dataSource: MockNoticesDataSource(notices: []),
            fbNoticesManager: mockFB,
            services: .make()
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
        
        let testVM = NoticesViewModel(
            dataSource: MockNoticesDataSource(notices: []),
            fbNoticesManager: mockFB,
            services: .make()
        )
        
        // When
        let start = Date()
        await testVM.importNoticesFromFirebase()
        let duration = Date().timeIntervalSince(start)
        
        // Then
        XCTAssertGreaterThan(duration, 0.5)
        XCTAssertEqual(testVM.notices.count, 1)
    }

    // MARK: - Sync Date vs Save

    /// VM с моком состояния синка — чтобы видеть, сдвинута ли дата notices.
    private func makeSyncVM(notices: [FBNoticeModel], dataSource: MockNoticesDataSource) -> (NoticesViewModel, MockAppSyncStateManager) {
        let stateManager = MockAppSyncStateManager()
        let vm = NoticesViewModel(
            dataSource: dataSource,
            appStateManager: stateManager,
            fbNoticesManager: MockFBNoticesManager.mockNotices(notices),
            services: .make()
        )
        return (vm, stateManager)
    }

    func testImportNotices_WhenSaveFails_DoesNotAdvanceSyncDate() async {
        // Given — сохранение notices упадёт
        let failingDataSource = MockNoticesDataSource(notices: [])
        failingDataSource.shouldThrowOnSave = true
        let (vm, stateManager) = makeSyncVM(
            notices: [FBNoticeModel.mock(noticeId: "1", noticeDate: Date())],
            dataSource: failingDataSource
        )

        // When
        await vm.importNoticesFromFirebase()

        // Then — дата не сдвинута, вставка откатана — notices придут при следующем импорте
        XCTAssertNil(stateManager.savedLatestNoticeDate)
        XCTAssertEqual(failingDataSource.rollbackCallCount, 1)
    }

    /// Notice уже удалён — отметка "прочитано" не показывает пользователю алерт.
    func testMarkAsRead_MissingNotice_DoesNotShowAlert() {
        let services = AppServiceDependencies.make()
        let testVM = NoticesViewModel(
            dataSource: MockNoticesDataSource(notices: []),
            fbNoticesManager: MockFBNoticesManager.mockEmpty(),
            services: services
        )

        testVM.markAsRead("missing-id")

        XCTAssertNil(services.errorManager.current)
    }

    /// Удаление уже пропавшего notice (nil) не показывает алерт.
    func testDeleteErase_NilNotice_DoesNotShowAlert() {
        let services = AppServiceDependencies.make()
        let testVM = NoticesViewModel(
            dataSource: MockNoticesDataSource(notices: []),
            fbNoticesManager: MockFBNoticesManager.mockEmpty(),
            services: services
        )

        testVM.deleteErase(nil)

        XCTAssertNil(services.errorManager.current)
    }

    /// Отметка "прочитано" не запускает очистку дублей (она — только при
    /// запуске и импорте).
    func testToggleReadStatus_DoesNotRemoveDuplicates() {
        // Given
        let copyA = Notice(id: "dup", title: "Copy A", isRead: false)
        let copyB = Notice(id: "dup", title: "Copy B", isRead: false)
        let dataSource = MockNoticesDataSource(notices: [copyA, copyB])
        let testVM = NoticesViewModel(
            dataSource: dataSource,
            fbNoticesManager: MockFBNoticesManager.mockEmpty(),
            services: .make()
        )

        // When
        testVM.toggleReadStatus(copyA)

        // Then
        XCTAssertTrue(dataSource.deletedNotices.isEmpty)
        XCTAssertEqual(testVM.notices.count, 2)
    }

    /// Удаление notice удаляет только его, не трогая копии другого дубля.
    func testDeleteErase_DoesNotRemoveOtherDuplicates() {
        // Given
        let copyA = Notice(id: "dup", title: "Copy A")
        let copyB = Notice(id: "dup", title: "Copy B")
        let other = Notice(id: "other", title: "Other")
        let dataSource = MockNoticesDataSource(notices: [copyA, copyB, other])
        let testVM = NoticesViewModel(
            dataSource: dataSource,
            fbNoticesManager: MockFBNoticesManager.mockEmpty(),
            services: .make()
        )

        // When
        testVM.deleteErase(other)

        // Then
        XCTAssertEqual(dataSource.deletedNotices.count, 1)
        XCTAssertTrue(dataSource.deletedNotices.first === other)
        XCTAssertEqual(testVM.notices.count, 2)
    }

    /// Ошибка сохранения отметки "прочитано" откатывает изменения.
    func testToggleReadStatus_WhenSaveFails_RollsBack() {
        // Given
        let notice = Notice(id: "n1", title: "Notice", isRead: false)
        let failingDataSource = MockNoticesDataSource(notices: [notice])
        failingDataSource.shouldThrowOnSave = true
        let testVM = NoticesViewModel(
            dataSource: failingDataSource,
            fbNoticesManager: MockFBNoticesManager.mockEmpty(),
            services: .make()
        )

        // When
        testVM.toggleReadStatus(notice)

        // Then
        XCTAssertEqual(failingDataSource.rollbackCallCount, 1)
    }

    func testImportNotices_WhenSaveSucceeds_AdvancesSyncDateToLatestNotice() async {
        // Given
        let earlier = Date().addingTimeInterval(60)
        let latest = Date().addingTimeInterval(120)
        let (vm, stateManager) = makeSyncVM(
            notices: [
                FBNoticeModel.mock(noticeId: "1", noticeDate: earlier),
                FBNoticeModel.mock(noticeId: "2", noticeDate: latest)
            ],
            dataSource: MockNoticesDataSource(notices: [])
        )

        // When
        await vm.importNoticesFromFirebase()

        // Then
        XCTAssertEqual(stateManager.savedLatestNoticeDate, latest)
    }

    // MARK: - Cloud Changes

    /// Изменение хранилища перезагружает notices — без очистки дублей,
    /// по той же причине, что у постов.
    func testStoreChange_ReloadsNoticesWithoutRemovingDuplicates() {
        // Given
        let dataSource = MockNoticesDataSource(notices: [
            Notice(id: "dup", title: "Copy A"),
            Notice(id: "dup", title: "Copy B")
        ])
        let observer = MockCloudChangeObserver()
        let testVM = NoticesViewModel(
            dataSource: dataSource,
            fbNoticesManager: MockFBNoticesManager.mockEmpty(),
            cloudChangeObserver: observer,
            services: .make()
        )
        testVM.start()

        // When
        observer.sendChange([.notice])

        // Then
        XCTAssertEqual(testVM.notices.count, 2)
        XCTAssertTrue(dataSource.deletedNotices.isEmpty)
    }

    /// Изменения других сущностей notices не перезагружают.
    func testStoreChange_OfOtherEntity_DoesNotReloadNotices() {
        // Given
        let dataSource = MockNoticesDataSource(notices: [Notice(id: "n1", title: "Notice")])
        let observer = MockCloudChangeObserver()
        let testVM = NoticesViewModel(
            dataSource: dataSource,
            fbNoticesManager: MockFBNoticesManager.mockEmpty(),
            cloudChangeObserver: observer,
            services: .make()
        )
        testVM.start()

        // When
        observer.sendChange([.post, .appSyncState])

        // Then
        XCTAssertTrue(testVM.notices.isEmpty)
    }

    // MARK: - Remove Duplicates

    /// Дубли по id убираются через протокол источника (раньше — только для
    /// SwiftData): остаётся одна копия, причём прочитанная.
    func testLoadNotices_RemovesDuplicateNotices_KeepsReadCopy() {
        // Given
        let unreadCopy = Notice(id: "dup", title: "Unread copy", isRead: false)
        let readCopy = Notice(id: "dup", title: "Read copy", isRead: true)
        let other = Notice(id: "other", title: "Other", isRead: false)
        let dataSource = MockNoticesDataSource(notices: [unreadCopy, readCopy, other])
        let testVM = NoticesViewModel(
            dataSource: dataSource,
            fbNoticesManager: MockFBNoticesManager.mockEmpty(),
            services: .make()
        )

        // When
        testVM.loadNoticesFromSwiftData()

        // Then
        XCTAssertEqual(testVM.notices.count, 2)
        let kept = testVM.notices.filter { $0.id == "dup" }
        XCTAssertEqual(kept.count, 1)
        XCTAssertTrue(kept.first?.isRead ?? false)
        XCTAssertTrue(dataSource.deletedNotices.contains { $0 === unreadCopy })
    }
}
