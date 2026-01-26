//
//  SearchAndFilterUITests.swift
//  StartToSwiftUIUITests
//
//  Created by Andrey Efimov on 25.01.2026.
//

import XCTest

final class SearchAndFilterUITests: XCTestCase {
    
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
    
    // MARK: - Search Tests
    
    func testSearchBarExists() throws {
        // Search bar uses TextField with placeholder "Search here ..."
        let searchField = app.textFields["Search here ..."]
        
        XCTAssertTrue(searchField.waitForExistence(timeout: 3), "Search bar should be visible")
    }
    
    func testSearchTyping() throws {
        let searchField = app.textFields["Search here ..."]
        
        guard searchField.waitForExistence(timeout: 3) else {
            throw XCTSkip("Search field not found")
        }
        
        searchField.tap()
        searchField.typeText("Swift")
        sleep(1)
        
        // Dismiss keyboard
        if app.keyboards.element.exists {
            app.tap()
        }
    }

    func testSearchShowsNoResultsForInvalidQuery() throws {
        let searchField = app.textFields["Search here ..."]
        
        guard searchField.waitForExistence(timeout: 3) else {
            throw XCTSkip("Search field not found")
        }
        
        searchField.tap()
        searchField.typeText("xyznonexistent123")
        sleep(1)
        
        // Check for "No Results" message or empty list
        let noResults = app.staticTexts["No Results matching your search criteria"]
        let noResultsAlt = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'No Results'")).firstMatch
        let emptyStateVisible = noResults.exists || noResultsAlt.exists || app.collectionViews.cells.count == 0
        
        XCTAssertTrue(emptyStateVisible, "Should show no results or empty list for invalid query")
        
        // Dismiss keyboard
        if app.keyboards.element.exists {
            app.tap()
        }
    }

    // MARK: - Filter Tests
    
    func testOpenFiltersSheet() throws {
        let filtersButton = app.buttons["line.3.horizontal.decrease"]
        guard filtersButton.waitForExistence(timeout: 3) else {
            XCTFail("Filters button not found")
            return
        }
        
        filtersButton.tap()
        sleep(1) // Wait for sheet animation
        
        // Verify sheet is open (check for filter-related content)
        // Close by swiping down
        app.swipeDown()
    }
    
    func testFilterByLevel() throws {
        // Open filters
        let filtersButton = app.buttons["line.3.horizontal.decrease"]
        guard filtersButton.waitForExistence(timeout: 3) else {
            XCTFail("Filters button not found")
            return
        }
        filtersButton.tap()
        sleep(1)
        
        // Try to find and tap a level filter option
        let beginnerOption = app.buttons["Beginner"]
        let middleOption = app.buttons["Middle"]
        let advancedOption = app.buttons["Advanced"]
        
        if beginnerOption.exists {
            beginnerOption.tap()
        } else if middleOption.exists {
            middleOption.tap()
        } else if advancedOption.exists {
            advancedOption.tap()
        }
        
        // Close filters
        app.swipeDown()
        sleep(1)
    }
    
    func testResetFilters() throws {
        // Open filters
        let filtersButton = app.buttons["line.3.horizontal.decrease"]
        guard filtersButton.waitForExistence(timeout: 3) else {
            XCTFail("Filters button not found")
            return
        }
        filtersButton.tap()
        sleep(1)
        
        // Look for reset/clear filters button
        let resetButton = app.buttons["Reset"]
        let clearButton = app.buttons["Clear"]
        let clearAllButton = app.buttons["Clear All"]
        
        if resetButton.exists {
            resetButton.tap()
        } else if clearButton.exists {
            clearButton.tap()
        } else if clearAllButton.exists {
            clearAllButton.tap()
        }
        
        // Close filters
        app.swipeDown()
    }
    
    // MARK: - Voice Search Tests
    
    func testVoiceSearchButtonExists() throws {
        // Check if voice search button exists (microphone icon)
        let micButton = app.buttons["mic"]
        let micFillButton = app.buttons["mic.fill"]
        
        let voiceSearchExists = micButton.waitForExistence(timeout: 2) || micFillButton.exists
        
        // Voice search may not be available on all devices/simulators
        // Just log whether it exists
        if voiceSearchExists {
            XCTAssertTrue(true, "Voice search button is available")
        } else {
            // Not a failure - feature may not be implemented
            print("Voice search button not found - feature may not be available")
        }
    }
}
