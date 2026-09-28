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
        XCTAssertEqual(post.progress, .added)
        XCTAssertEqual(post.favoriteChoice, .no)
        XCTAssertEqual(post.origin, .local)
        XCTAssertFalse(post.draft)
        XCTAssertEqual(post.category, Constants.mainCategory)
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
        XCTAssertEqual(post.progress, .added)
        XCTAssertEqual(post.favoriteChoice, .no)
        XCTAssertEqual(post.origin, .local)
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
            category: Constants.mainCategory,
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
            category: Constants.mainCategory,
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
            category: Constants.mainCategory,
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
            progress: .added,
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
        post.progress = .added
        
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
        post.progress = .added
        
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
        
        // When - Move backward to added
        post.progress = .added
        
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

    // MARK: - mergeUserState(from:) Tests
    // Слияние пользовательского состояния дубля перед его удалением
    // (removeDuplicatePosts). @MainActor — Post изолирован на MainActor.

    @MainActor
    func testMergeUserState_TakesStrongestStateFromDuplicate() {
        // Given — остающаяся копия с "меньшим" состоянием
        let d1 = Date(timeIntervalSince1970: 1_000)
        let d2 = Date(timeIntervalSince1970: 2_000)
        let d3 = Date(timeIntervalSince1970: 3_000)
        let d4 = Date(timeIntervalSince1970: 4_000)

        let keep = Post(
            title: "Keep",
            progress: .started,
            favoriteChoice: .no,
            postRating: .good,
            notes: "Notes A",
            origin: .cloud,
            draft: false,
            status: .active,
            addedDateStamp: d2,
            startedDateStamp: d2
        )
        // Дубль с более продвинутым состоянием и более ранними метками
        let duplicate = Post(
            title: "Duplicate",
            progress: .practiced,
            favoriteChoice: .yes,
            postRating: .excellent,
            notes: "Notes B",
            origin: .local,
            draft: true,
            status: .deleted,
            addedDateStamp: d1,
            startedDateStamp: d1,
            studiedDateStamp: d3,
            practicedDateStamp: d4
        )

        // When
        keep.mergeUserState(from: duplicate)

        // Then — пользовательское состояние слито
        XCTAssertEqual(keep.progress, .practiced)
        XCTAssertEqual(keep.addedDateStamp, d1)
        XCTAssertEqual(keep.startedDateStamp, d1)
        XCTAssertEqual(keep.studiedDateStamp, d3)
        XCTAssertEqual(keep.practicedDateStamp, d4)
        XCTAssertEqual(keep.favoriteChoice, .yes)
        XCTAssertEqual(keep.postRating, .excellent)
        XCTAssertEqual(keep.notes, "Notes A\n\nNotes B")

        // Then — контент и служебные поля остаются как у остающейся копии
        XCTAssertEqual(keep.title, "Keep")
        XCTAssertEqual(keep.origin, .cloud)
        XCTAssertFalse(keep.draft)
        XCTAssertEqual(keep.status, .active)
    }

    @MainActor
    func testMergeUserState_DoesNotDowngradeStrongerState() {
        // Given — остающаяся копия "сильнее" дубля
        let early = Date(timeIntervalSince1970: 1_000)
        let late = Date(timeIntervalSince1970: 5_000)

        let keep = Post(
            progress: .studied,
            favoriteChoice: .yes,
            postRating: .great,
            notes: "Keep notes",
            startedDateStamp: early,
            studiedDateStamp: early
        )
        let duplicate = Post(
            progress: .started,
            favoriteChoice: .no,
            postRating: nil,
            notes: "",
            startedDateStamp: late
        )

        // When
        keep.mergeUserState(from: duplicate)

        // Then — ничего не откатилось назад
        XCTAssertEqual(keep.progress, .studied)
        XCTAssertEqual(keep.favoriteChoice, .yes)
        XCTAssertEqual(keep.postRating, .great)
        XCTAssertEqual(keep.startedDateStamp, early)
        XCTAssertEqual(keep.studiedDateStamp, early)
        XCTAssertNil(keep.practicedDateStamp)
        XCTAssertEqual(keep.notes, "Keep notes")
    }

    @MainActor
    func testMergeUserState_Notes_TakesMoreCompleteVersion() {
        // Given — заметки дубля — дополненная редакция заметок остающейся копии
        let keep = Post(notes: "Short")
        let duplicate = Post(notes: "Short, then extended")

        // When
        keep.mergeUserState(from: duplicate)

        // Then — берётся более полная версия, без дублирования текста
        XCTAssertEqual(keep.notes, "Short, then extended")

        // Given — у остающейся копии заметок нет
        let emptyKeep = Post(notes: "")
        let withNotes = Post(notes: "Only here")

        // When
        emptyKeep.mergeUserState(from: withNotes)

        // Then
        XCTAssertEqual(emptyKeep.notes, "Only here")
    }

    // MARK: - applyStudyProgress(_:at:) Tests
    // Метки этапов накопительные: пропущенные ранние этапы получают дату
    // следующего, существующие даты не перезаписываются, откат обнуляет поздние.

    @MainActor
    func testApplyStudyProgress_SkippedStages_GetSameDateAsTarget() {
        // Given — пост только добавлен
        let now = Date(timeIntervalSince1970: 3_000)
        let post = Post(progress: .added)

        // When — сразу practiced
        post.applyStudyProgress(.practiced, at: now)

        // Then — started и studied заполнены той же датой
        XCTAssertEqual(post.progress, .practiced)
        XCTAssertEqual(post.practicedDateStamp, now)
        XCTAssertEqual(post.studiedDateStamp, now)
        XCTAssertEqual(post.startedDateStamp, now)
    }

    @MainActor
    func testApplyStudyProgress_ExistingEarlierStamp_IsKept() {
        // Given — started отмечен раньше
        let startedDate = Date(timeIntervalSince1970: 1_000)
        let now = Date(timeIntervalSince1970: 3_000)
        let post = Post(progress: .started, startedDateStamp: startedDate)

        // When
        post.applyStudyProgress(.practiced, at: now)

        // Then — реальная дата started сохранена, пропущенный studied — дата practiced
        XCTAssertEqual(post.startedDateStamp, startedDate)
        XCTAssertEqual(post.studiedDateStamp, now)
        XCTAssertEqual(post.practicedDateStamp, now)
    }

    @MainActor
    func testApplyStudyProgress_SameStageAgain_DoesNotOverwriteDate() {
        // Given — practiced уже отмечен
        let firstDate = Date(timeIntervalSince1970: 1_000)
        let laterDate = Date(timeIntervalSince1970: 9_000)
        let post = Post()
        post.applyStudyProgress(.practiced, at: firstDate)

        // When — тот же этап ещё раз
        post.applyStudyProgress(.practiced, at: laterDate)

        // Then — дата не сдвинулась
        XCTAssertEqual(post.practicedDateStamp, firstDate)
        XCTAssertEqual(post.studiedDateStamp, firstDate)
        XCTAssertEqual(post.startedDateStamp, firstDate)
    }

    @MainActor
    func testApplyStudyProgress_Rollback_ClearsLaterStages() {
        // Given
        let date = Date(timeIntervalSince1970: 1_000)
        let post = Post()
        post.applyStudyProgress(.practiced, at: date)

        // When — откат practiced → studied
        post.applyStudyProgress(.studied, at: Date(timeIntervalSince1970: 9_000))

        // Then — practiced обнулён, ранние этапы не тронуты
        XCTAssertEqual(post.progress, .studied)
        XCTAssertNil(post.practicedDateStamp)
        XCTAssertEqual(post.studiedDateStamp, date)
        XCTAssertEqual(post.startedDateStamp, date)

        // When — откат studied → started
        post.applyStudyProgress(.started, at: Date(timeIntervalSince1970: 9_000))

        // Then
        XCTAssertNil(post.studiedDateStamp)
        XCTAssertEqual(post.startedDateStamp, date)
    }

    @MainActor
    func testApplyStudyProgress_Added_ClearsStagesButKeepsAddedDate() {
        // Given
        let addedDate = Date(timeIntervalSince1970: 500)
        let post = Post(addedDateStamp: addedDate)
        post.applyStudyProgress(.practiced, at: Date(timeIntervalSince1970: 1_000))

        // When
        post.applyStudyProgress(.added, at: Date(timeIntervalSince1970: 9_000))

        // Then
        XCTAssertEqual(post.progress, .added)
        XCTAssertNil(post.startedDateStamp)
        XCTAssertNil(post.studiedDateStamp)
        XCTAssertNil(post.practicedDateStamp)
        XCTAssertEqual(post.addedDateStamp, addedDate)
    }

    // MARK: - isPreferredToKeep(_:over:) Tests
    // Выбор остающейся копии дубля должен совпадать на всех устройствах.

    @MainActor
    func testIsPreferredToKeep_EarlierAddedDateStampWins() {
        let early = Post(title: "A", date: Date(timeIntervalSince1970: 5_000), addedDateStamp: Date(timeIntervalSince1970: 1_000))
        let late = Post(title: "A", date: Date(timeIntervalSince1970: 1), addedDateStamp: Date(timeIntervalSince1970: 2_000))

        XCTAssertTrue(Post.isPreferredToKeep(early, over: late))
        XCTAssertFalse(Post.isPreferredToKeep(late, over: early))
    }

    @MainActor
    func testIsPreferredToKeep_MissingAddedDateStampLoses() {
        let withStamp = Post(title: "A", addedDateStamp: Date(timeIntervalSince1970: 1_000))
        let withoutStamp = Post(title: "A", addedDateStamp: nil)

        XCTAssertTrue(Post.isPreferredToKeep(withStamp, over: withoutStamp))
        XCTAssertFalse(Post.isPreferredToKeep(withoutStamp, over: withStamp))
    }

    @MainActor
    func testIsPreferredToKeep_EqualStamps_EarlierDateWins() {
        let stamp = Date(timeIntervalSince1970: 1_000)
        let earlier = Post(title: "A", date: Date(timeIntervalSince1970: 100), addedDateStamp: stamp)
        let later = Post(title: "A", date: Date(timeIntervalSince1970: 200), addedDateStamp: stamp)

        XCTAssertTrue(Post.isPreferredToKeep(earlier, over: later))
        XCTAssertFalse(Post.isPreferredToKeep(later, over: earlier))
    }

    @MainActor
    func testIsPreferredToKeep_EqualStampsAndDates_SmallerIdWins() {
        let stamp = Date(timeIntervalSince1970: 1_000)
        let date = Date(timeIntervalSince1970: 100)
        let a = Post(id: "a", title: "Same", date: date, addedDateStamp: stamp)
        let b = Post(id: "b", title: "Same", date: date, addedDateStamp: stamp)

        XCTAssertTrue(Post.isPreferredToKeep(a, over: b))
        XCTAssertFalse(Post.isPreferredToKeep(b, over: a))
    }
}
