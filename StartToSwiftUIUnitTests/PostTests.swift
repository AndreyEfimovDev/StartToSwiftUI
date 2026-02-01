//
//  StartToSwiftUIUnitTests.swift
//  StartToSwiftUIUnitTests
//
//  Created by Andrey Efimov on 21.01.2026.
//

import XCTest
import SwiftData
@testable import StartToSwiftUI

final class PostTests: XCTestCase {
    
    // MARK: - Basic Initialization Tests
    
    func testPostDefaultInitialization() {
        // Given & When
        let post = Post()
        
        // Then
        XCTAssertEqual(post.title, "")
        XCTAssertEqual(post.author, "")
        XCTAssertEqual(post.studyLevel, .beginner)
        XCTAssertEqual(post.progress, .fresh)
        XCTAssertEqual(post.favoriteChoice, .no)
        XCTAssertEqual(post.origin, .cloudNew)
        XCTAssertFalse(post.draft)
        XCTAssertEqual(post.category, "SwiftUI")
        XCTAssertEqual(post.urlString, Constants.urlStart)
        XCTAssertEqual(post.postPlatform, .youtube)
        XCTAssertEqual(post.postType, .post)
    }
    
    func testPostCustomInitialization() {
        // Given
        let customDate = Date().addingTimeInterval(-86400)
        
        // When
        let post = Post(
            category: "Combine",
            title: "Custom Title",
            intro: "Custom Intro",
            author: "Custom Author",
            postType: .post,
            urlString: "https://example.com",
            postPlatform: .website,
            postDate: customDate,
            studyLevel: .advanced,
            progress: .studied,
            favoriteChoice: .yes,
            postRating: .excellent,
            notes: "Custom notes",
            origin: .local,
            draft: true,
            date: customDate,
            addedDateStamp: customDate,
            startedDateStamp: customDate,
            studiedDateStamp: customDate,
            practicedDateStamp: customDate
        )
        
        // Then
        XCTAssertEqual(post.category, "Combine")
        XCTAssertEqual(post.title, "Custom Title")
        XCTAssertEqual(post.intro, "Custom Intro")
        XCTAssertEqual(post.author, "Custom Author")
        XCTAssertEqual(post.postType, .post)
        XCTAssertEqual(post.urlString, "https://example.com")
        XCTAssertEqual(post.postPlatform, .website)
        XCTAssertEqual(post.postDate, customDate)
        XCTAssertEqual(post.studyLevel, .advanced)
        XCTAssertEqual(post.progress, .studied)
        XCTAssertEqual(post.favoriteChoice, .yes)
        XCTAssertEqual(post.postRating, .excellent)
        XCTAssertEqual(post.notes, "Custom notes")
        XCTAssertEqual(post.origin, .local)
        XCTAssertTrue(post.draft)
        XCTAssertEqual(post.date, customDate)
        XCTAssertEqual(post.addedDateStamp, customDate)
        XCTAssertEqual(post.startedDateStamp, customDate)
        XCTAssertEqual(post.studiedDateStamp, customDate)
        XCTAssertEqual(post.practicedDateStamp, customDate)
    }
    
    // MARK: - Computed Properties Tests
    
    func testPostComputedProperties() {
        // Given
        let post = Post()
        
        // When
        post.studyLevelRawValue = "advanced"
        post.progressRawValue = "practiced"
        post.favoriteChoiceRawValue = "yes"
        post.originRawValue = "cloud"
        post.postTypeRawValue = "post"
        post.postPlatformRawValue = "website"
        
        // Then
        XCTAssertEqual(post.studyLevel, .advanced)
        XCTAssertEqual(post.progress, .practiced)
        XCTAssertEqual(post.favoriteChoice, .yes)
        XCTAssertEqual(post.origin, .cloud)
        XCTAssertEqual(post.postType, .post)
        XCTAssertEqual(post.postPlatform, .website)
    }
    
