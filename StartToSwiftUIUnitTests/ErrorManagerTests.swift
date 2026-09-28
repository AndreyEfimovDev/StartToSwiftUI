//
//  ErrorManagerTests.swift
//  StartToSwiftUIUnitTests
//
//  Created by Andrey Efimov on 18.09.2026.
//

import XCTest
@testable import StartToSwiftUI

private struct SampleError: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}

@MainActor
final class ErrorManagerTests: XCTestCase {

    var sut: ErrorManager!

    override func setUp() {
        super.setUp()
        sut = ErrorManager()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Basic show/dismiss

    func test_handle_firstError_showsImmediately() {
        sut.handle(message: "Something went wrong")

        XCTAssertEqual(sut.current, DisplayableError(title: "Error", message: "Something went wrong"))
    }

    /// С исходной ошибкой: заголовок — контекст операции, текст — описание ошибки.
    func test_handle_withError_contextIsTitleAndDescriptionIsMessage() {
        sut.handle(SampleError(message: "Network unreachable"), message: "Failed to load posts")

        XCTAssertEqual(sut.current, DisplayableError(title: "Failed to load posts", message: "Network unreachable"))
    }

    func test_dismissCurrent_leavesNothingToShow() {
        sut.handle(message: "Oops")
        sut.dismissCurrent()

        XCTAssertNil(sut.current)
    }

    // MARK: - Queue: second error while one is showing

    func test_handle_secondErrorWhileShowing_doesNotOverwriteCurrent() {
        sut.handle(message: "First")
        sut.handle(message: "Second")

        // Первая ошибка не должна молча замениться второй, пока пользователь её не закрыл.
        XCTAssertEqual(sut.current?.message, "First")
    }

    func test_dismissCurrent_afterTwoQueuedErrors_showsNextFromQueue() {
        sut.handle(message: "First")
        sut.handle(message: "Second")

        sut.dismissCurrent()

        XCTAssertEqual(sut.current?.message, "Second")
    }

    func test_dismissCurrent_afterAllQueuedErrorsShown_leavesNothingToShow() {
        sut.handle(message: "First")
        sut.handle(message: "Second")

        sut.dismissCurrent() // показывает "Second"
        sut.dismissCurrent() // очередь пуста

        XCTAssertNil(sut.current)
    }

    func test_multipleQueuedErrors_drainInFIFOOrder() {
        sut.handle(message: "First")
        sut.handle(message: "Second")
        sut.handle(message: "Third")

        sut.dismissCurrent() // First → Second
        XCTAssertEqual(sut.current?.message, "Second")

        sut.dismissCurrent() // Second → Third
        XCTAssertEqual(sut.current?.message, "Third")
    }

    // MARK: - Dedup

    func test_handle_sameErrorWhileCurrentlyShowing_isNotQueuedTwice() {
        sut.handle(message: "Duplicate")
        sut.handle(message: "Duplicate") // та же ошибка, пока первая ещё на экране

        sut.dismissCurrent()

        // Если бы дедупа не было, здесь показалась бы вторая "Duplicate".
        XCTAssertNil(sut.current)
    }

    func test_handle_sameErrorAlreadyInQueue_isNotQueuedTwice() {
        sut.handle(message: "First")
        sut.handle(message: "Duplicate")
        sut.handle(message: "Duplicate") // уже в очереди — не должно продублироваться

        sut.dismissCurrent() // First → Duplicate
        XCTAssertEqual(sut.current?.message, "Duplicate")

        sut.dismissCurrent() // очередь должна быть пуста
        XCTAssertNil(sut.current)
    }

    /// Одинаковое описание, но разный контекст — это разные ошибки.
    func test_handle_sameDescriptionDifferentContext_isQueued() {
        sut.handle(SampleError(message: "Offline"), message: "Failed to load posts")
        sut.handle(SampleError(message: "Offline"), message: "Failed to load notices")

        sut.dismissCurrent()

        XCTAssertEqual(sut.current?.title, "Failed to load notices")
    }

    // MARK: - userMessage(for:)

    func test_userMessage_cocoaOutOfSpace_suggestsFreeingSpace() {
        let error = NSError(domain: NSCocoaErrorDomain, code: NSFileWriteOutOfSpaceError)

        XCTAssertEqual(
            ErrorManager.userMessage(for: error),
            "Not enough storage on the device. Free up some space and try again."
        )
    }

    func test_userMessage_sqliteFull_suggestsFreeingSpace() {
        let error = NSError(domain: "NSSQLiteErrorDomain", code: 13)

        XCTAssertEqual(
            ErrorManager.userMessage(for: error),
            "Not enough storage on the device. Free up some space and try again."
        )
    }

    /// Нехватка места, завёрнутая в другую ошибку (как это может сделать SwiftData).
    func test_userMessage_nestedOutOfSpace_suggestsFreeingSpace() {
        let sqliteFull = NSError(domain: "NSSQLiteErrorDomain", code: 13)
        let wrapper = NSError(domain: NSCocoaErrorDomain, code: 134030, userInfo: [NSUnderlyingErrorKey: sqliteFull])

        XCTAssertEqual(
            ErrorManager.userMessage(for: wrapper),
            "Not enough storage on the device. Free up some space and try again."
        )
    }

    func test_userMessage_otherError_usesLocalizedDescription() {
        XCTAssertEqual(ErrorManager.userMessage(for: SampleError(message: "Network unreachable")), "Network unreachable")
    }
}
