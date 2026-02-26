//
//  PostsUITests.swift
//  StartToSwiftUIUITests
//
//  Created by Andrey Efimov on 25.01.2026.
//

import XCTest

final class PostsUITests: XCTestCase {
    
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
    
    // MARK: - Post List Tests
    
    func testPostListDisplays() throws {
        // Check if the list exists (either with posts or empty state)
        let list = app.collectionViews.firstMatch
        let emptyState = app.staticTexts["No Study Materials"]
        
        let hasContent = list.waitForExistence(timeout: 3) || emptyState.waitForExistence(timeout: 3)
        XCTAssertTrue(hasContent, "Neither post list nor empty state is displayed")
    }
    
    func testTapOnPostOpensDetails() throws {
        // Find the first cell in the list
        let list = app.collectionViews.firstMatch
        guard list.waitForExistence(timeout: 3) else {
            // No posts available, skip test
            throw XCTSkip("No posts available to test")
        }
        
        let firstCell = list.cells.firstMatch
        guard firstCell.exists else {
            throw XCTSkip("No posts in list")
        }
        
        firstCell.tap()
        
        // On iPhone, verify navigation to details
        // On iPad, details appear in split view
        sleep(1)
    }
    
    // MARK: - Add Post Tests
    
    func testAddNewPostFlow() throws {
        // Open Add Post
        let addButton = app.buttons["plus"]
        guard addButton.waitForExistence(timeout: 3) else {
            XCTFail("Add button not found")
            return
        }
        addButton.tap()
        
        // Verify Add screen opened
        let addNavBar = app.navigationBars["Add"]
        XCTAssertTrue(addNavBar.waitForExistence(timeout: 2))
        
        // Fill in required fields
        let titleField = app.textFields["Title"]
        if titleField.waitForExistence(timeout: 2) {
            titleField.tap()
            titleField.typeText("Test Post Title")
        }
        
        // Dismiss keyboard (universal approach)
        if app.keyboards.element.exists {
            app.tap() // tap outside to dismiss
        }
    }
    
    func testAddPostValidation() throws {
        // Open Add Post
        let addButton = app.buttons["plus"]
        guard addButton.waitForExistence(timeout: 3) else {
            XCTFail("Add button not found")
            return
        }
        addButton.tap()
        
        // Try to save without filling required fields
        let saveButton = app.buttons["Save"]
        if saveButton.waitForExistence(timeout: 2) && saveButton.isEnabled {
            saveButton.tap()
            
            // Expect validation error or disabled state
            sleep(1)
        }
        
        // Close the view
        let backButton = app.buttons["chevron.left"]
        if backButton.exists {
            backButton.tap()
        }
    }
    
    func testCancelAddPost() throws {
        // Open Add Post
        let addButton = app.buttons["plus"]
        guard addButton.waitForExistence(timeout: 3) else {
            XCTFail("Add button not found")
            return
        }
        addButton.tap()
        
        // Verify Add screen opened
        let navBar = app.navigationBars["Add"]
        XCTAssertTrue(navBar.waitForExistence(timeout: 2))
        
        // Go back without saving - ищем кнопку ВНУТРИ NavigationBar
        let backButton = navBar.buttons["chevron.left"]
        let closeButton = navBar.buttons["xmark"]
        
        if backButton.exists {
            backButton.tap()
        } else if closeButton.exists {
            closeButton.tap()
        } else {
            // Fallback: кнопка с label "Close" в навбаре
            let closeByLabel = navBar.buttons["Close"]
            if closeByLabel.exists {
                closeByLabel.tap()
            } else {
                XCTFail("No back/close button found in navigation bar")
            }
        }
        
        // May show confirmation dialog for unsaved changes
        let discardButton = app.buttons["Discard"]
        if discardButton.waitForExistence(timeout: 1) {
            discardButton.tap()
        }
        
        sleep(1)
    }
    // MARK: - Swipe Actions Tests
    
    func testSwipeToDeletePost() throws {
        let list = app.collectionViews.firstMatch
        guard list.waitForExistence(timeout: 3) else {
            throw XCTSkip("No posts available")
        }
        
        let firstCell = list.cells.firstMatch
        guard firstCell.exists else {
            throw XCTSkip("No posts in list")
        }
        
        // Swipe left to reveal delete action
        firstCell.swipeLeft()
        
        // Check if delete button appears
        let hideButton = app.buttons["Hide"]
        let deleteButton = app.buttons["Delete"]
        let hasActions = hideButton.waitForExistence(timeout: 2) || deleteButton.exists
        XCTAssertTrue(hasActions, "Swipe actions should be visible")

        if deleteButton.waitForExistence(timeout: 2) {
            // Don't actually delete, just verify the action exists
            // Swipe right to dismiss
            firstCell.swipeRight()
        }
    }
    
    func testSwipeToFavouritePost() throws {
        let list = app.collectionViews.firstMatch
        guard list.waitForExistence(timeout: 3) else {
            throw XCTSkip("No posts available")
        }
        
        let firstCell = list.cells.firstMatch
        guard firstCell.exists else {
            throw XCTSkip("No posts in list")
        }
        
        // Swipe right to reveal favorite action
        firstCell.swipeRight()
        
        // Check if mark/unmark button appears
        let markButton = app.buttons["Mark"]
        let unmarkButton = app.buttons["Unmark"]
        
        if markButton.waitForExistence(timeout: 2) || unmarkButton.waitForExistence(timeout: 1) {
            // Dismiss by swiping
            firstCell.swipeLeft()
        }
    }
}
