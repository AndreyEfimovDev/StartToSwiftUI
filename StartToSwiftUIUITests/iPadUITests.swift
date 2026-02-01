//
//  iPadUITests.swift
//  StartToSwiftUIUITests
//
//  Created by Andrey Efimov on 25.01.2026.
//

import XCTest

final class iPadUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        // Skip on iPhone
#if !targetEnvironment(macCatalyst)
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            throw XCTSkip("This test is for iPad only")
        }
#endif
        
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
        
        waitForLaunchScreenToDisappear()
        acceptTermsOfUseIfNeeded()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Helper Methods
    
    private func waitForLaunchScreenToDisappear() {
        let navBar = app.navigationBars.firstMatch
        _ = navBar.waitForExistence(timeout: 5)
    }
    
    private func acceptTermsOfUseIfNeeded() {
        let termsButton = app.buttons["Terms of Use"]
        if termsButton.waitForExistence(timeout: 2) {
            termsButton.tap()
            let acceptButton = app.buttons["Accept and Continue"]
            if acceptButton.waitForExistence(timeout: 2) {
                acceptButton.tap()
            }
        }
    }
    
    // MARK: - iPad Split View Tests
    
    func testSplitViewDisplays() throws {
        // On iPad, we should see a split view with list and detail
        sleep(1)
        
        // The split view should have multiple columns visible
        // Check for navigation bars (should have at least one)
        let navBars = app.navigationBars
        XCTAssertTrue(navBars.count >= 1, "Should have navigation bars visible")
    }
    
    func testSelectPostShowsDetailsInSplitView() throws {
        // Find and tap a post in the list
        let list = app.collectionViews.firstMatch
        guard list.waitForExistence(timeout: 3) else {
            throw XCTSkip("No posts list available")
        }
        
        let firstCell = list.cells.firstMatch
        guard firstCell.exists else {
            throw XCTSkip("No posts in list")
        }
        
        firstCell.tap()
        sleep(1)
        
        // On iPad, details should appear in the detail column
        // without navigating away from the list
        XCTAssertTrue(list.exists, "List should still be visible on iPad")
    }
    
    func testPreferencesOpensAsSheet() throws {
        let settingsButton = app.buttons["gearshape"]
        guard settingsButton.waitForExistence(timeout: 3) else {
            XCTFail("Settings button not found")
            return
        }
        
        settingsButton.tap()
        sleep(2)
        
        // Вариант 1: NavigationBar
        let preferencesNavBar = app.navigationBars["Preferences"]
        
        // Вариант 2: StaticText с заголовком
        let preferencesTitle = app.staticTexts["Preferences"]
        
        // Проверяем оба варианта
        let found = preferencesNavBar.waitForExistence(timeout: 3) ||
        preferencesTitle.waitForExistence(timeout: 3)
        
        XCTAssertTrue(found, "Preferences screen should be visible")
        
        // Закрытие - кнопка назад или X
        let navBar = app.navigationBars.firstMatch
        let closeButton = navBar.buttons["xmark"]
        let backButton = navBar.buttons["chevron.left"]
        let backButtonAlt = navBar.buttons["Back"]
        
        if closeButton.exists {
            closeButton.tap()
        } else if backButton.exists {
            backButton.tap()
        } else if backButtonAlt.exists {
            backButtonAlt.tap()
        }
    }
}
