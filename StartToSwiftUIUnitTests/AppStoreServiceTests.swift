//
//  AppStoreServiceTests.swift
//  StartToSwiftUIUnitTests
//
//  Created by Andrey Efimov on 23.09.2026.
//

import XCTest
@testable import StartToSwiftUI

final class AppStoreServiceTests: XCTestCase {

    func testIsNewerVersionHandlesMultiDigitComponents() {
        // Given/When/Then — баг, который эти тесты чинят: лексикографическое
        // сравнение строк даёт "10.0" < "9.0", хотя семантически 10.0 новее.
        XCTAssertTrue(AppStoreService.isNewerVersion("10.0", than: "9.0"))
        XCTAssertTrue(AppStoreService.isNewerVersion("1.10.0", than: "1.8.0"))
        XCTAssertTrue(AppStoreService.isNewerVersion("9.10", than: "9.9"))
    }

    func testIsNewerVersionEqualVersionsAreNotNewer() {
        XCTAssertFalse(AppStoreService.isNewerVersion("1.8.0", than: "1.8.0"))
    }

    func testIsNewerVersionOlderVersionIsNotNewer() {
        XCTAssertFalse(AppStoreService.isNewerVersion("1.8.0", than: "1.9.0"))
        XCTAssertFalse(AppStoreService.isNewerVersion("9.0", than: "10.0"))
    }

    func testIsNewerVersionDifferentComponentCounts() {
        // "1.8.0" считается новее "1.8" — точный префикс короче, значит старее.
        XCTAssertTrue(AppStoreService.isNewerVersion("1.8.0", than: "1.8"))
        XCTAssertFalse(AppStoreService.isNewerVersion("1.8", than: "1.8.0"))
    }
}
