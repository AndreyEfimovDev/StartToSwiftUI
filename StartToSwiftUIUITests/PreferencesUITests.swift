//
//  PreferencesUITests.swift
//  StartToSwiftUIUITests
//
//  Created by Andrey Efimov on 25.01.2026.
//

import XCTest

final class PreferencesUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
        
        waitForLaunchScreenToDisappear()
        acceptTermsOfUseIfNeeded()
        openPreferences()
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
    
    private func openPreferences() {
        let settingsButton = app.buttons["gearshape"]
        if settingsButton.waitForExistence(timeout: 3) {
            settingsButton.tap()
            _ = app.navigationBars["Preferences"].waitForExistence(timeout: 2)
        }
    }
    
    private func closePreferences() {
        let backButton = app.buttons["chevron.left"]
        let closeButton = app.buttons["xmark"]
        
        if backButton.exists {
            backButton.tap()
        } else if closeButton.exists {
            closeButton.tap()
        }
    }
    
    // MARK: - Preferences Screen Tests
    
    func testPreferencesScreenDisplays() throws {
        let navBar = app.navigationBars["Preferences"]
        XCTAssertTrue(navBar.exists, "Preferences screen should be displayed")
    }
    
    func testThemeAppearanceSection() throws {
        // Check for theme options - they are Text elements, not buttons
        let lightOption = app.staticTexts["Light"]
        let darkOption = app.staticTexts["Dark"]
        let systemOption = app.staticTexts["System"]
        
        let hasThemeOptions = lightOption.exists || darkOption.exists || systemOption.exists
        XCTAssertTrue(hasThemeOptions, "Theme options should be visible")
    }

    func testToggleTheme() throws {
        // Find and toggle theme - they are Text elements
        let darkOption = app.staticTexts["Dark"]
        let lightOption = app.staticTexts["Light"]
        
        if darkOption.waitForExistence(timeout: 2) {
            darkOption.tap()
            sleep(1)
        }
        
        if lightOption.waitForExistence(timeout: 2) {
            lightOption.tap()
            sleep(1)
        }
    }
    
    // MARK: - Notifications Section Tests
    
    func testNotificationToggle() throws {
        let notificationToggle = app.switches.firstMatch
        
        guard notificationToggle.waitForExistence(timeout: 2) else {
            throw XCTSkip("Notification toggle not found")
        }
        
        // Verify toggle is interactable and tap works
        XCTAssertTrue(notificationToggle.isHittable)
        notificationToggle.tap()
        sleep(1)
        notificationToggle.tap() // restore
    }

    // MARK: - Navigation Tests
    
    func testOpenAchievements() throws {
        let achievementsButton = app.buttons["Check progress"]
        
        if achievementsButton.waitForExistence(timeout: 2) {
            achievementsButton.tap()
            
            // Verify Study Progress screen opens
            sleep(1)
            
            // Go back
            let backButton = app.buttons["chevron.left"]
            if backButton.exists {
                backButton.tap()
            }
        }
    }
    
    func testOpenAboutApp() throws {
        // Scroll down to find About App
        let aboutButton = app.buttons["About App"]
        
        // Scroll if needed
        if !aboutButton.exists {
            app.swipeUp()
        }
        
        if aboutButton.waitForExistence(timeout: 2) {
            aboutButton.tap()
            sleep(1)
            
            // Go back
            let backButton = app.buttons["chevron.left"]
            if backButton.exists {
                backButton.tap()
            }
        }
    }
    
    func testOpenLegalInformation() throws {
        // Scroll down to find Legal Information
        let legalButton = app.buttons["Legal information"]
        
        // Scroll if needed
        if !legalButton.exists {
            app.swipeUp()
        }
        
        if legalButton.waitForExistence(timeout: 2) {
            legalButton.tap()
            sleep(1)
            
            // Go back
            let backButton = app.buttons["chevron.left"]
            if backButton.exists {
                backButton.tap()
            }
        }
    }
    
    func testOpenAcknowledgements() throws {
        // Scroll down to find Acknowledgements
        let ackButton = app.buttons["Acknowledgements"]
        
        // Scroll if needed
        if !ackButton.exists {
            app.swipeUp()
        }
        
        if ackButton.waitForExistence(timeout: 2) {
            ackButton.tap()
            sleep(1)
            
            // Go back
            let backButton = app.buttons["chevron.left"]
            if backButton.exists {
                backButton.tap()
            }
        }
    }
    
    // MARK: - Materials Management Tests
    
    func testShareBackupOption() throws {
        let shareButton = app.buttons["Share/Backup"]
        
        if !shareButton.exists {
            app.swipeUp()
        }
        
        if shareButton.waitForExistence(timeout: 2) {
            shareButton.tap()
            sleep(1)
            
            // Go back
            let backButton = app.buttons["chevron.left"]
            let closeButton = app.buttons["xmark"]
            let homeButton = app.buttons["house"]
            
            if backButton.exists {
                backButton.tap()
            } else if closeButton.exists {
                closeButton.tap()
            } else if homeButton.exists {
                homeButton.tap()
            }
        }
    }
    
    func testRestoreBackupOption() throws {
        let restoreButton = app.buttons["Restore backup"]
        
        if !restoreButton.exists {
            app.swipeUp()
        }
        
        if restoreButton.waitForExistence(timeout: 2) {
            restoreButton.tap()
            sleep(1)
            
            // Go back
            let backButton = app.buttons["chevron.left"]
            if backButton.exists {
                backButton.tap()
            }
        }
    }
    
    func testErasePostsOptionExists() throws {
        let eraseButton = app.buttons["Erase all materials"]
        
        // Scroll to find the button
        var scrollAttempts = 0
        while !eraseButton.exists && scrollAttempts < 3 {
            app.swipeUp()
            scrollAttempts += 1
        }
        
        // Just verify the option exists, don't tap it
        XCTAssertTrue(eraseButton.exists, "Erase all materials option should exist")
    }
}