    func testPostComputedPropertiesWithInvalidRawValues() {
        // Given
        let post = Post()
        
        // When - Setting invalid raw values
        post.studyLevelRawValue = "invalid_level"
        post.progressRawValue = "invalid_progress"
        post.favoriteChoiceRawValue = "invalid_choice"
        post.originRawValue = "invalid_origin"
        post.postTypeRawValue = "invalid_type"
        post.postPlatformRawValue = "invalid_platform"
        
        // Then - Should fall back to defaults
        XCTAssertEqual(post.studyLevel, .beginner)
        XCTAssertEqual(post.progress, .fresh)
        XCTAssertEqual(post.favoriteChoice, .no)
        XCTAssertEqual(post.origin, .cloudNew)
        XCTAssertEqual(post.postType, .post)
        XCTAssertEqual(post.postPlatform, .youtube)
    }
    
    func testPostRatingComputedProperty() {
        // Given
        let post = Post()
        
        // Test all rating cases
        let testCases: [(raw: String, expected: PostRating)] = [
            ("good", .good),
            ("great", .great),
            ("excellent", .excellent)
        ]
        
        for testCase in testCases {
            // When
            post.postRatingRawValue = testCase.raw
            
            // Then
            XCTAssertEqual(post.postRating, testCase.expected)
        }
    }
    
    func testPostRatingComputedPropertyWithInvalidValue() {
        // Given
        let post = Post()
        
        // When
        post.postRatingRawValue = "invalid_rating"
        
        // Then
        XCTAssertNil(post.postRating)
    }
    
    func testPostRatingComputedPropertySetToNil() {
        // Given
        let post = Post()
        post.postRatingRawValue = "good"
        
        // When
        post.postRating = nil
        
        // Then
        XCTAssertNil(post.postRating)
        XCTAssertNil(post.postRatingRawValue)
    }
    
    // MARK: - Comparison Tests
    
    func testPostIsEqualAllFields() {
        // Given
        let post1 = Post(
            category: "SwiftUI",
            title: "Test Title",
            intro: "Test Intro",
            author: "Test Author",
            urlString: "https://test.com",
            postPlatform: .youtube,
            postDate: Date(),
            studyLevel: .middle,
            notes: "Test notes"
        )
        
        let post2 = Post(
            category: "SwiftUI",
            title: "Test Title",
            intro: "Test Intro",
            author: "Test Author",
            urlString: "https://test.com",
            postPlatform: .youtube,
            postDate: post1.postDate,
            studyLevel: .middle,
            notes: "Test notes"
        )
        
        // When & Then
        XCTAssertTrue(post1.isEqual(to: post2))
    }
    
    func testPostIsNotEqualByTitle() {
        // Given
        let post1 = Post(
            title: "Test Title 1",
            intro: "Test Intro",
            author: "Test Author"
        )
        
        let post2 = Post(
            title: "Test Title 2",
            intro: "Test Intro",
            author: "Test Author"
        )
        
        // When & Then
        XCTAssertFalse(post1.isEqual(to: post2))
    }
    
    func testPostIsNotEqualByCategory() {
        // Given
        let post1 = Post(
            category: "SwiftUI",
            title: "Test Title",
            intro: "Test Intro",
            author: "Test Author"
        )
        
        let post2 = Post(
            category: "Combine",
            title: "Test Title",
            intro: "Test Intro",
            author: "Test Author"
        )
        
        // When & Then
        XCTAssertFalse(post1.isEqual(to: post2))
    }
    
    func testPostIsNotEqualByIntro() {
        // Given
        let post1 = Post(
            title: "Test Title",
            intro: "Intro 1",
            author: "Test Author"
        )
        
        let post2 = Post(
            title: "Test Title",
            intro: "Intro 2",
            author: "Test Author"
        )
        
        // When & Then
        XCTAssertFalse(post1.isEqual(to: post2))
    }
    
    func testPostIsNotEqualByAuthor() {
        // Given
        let post1 = Post(
            title: "Test Title",
            intro: "Test Intro",
            author: "Author 1"
        )
        
        let post2 = Post(
            title: "Test Title",
            intro: "Test Intro",
            author: "Author 2"
        )
        
        // When & Then
        XCTAssertFalse(post1.isEqual(to: post2))
    }
    
