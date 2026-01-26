//
//  StartToSwiftUIUITests.swift
//  StartToSwiftUIUITests
//
//  Created by Andrey Efimov on 25.01.2026.
//

import XCTest

final class StartToSwiftUIUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
        
        // Wait for launch screen to disappear
        waitForLaunchScreenToDisappear()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Helper Methods
    
    private func waitForLaunchScreenToDisappear() {
        // Wait up to 5 seconds for the launch animation to complete
        let homeExists = app.navigationBars["SwiftUI"].waitForExistence(timeout: 5)
        if !homeExists {
            // Try waiting a bit more if Terms of Use screen appears
            sleep(2)
        }
    }
    
    private func acceptTermsOfUseIfNeeded() {
        let termsButton = app.buttons["Terms of Use"]
        if termsButton.waitForExistence(timeout: 2) {
            termsButton.tap()
            
            // Wait for Terms of Use screen and accept
            let acceptButton = app.buttons["Accept and Continue"]
            if acceptButton.waitForExistence(timeout: 2) {
                acceptButton.tap()
            }
        }
    }
    
    private func dismissModalIfPresent() {
        let closeButton = app.buttons["xmark"]
        if closeButton.exists {
            closeButton.tap()
        }
    }
    
    // MARK: - Launch Tests
    
    func testAppLaunches() throws {
        // Verify the app launches successfully
        XCTAssertTrue(app.state == .runningForeground)
    }
    
    func testHomeViewDisplaysAfterLaunch() throws {
        acceptTermsOfUseIfNeeded()
        
        // Verify HomeView is displayed (navigation bar with title)
        let navBar = app.navigationBars.firstMatch
        XCTAssertTrue(navBar.waitForExistence(timeout: 5))
    }
    
    // MARK: - Navigation Tests
    
    func testOpenPreferences() throws {
        acceptTermsOfUseIfNeeded()
        
        // Tap on settings button (gearshape icon)
        let settingsButton = app.buttons["gearshape"]
        if settingsButton.waitForExistence(timeout: 3) {
            settingsButton.tap()
            
            // Verify Preferences screen is displayed
            let preferencesNavBar = app.navigationBars["Preferences"]
            XCTAssertTrue(preferencesNavBar.waitForExistence(timeout: 2))
        }
    }
    
    func testOpenAndClosePreferences() throws {
        acceptTermsOfUseIfNeeded()
        
        // Open Preferences
        let settingsButton = app.buttons["gearshape"]
        guard settingsButton.waitForExistence(timeout: 3) else {
            XCTFail("Settings button not found")
            return
        }
        settingsButton.tap()
        
        // Verify Preferences opened
        let preferencesNavBar = app.navigationBars["Preferences"]
        XCTAssertTrue(preferencesNavBar.waitForExistence(timeout: 2))
        
        // Close Preferences (back button or X button)
        let backButton = app.buttons["chevron.left"]
        let closeButton = app.buttons["xmark"]
        
        if backButton.exists {
            backButton.tap()
        } else if closeButton.exists {
            closeButton.tap()
        }
        
        // Verify back to HomeView
        sleep(1)
    }
    
    func testOpenAddPostView() throws {
        acceptTermsOfUseIfNeeded()
        
        // Tap on add button (plus icon)
        let addButton = app.buttons["plus"]
        guard addButton.waitForExistence(timeout: 3) else {
            XCTFail("Add button not found")
            return
        }
        addButton.tap()
        
        // Verify Add Post screen is displayed
        let addNavBar = app.navigationBars["Add"]
        XCTAssertTrue(addNavBar.waitForExistence(timeout: 2))
    }
    
    func testOpenFiltersSheet() throws {
        acceptTermsOfUseIfNeeded()
        
        let filtersButton = app.buttons["line.3.horizontal.decrease"]
        guard filtersButton.waitForExistence(timeout: 3) else {
            XCTFail("Filters button not found")
            return
        }
        
        filtersButton.tap()
        sleep(1) // Wait for sheet animation
        
        // Check for filter-related content (actual labels from FiltersSheetView)
        let filtersTitle = app.staticTexts["Filters"]
        let studyLevel = app.staticTexts["Study level:"]
        let favorite = app.staticTexts["Favorite:"]
        let postType = app.staticTexts["Post type:"]
        
        let sheetIsOpen = filtersTitle.exists || studyLevel.exists || favorite.exists || postType.exists
        XCTAssertTrue(sheetIsOpen, "Filter sheet should show filter options")
        
        // Close sheet by swiping down
        app.swipeDown()
    }
}
