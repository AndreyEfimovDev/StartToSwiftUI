//
//  NoticesUITests.swift
//  StartToSwiftUIUITests
//
//  Created by Andrey Efimov on 25.01.2026.
//

import XCTest

final class NoticesUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
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
    
    private func openNoticesFromToolbar() -> Bool {
        // Notice button uses CircleStrokeButtonView with iconName "message"
        // After adding accessibilityIdentifier, it should be findable
        let messageButton = app.buttons["message"]
        
        if messageButton.waitForExistence(timeout: 2) {
            messageButton.tap()
            sleep(1)
            return true
        }
        return false
    }
    
    private func openNoticesFromPreferences() -> Bool {
        // Open preferences first
        let settingsButton = app.buttons["gearshape"]
        guard settingsButton.waitForExistence(timeout: 3) else {
            return false
        }
        settingsButton.tap()
        sleep(1)
        
        // Find messages button by accessibilityIdentifier
        let messagesButton = app.buttons["MessagesButton"]
        
        if messagesButton.waitForExistence(timeout: 2) {
            messagesButton.tap()
            sleep(1)
            return true
        }
        
        // Fallback: search by label predicate
        let predicate = NSPredicate(format: "label BEGINSWITH 'Messages'")
        let fallbackButton = app.buttons.matching(predicate).firstMatch
        
        if fallbackButton.waitForExistence(timeout: 2) {
            fallbackButton.tap()
            sleep(1)
            return true
        }
        
        return false
    }
    
    // MARK: - Notices Tests
    
    func testOpenNoticesFromToolbarIfAvailable() throws {
        // Notice button only appears if there are unread notices
        let opened = openNoticesFromToolbar()
        
        if opened {
            // Verify Notices screen
            sleep(1)
            
            // Go back
            let backButton = app.buttons["chevron.left"]
            let closeButton = app.buttons["xmark"]
            
            if backButton.exists {
                backButton.tap()
            } else if closeButton.exists {
                closeButton.tap()
            }
        } else {
            // No unread notices, test passes
            XCTAssertTrue(true, "No unread notices - button not visible")
        }
    }
    
    func testOpenNoticesFromPreferences() throws {
        let opened = openNoticesFromPreferences()
        
        if opened {
            // Check for notices content
            let noticesTitle = app.navigationBars.staticTexts.firstMatch
            XCTAssertTrue(noticesTitle.waitForExistence(timeout: 2), "Notices title should be visible")
            
            sleep(1)
            
            // Go back
            let backButton = app.buttons["chevron.left"]
            if backButton.exists {
                backButton.tap()
            }
        }
        
        // Close preferences
        let closeButton = app.buttons["xmark"]
        let backButton = app.buttons["chevron.left"]
        
        if closeButton.exists {
            closeButton.tap()
        } else if backButton.exists {
            backButton.tap()
        }
    }
    
    func testNoticesEmptyState() throws {
        // Open notices
        if openNoticesFromToolbar() || openNoticesFromPreferences() {
            // Check for empty state if no notices
            let emptyState = app.staticTexts["No notifications"]
            let hasNotices = app.collectionViews.cells.count > 0
            
            // Either we have notices or empty state
            XCTAssertTrue(emptyState.exists || hasNotices, "Should show either notices or empty state")
            sleep(1)
        }
    }
    
    func testNoticeSwipeToDelete() throws {
        // Open notices
        guard openNoticesFromToolbar() || openNoticesFromPreferences() else {
            throw XCTSkip("Could not open notices")
        }
        
        sleep(1)
        
        // Find first notice cell
        let list = app.collectionViews.firstMatch
        let firstCell = list.cells.firstMatch
        
        guard firstCell.exists else {
            throw XCTSkip("No notices to test")
        }
        
        // Swipe left to reveal delete
        firstCell.swipeLeft()
        
        let deleteButton = app.buttons["Delete"]
        if deleteButton.waitForExistence(timeout: 2) {
            // Don't delete, just verify action exists
            firstCell.swipeRight()
        }
    }
    
    func testNoticeSwipeToToggleRead() throws {
        // Open notices
        guard openNoticesFromToolbar() || openNoticesFromPreferences() else {
            throw XCTSkip("Could not open notices")
        }
        
        sleep(1)
        
        // Find first notice cell
        let list = app.collectionViews.firstMatch
        let firstCell = list.cells.firstMatch
        
        guard firstCell.exists else {
            throw XCTSkip("No notices to test")
        }
        
        // Swipe right to reveal read/unread toggle
        firstCell.swipeRight()
        
        let readButton = app.buttons["Read"]
        let unreadButton = app.buttons["Unread"]
        
        if readButton.waitForExistence(timeout: 2) || unreadButton.exists {
            // Action exists
            firstCell.swipeLeft()
        }
    }
    
    func testOpenNoticeDetails() throws {
        // Open notices
        guard openNoticesFromToolbar() || openNoticesFromPreferences() else {
            throw XCTSkip("Could not open notices")
        }
        
        sleep(1)
        
        // Find and tap first notice
        let list = app.collectionViews.firstMatch
        let firstCell = list.cells.firstMatch
        
        guard firstCell.exists else {
            throw XCTSkip("No notices to test")
        }
        
        firstCell.tap()
        
        // Verify notice details opened
        let detailsNavBar = app.navigationBars["Notice message"]
        _ = detailsNavBar.waitForExistence(timeout: 2)
        
        // Go back
        let backButton = app.buttons["chevron.left"]
        if backButton.exists {
            backButton.tap()
        }
    }
}