    func testPostIsNotEqualByPostType() {
        // Given
        let post1 = Post(
            title: "Test Title",
            intro: "Test Intro",
            author: "Test Author",
            postType: .post
        )
        
        let post2 = Post(
            title: "Test Title",
            intro: "Test Intro",
            author: "Test Author",
            postType: .course
        )
        
        // When & Then
        XCTAssertFalse(post1.isEqual(to: post2))
    }
    
    func testPostIsNotEqualByUrlString() {
        // Given
        let post1 = Post(
            title: "Test Title",
            intro: "Test Intro",
            author: "Test Author",
            urlString: "https://url1.com"
        )
        
        let post2 = Post(
            title: "Test Title",
            intro: "Test Intro",
            author: "Test Author",
            urlString: "https://url2.com"
        )
        
        // When & Then
        XCTAssertFalse(post1.isEqual(to: post2))
    }
    
    func testPostIsNotEqualByPlatform() {
        // Given
        let post1 = Post(
            title: "Test Title",
            intro: "Test Intro",
            author: "Test Author",
            postPlatform: .youtube
        )
        
        let post2 = Post(
            title: "Test Title",
            intro: "Test Intro",
            author: "Test Author",
            postPlatform: .website
        )
        
        // When & Then
        XCTAssertFalse(post1.isEqual(to: post2))
    }
    
    func testPostIsNotEqualByPostDate() {
        // Given
        let date1 = Date()
        let date2 = date1.addingTimeInterval(3600)
        
        let post1 = Post(
            title: "Test Title",
            intro: "Test Intro",
            author: "Test Author",
            postDate: date1
        )
        
        let post2 = Post(
            title: "Test Title",
            intro: "Test Intro",
            author: "Test Author",
            postDate: date2
        )
        
        // When & Then
        XCTAssertFalse(post1.isEqual(to: post2))
    }
    
    func testPostIsNotEqualByStudyLevel() {
        // Given
        let post1 = Post(
            title: "Test Title",
            intro: "Test Intro",
            author: "Test Author",
            studyLevel: .beginner
        )
        
        let post2 = Post(
            title: "Test Title",
            intro: "Test Intro",
            author: "Test Author",
            studyLevel: .advanced
        )
        
        // When & Then
        XCTAssertFalse(post1.isEqual(to: post2))
    }
    
    func testPostIsNotEqualByNotes() {
        // Given
        let post1 = Post(
            title: "Test Title",
            intro: "Test Intro",
            author: "Test Author",
            notes: "Notes 1"
        )
        
        let post2 = Post(
            title: "Test Title",
            intro: "Test Intro",
            author: "Test Author",
            notes: "Notes 2"
        )
        
        // When & Then
        XCTAssertFalse(post1.isEqual(to: post2))
    }
    
    // MARK: - Copy Tests
    
    func testPostCopyCreatesIdenticalButSeparateInstance() {
        // Given
        let original = Post(
            title: "Original Title",
            intro: "Original Intro",
            author: "Original Author",
            studyLevel: .advanced,
            progress: .practiced,
            favoriteChoice: .yes,
            postRating: .excellent,
            notes: "Original notes",
            draft: true
        )
        
        // When
        let copy = original.copy()
        
        // Then
        XCTAssertEqual(original.id, copy.id)
        XCTAssertEqual(original.title, copy.title)
        XCTAssertEqual(original.intro, copy.intro)
        XCTAssertEqual(original.author, copy.author)
        XCTAssertEqual(original.studyLevel, copy.studyLevel)
        XCTAssertEqual(original.progress, copy.progress)
        XCTAssertEqual(original.favoriteChoice, copy.favoriteChoice)
        XCTAssertEqual(original.postRating, copy.postRating)
        XCTAssertEqual(original.notes, copy.notes)
        XCTAssertEqual(original.draft, copy.draft)
        XCTAssertEqual(original.category, copy.category)
        XCTAssertEqual(original.urlString, copy.urlString)
        
        // Verify they are separate instances
        copy.title = "Modified Title"
        XCTAssertNotEqual(original.title, copy.title)
    }
    
