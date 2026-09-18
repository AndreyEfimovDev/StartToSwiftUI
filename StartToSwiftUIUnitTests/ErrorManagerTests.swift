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

    // MARK: - Basic show/clear

    func test_handle_firstError_showsImmediately() {
        sut.handle(message: "Something went wrong")

        XCTAssertTrue(sut.showAlert)
        XCTAssertEqual(sut.errorMessage, "Something went wrong")
    }

    func test_handle_withError_usesLocalizedDescription() {
        sut.handle(SampleError(message: "Network unreachable"), message: "Fallback text")

        XCTAssertEqual(sut.errorMessage, "Network unreachable")
    }

    func test_clear_resetsMessageAndAlert() {
        sut.handle(message: "Oops")
        sut.clear()

        XCTAssertFalse(sut.showAlert)
        XCTAssertNil(sut.errorMessage)
    }

    // MARK: - Queue: second error while one is showing

    func test_handle_secondErrorWhileShowing_doesNotOverwriteCurrent() {
        sut.handle(message: "First")
        sut.handle(message: "Second")

        // Первая ошибка не должна молча замениться второй, пока пользователь её не закрыл.
        XCTAssertEqual(sut.errorMessage, "First")
        XCTAssertTrue(sut.showAlert)
    }

    func test_clear_afterTwoQueuedErrors_showsNextFromQueue() {
        sut.handle(message: "First")
        sut.handle(message: "Second")

        sut.clear()

        XCTAssertEqual(sut.errorMessage, "Second")
        XCTAssertTrue(sut.showAlert)
    }

    func test_clear_afterAllQueuedErrorsShown_leavesNothingToShow() {
        sut.handle(message: "First")
        sut.handle(message: "Second")

        sut.clear() // показывает "Second"
        sut.clear() // очередь пуста

        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.showAlert)
    }

    func test_multipleQueuedErrors_drainInFIFOOrder() {
        sut.handle(message: "First")
        sut.handle(message: "Second")
        sut.handle(message: "Third")

        sut.clear() // First → Second
        XCTAssertEqual(sut.errorMessage, "Second")

        sut.clear() // Second → Third
        XCTAssertEqual(sut.errorMessage, "Third")
    }

    // MARK: - Dedup

    func test_handle_sameMessageWhileCurrentlyShowing_isNotQueuedTwice() {
        sut.handle(message: "Duplicate")
        sut.handle(message: "Duplicate") // тот же текст, пока первый ещё на экране

        sut.clear()

        // Если бы дедупа не было, здесь показался бы второй "Duplicate".
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.showAlert)
    }

    func test_handle_sameMessageAlreadyInQueue_isNotQueuedTwice() {
        sut.handle(message: "First")
        sut.handle(message: "Duplicate")
        sut.handle(message: "Duplicate") // уже в очереди — не должно продублироваться

        sut.clear() // First → Duplicate
        XCTAssertEqual(sut.errorMessage, "Duplicate")

        sut.clear() // очередь должна быть пуста
        XCTAssertNil(sut.errorMessage)
    }

    // Показывающийся simultaneously через isPresented-биндинг SwiftUI выставляет
    // showAlert = false напрямую (не через clear()) — didSet должен вести себя так же.
    func test_showAlertSetToFalseDirectly_behavesLikeClear() {
        sut.handle(message: "First")
        sut.handle(message: "Second")

        sut.showAlert = false

        XCTAssertEqual(sut.errorMessage, "Second")
        XCTAssertTrue(sut.showAlert)
    }
}