    func testPostCopyWithAllProperties() {
        // Given
        let date = Date()
        let original = Post(
            category: "Combine",
            title: "Title",
            intro: "Intro",
            author: "Author",
            postType: .post,
            urlString: "https://test.com",
            postPlatform: .website,
            postDate: date,
            studyLevel: .middle,
            progress: .studied,
            favoriteChoice: .yes,
            postRating: .good,
            notes: "Notes",
            origin: .local,
            draft: true,
            date: date,
            addedDateStamp: date,
            startedDateStamp: date,
            studiedDateStamp: date,
            practicedDateStamp: date
        )
        
        // When
        let copy = original.copy()
        
        // Then - Check all properties
        XCTAssertEqual(original.id, copy.id)
        XCTAssertEqual(original.category, copy.category)
        XCTAssertEqual(original.title, copy.title)
        XCTAssertEqual(original.intro, copy.intro)
        XCTAssertEqual(original.author, copy.author)
        XCTAssertEqual(original.postType, copy.postType)
        XCTAssertEqual(original.urlString, copy.urlString)
        XCTAssertEqual(original.postPlatform, copy.postPlatform)
        XCTAssertEqual(original.postDate, copy.postDate)
        XCTAssertEqual(original.studyLevel, copy.studyLevel)
        XCTAssertEqual(original.progress, copy.progress)
        XCTAssertEqual(original.favoriteChoice, copy.favoriteChoice)
        XCTAssertEqual(original.postRating, copy.postRating)
        XCTAssertEqual(original.notes, copy.notes)
        XCTAssertEqual(original.origin, copy.origin)
        XCTAssertEqual(original.draft, copy.draft)
        XCTAssertEqual(original.date, copy.date)
        XCTAssertEqual(original.addedDateStamp, copy.addedDateStamp)
        XCTAssertEqual(original.startedDateStamp, copy.startedDateStamp)
        XCTAssertEqual(original.studiedDateStamp, copy.studiedDateStamp)
        XCTAssertEqual(original.practicedDateStamp, copy.practicedDateStamp)
    }
    
    // MARK: - Update Tests
    
    func testPostUpdateChangesOnlyEditableFields() {
        // Given
        let originalDate = Date().addingTimeInterval(-86400)
        let post = Post(
            id: "original-id",
            category: "Original Category",
            title: "Original Title",
            intro: "Original Intro",
            author: "Original Author",
            postType: .post,
            urlString: "https://original.com",
            postPlatform: .youtube,
            postDate: originalDate,
            studyLevel: .beginner,
            progress: .practiced, // Should NOT be updated
            favoriteChoice: .yes, // Should NOT be updated
            postRating: .good, // Should NOT be updated
            notes: "Original notes",
            origin: .local, // Should NOT be updated
            draft: false,
            date: originalDate, // Should NOT be updated
            addedDateStamp: originalDate, // Should NOT be updated
            startedDateStamp: originalDate, // Should NOT be updated
            studiedDateStamp: originalDate, // Should NOT be updated
            practicedDateStamp: originalDate // Should NOT be updated
        )
        
        let newDate = Date()
        let updatedPost = Post(
            id: "new-id",
            category: "New Category",
            title: "New Title",
            intro: "New Intro",
            author: "New Author",
            postType: .post,
            urlString: "https://new.com",
            postPlatform: .website,
            postDate: newDate,
            studyLevel: .advanced,
            progress: .fresh,
            favoriteChoice: .no,
            postRating: .excellent,
            notes: "New notes",
            origin: .cloud,
            draft: true,
            date: newDate,
            addedDateStamp: newDate,
            startedDateStamp: newDate,
            studiedDateStamp: newDate,
            practicedDateStamp: newDate
        )
        
        // When
        post.update(with: updatedPost)
        
        // Then - Check editable fields were updated
        XCTAssertEqual(post.category, "New Category")
        XCTAssertEqual(post.title, "New Title")
        XCTAssertEqual(post.intro, "New Intro")
        XCTAssertEqual(post.author, "New Author")
        XCTAssertEqual(post.postType, .post)
        XCTAssertEqual(post.urlString, "https://new.com")
        XCTAssertEqual(post.postPlatform, .website)
        XCTAssertEqual(post.postDate, newDate)
        XCTAssertEqual(post.studyLevel, .advanced)
        XCTAssertEqual(post.notes, "New notes")
        XCTAssertEqual(post.draft, true)
        
        // Check non-editable fields remain unchanged
        XCTAssertEqual(post.id, "original-id")
        XCTAssertEqual(post.progress, .practiced) // Should remain unchanged
        XCTAssertEqual(post.favoriteChoice, .yes) // Should remain unchanged
        XCTAssertEqual(post.postRating, .good) // Should remain unchanged
        XCTAssertEqual(post.origin, .local) // Should remain unchanged
        XCTAssertEqual(post.date, originalDate) // Should remain unchanged
        XCTAssertEqual(post.addedDateStamp, originalDate) // Should remain unchanged
        XCTAssertEqual(post.startedDateStamp, originalDate) // Should remain unchanged
        XCTAssertEqual(post.studiedDateStamp, originalDate) // Should remain unchanged
        XCTAssertEqual(post.practicedDateStamp, originalDate) // Should remain unchanged
    }
    
    func testPostUpdateWithNilValues() {
        // Given
        let originalDate = Date()
        let post = Post(
            title: "Original Title",
            intro: "Original Intro",
            author: "Original Author",
            postDate: originalDate,
            notes: "Original notes"
        )
        
        let updatedPost = Post(
            title: "New Title",
            intro: "New Intro",
            author: "New Author",
            postDate: nil,
            notes: ""
        )
        
        // When
        post.update(with: updatedPost)
        
        // Then
        XCTAssertEqual(post.title, "New Title")
        XCTAssertEqual(post.intro, "New Intro")
        XCTAssertEqual(post.author, "New Author")
        XCTAssertNil(post.postDate)
        XCTAssertEqual(post.notes, "")
    }
    
    // MARK: - Date Stamps Tests
    func testPostDateStampsAreIndependentOfProgress() {
        // Given
        let post = Post()
        
        // When - Manually set dates
        let startDate = Date().addingTimeInterval(-86400)
        let studyDate = Date().addingTimeInterval(-43200)
        let practiceDate = Date()
        
        post.startedDateStamp = startDate
        post.studiedDateStamp = studyDate
        post.practicedDateStamp = practiceDate
        
        // Then - Dates should be preserved regardless of progress
        XCTAssertEqual(post.startedDateStamp, startDate)
        XCTAssertEqual(post.studiedDateStamp, studyDate)
        XCTAssertEqual(post.practicedDateStamp, practiceDate)
        
        // When - Change progress
        post.progress = .fresh
        
        // Then - Dates should remain unchanged
        XCTAssertEqual(post.startedDateStamp, startDate)
        XCTAssertEqual(post.studiedDateStamp, studyDate)
        XCTAssertEqual(post.practicedDateStamp, practiceDate)
    }

    func testPostDateStampsCanBeClearedIndependently() {
        // Given
        let post = Post()
        post.startedDateStamp = Date()
        post.studiedDateStamp = Date()
        post.practicedDateStamp = Date()
        
        // When - Clear dates individually
        post.startedDateStamp = nil
        
        // Then
        XCTAssertNil(post.startedDateStamp)
        XCTAssertNotNil(post.studiedDateStamp)
        XCTAssertNotNil(post.practicedDateStamp)
        
        // When - Clear all dates
        post.startedDateStamp = nil
        post.studiedDateStamp = nil
        post.practicedDateStamp = nil
        
        // Then
        XCTAssertNil(post.startedDateStamp)
        XCTAssertNil(post.studiedDateStamp)
        XCTAssertNil(post.practicedDateStamp)
    }
    func testPostResetDateStampsWhenSetToFresh() {
        // Given
        let post = Post()
        post.progress = .practiced
        // Ensure dates are set
        let _ = post.startedDateStamp
        let _ = post.studiedDateStamp
        let _ = post.practicedDateStamp
        
        // When
        post.progress = .fresh
        
        // Then
        XCTAssertNil(post.startedDateStamp)
        XCTAssertNil(post.studiedDateStamp)
        XCTAssertNil(post.practicedDateStamp)
    }
    
    func testPostDateStampsNotChangedWhenSettingSameProgress() {
        // Given
        let post = Post()
        post.progress = .studied
        let originalStudiedDate = post.studiedDateStamp
        
        // When - Set to same progress
        let beforeUpdate = Date()
        post.progress = .studied
        let afterUpdate = Date()
        
        // Then - Date should remain the same
        XCTAssertEqual(post.studiedDateStamp, originalStudiedDate)
        if let studiedDate = post.studiedDateStamp {
            XCTAssertTrue(studiedDate < beforeUpdate)
            XCTAssertTrue(studiedDate < afterUpdate)
        }
    }
    
    func testPostDateStampsPartialResetWhenMovingBackward() {
        // Given
        let post = Post()
        post.progress = .practiced
        let originalStarted = post.startedDateStamp
        let originalStudied = post.studiedDateStamp
        _ = post.practicedDateStamp
        
        // When - Move backward to studied
        post.progress = .studied
        
        // Then
        XCTAssertEqual(post.startedDateStamp, originalStarted)
        XCTAssertEqual(post.studiedDateStamp, originalStudied)
        XCTAssertNil(post.practicedDateStamp)
        
        // When - Move backward to started
        post.progress = .started
        
        // Then
        XCTAssertEqual(post.startedDateStamp, originalStarted)
        XCTAssertNil(post.studiedDateStamp)
        XCTAssertNil(post.practicedDateStamp)
        
        // When - Move backward to fresh
        post.progress = .fresh
        
        // Then
        XCTAssertNil(post.startedDateStamp)
        XCTAssertNil(post.studiedDateStamp)
        XCTAssertNil(post.practicedDateStamp)
    }
    
    // MARK: - Edge Cases Tests
    
    func testPostWithEmptyStrings() {
        // Given & When
        let post = Post(
            category: "",
            title: "",
            intro: "",
            author: "",
            urlString: "",
            notes: ""
        )
        
        // Then
        XCTAssertEqual(post.category, "")
        XCTAssertEqual(post.title, "")
        XCTAssertEqual(post.intro, "")
        XCTAssertEqual(post.author, "")
        XCTAssertEqual(post.urlString, "")
        XCTAssertEqual(post.notes, "")
    }
    
    func testPostWithVeryLongStrings() {
        // Given
        let longString = String(repeating: "a", count: 1000)
        
        // When
        let post = Post(
            title: longString,
            intro: longString,
            author: longString,
            notes: longString
        )
        
        // Then
        XCTAssertEqual(post.title, longString)
        XCTAssertEqual(post.intro, longString)
        XCTAssertEqual(post.author, longString)
        XCTAssertEqual(post.notes, longString)
    }
    
    func testPostWithSpecialCharacters() {
        // Given
        let specialTitle = "Test 🚀 Title with emoji"
        let specialIntro = "Intro with ❤️ and #hashtag"
        let specialAuthor = "Author © 2024"
        let specialNotes = "Notes with\nnewline\tand tab"
        
        // When
        let post = Post(
            title: specialTitle,
            intro: specialIntro,
            author: specialAuthor,
            notes: specialNotes
        )
        
        // Then
        XCTAssertEqual(post.title, specialTitle)
        XCTAssertEqual(post.intro, specialIntro)
        XCTAssertEqual(post.author, specialAuthor)
        XCTAssertEqual(post.notes, specialNotes)
    }
}
