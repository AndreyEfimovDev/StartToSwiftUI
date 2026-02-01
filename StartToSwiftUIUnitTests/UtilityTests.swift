//
//  UtilityTests.swift
//  StartToSwiftUIUnitTests
//
//  Created by Andrey Efimov on 21.01.2026.
//

import SwiftUI

import XCTest
@testable import StartToSwiftUI

final class UtilityTests: XCTestCase {
    
    // MARK: - PostMigrationHelper Tests
    
    func testPostMigrationHelperBasicConversion() {
        // Given
        let codablePost = CodablePost(
            id: "test-id",
            category: "SwiftUI",
            title: "Test Title",
            intro: "Test Intro",
            author: "Test Author",
            postType: .post,
            urlString: "https://example.com",
            postPlatform: .youtube,
            postDate: Date(),
            studyLevel: .beginner,
            progress: .fresh,
            favoriteChoice: .no,
            postRating: nil,
            notes: "Test notes",
            origin: .cloud,
            draft: false,
            status: .active,
            date: Date(),
            addedDateStamp: nil,
            startedDateStamp: nil,
            studiedDateStamp: nil,
            practicedDateStamp: nil
        )
        
        // When
        let post = PostMigrationHelper.convertFromCodable(codablePost)
        
        // Then
        XCTAssertEqual(post.id, codablePost.id)
        XCTAssertEqual(post.title, codablePost.title)
        XCTAssertEqual(post.intro, codablePost.intro)
        XCTAssertEqual(post.author, codablePost.author)
        XCTAssertEqual(post.postType, codablePost.postType)
        XCTAssertEqual(post.studyLevel, codablePost.studyLevel)
        XCTAssertEqual(post.progress, codablePost.progress)
        XCTAssertEqual(post.origin, codablePost.origin)
        XCTAssertEqual(post.notes, codablePost.notes)
        XCTAssertEqual(post.draft, codablePost.draft)
    }
    
    func testPostMigrationHelperWithOptionalFields() {
        // Given
        let testDate = Date()
        let codablePost = CodablePost(
            id: "test-id-optional",
            category: "", // Empty string instead of nil
            title: "Optional Test",
            intro: "",
            author: "",
            postType: .post,
            urlString: "", // Empty string
            postPlatform: .youtube, // Default value
            postDate: nil, // Optional date - ВАЖНО: это nil!
            studyLevel: .beginner, // Default value
            progress: .fresh, // Default value
            favoriteChoice: .no, // Default value
            postRating: .good, // With rating
            notes: "", // Empty string
            origin: .local,
            draft: true,
            status: .active,
            date: testDate, // Основная дата
            addedDateStamp: testDate.addingTimeInterval(3600),
            startedDateStamp: testDate.addingTimeInterval(4800),
            studiedDateStamp: testDate.addingTimeInterval(7200),
            practicedDateStamp: nil
        )
        
        // When
        let post = PostMigrationHelper.convertFromCodable(codablePost)
        
        // Then
        XCTAssertEqual(post.id, codablePost.id)
        XCTAssertEqual(post.title, codablePost.title)
        XCTAssertEqual(post.category, "") // Should be empty string
        XCTAssertEqual(post.intro, "") // Should be empty string
        XCTAssertEqual(post.author, "") // Should be empty string
        XCTAssertEqual(post.postType, .post)
        XCTAssertEqual(post.urlString, "") // Should be empty string
        XCTAssertEqual(post.postPlatform, .youtube)
        XCTAssertNil(post.postDate) // ДОЛЖНО быть nil, т.к. мы передали nil в codablePost
        XCTAssertEqual(post.studyLevel, .beginner)
        XCTAssertEqual(post.progress, .fresh)
        XCTAssertEqual(post.favoriteChoice, .no)
        XCTAssertEqual(post.postRating, .good) // Should preserve rating
        XCTAssertEqual(post.notes, "") // Should be empty string
        XCTAssertEqual(post.origin, .local)
        XCTAssertEqual(post.draft, true)
        XCTAssertEqual(post.date, testDate) // Основная дата должна быть скопирована
        XCTAssertEqual(post.addedDateStamp, testDate.addingTimeInterval(3600))
        XCTAssertEqual(post.startedDateStamp, testDate.addingTimeInterval(4800))
        XCTAssertEqual(post.studiedDateStamp, testDate.addingTimeInterval(7200))
        XCTAssertNil(post.practicedDateStamp)
    }
    
    func testPostMigrationHelperWithPostDate() {
        // Given - Тест с установленной postDate
        let testDate = Date()
        let postDate = testDate.addingTimeInterval(-86400) // Вчера
        
        let codablePost = CodablePost(
            id: "test-with-postdate",
            category: "Test",
            title: "Test with Post Date",
            intro: "Testing with post date",
            author: "Author",
            postType: .post,
            urlString: "https://example.com",
            postPlatform: .youtube,
            postDate: postDate, // Установлена дата
            studyLevel: .beginner,
            progress: .fresh,
            favoriteChoice: .no,
            postRating: .good,
            notes: "Notes",
            origin: .local,
            draft: false,
            status: .active,
            date: testDate,
            addedDateStamp: nil,
            startedDateStamp: nil,
            studiedDateStamp: nil,
            practicedDateStamp: nil
        )
        
        // When
        let post = PostMigrationHelper.convertFromCodable(codablePost)
        
        // Then
        XCTAssertNotNil(post.postDate)
        XCTAssertEqual(post.postDate, postDate) // Должно быть равно переданной дате
        XCTAssertEqual(post.date, testDate) // Основная дата
        XCTAssertNotEqual(post.postDate, post.date) // postDate и date разные
    }

 
    
    func testPostMigrationHelperURLConversion() {
        // Given
        let urlString = "https://www.youtube.com/watch?v=abc123"
        let codablePost = CodablePost(
            id: "test-url",
            category: "Tutorial",
            title: "URL Test",
            intro: "Testing URL conversion",
            author: "Test Author",
            postType: .post,
            urlString: urlString,
            postPlatform: .youtube,
            postDate: Date(),
            studyLevel: .beginner,
            progress: .fresh,
            favoriteChoice: .yes,
            postRating: nil,
            notes: "Notes with URL",
            origin: .cloud,
            draft: false,
            status: .active,
            date: Date(),
            addedDateStamp: nil,
            startedDateStamp: nil,
            studiedDateStamp: nil,
            practicedDateStamp: nil
        )
        
        // When
        let post = PostMigrationHelper.convertFromCodable(codablePost)
        
        // Then
        XCTAssertNotNil(post.urlString)
        XCTAssertEqual(post.urlString, urlString)
        XCTAssertEqual(post.postPlatform, .youtube)
    }
    
    func testPostMigrationHelperDateHandling() {
        // Given
        let testDate = Date(timeIntervalSince1970: 1642675200) // 2022-01-20
        let codablePost = CodablePost(
            id: "test-date",
            category: "Dates",
            title: "Date Test",
            intro: "Testing date handling",
            author: "Test Author",
            postType: .post,
            urlString: "", // Не nil, а пустая строка
            postPlatform: .youtube, // Не nil, а дефолтное значение
            postDate: testDate,
            studyLevel: .middle,
            progress: .started,
            favoriteChoice: .yes,
            postRating: .good,
            notes: "Date test notes",
            origin: .local,
            draft: false,
            status: .active,
            date: testDate,
            addedDateStamp: testDate.addingTimeInterval(86400), // +1 day
            startedDateStamp: testDate.addingTimeInterval(172800), // +2 days
            studiedDateStamp: testDate.addingTimeInterval(259200), // +3 days
            practicedDateStamp: testDate.addingTimeInterval(345600) // +4 days
        )
        
        // When
        let post = PostMigrationHelper.convertFromCodable(codablePost)
        
        // Then
        XCTAssertNotNil(post.postDate)
        XCTAssertEqual(post.postDate, testDate)
        XCTAssertNotNil(post.addedDateStamp)
        XCTAssertNotNil(post.startedDateStamp)
        XCTAssertNotNil(post.studiedDateStamp)
        XCTAssertNotNil(post.practicedDateStamp)
        
        // Verify all dates are correctly copied
        XCTAssertEqual(post.postDate, codablePost.postDate)
        XCTAssertEqual(post.date, codablePost.date)
        XCTAssertEqual(post.addedDateStamp, codablePost.addedDateStamp)
        XCTAssertEqual(post.startedDateStamp, codablePost.startedDateStamp)
        XCTAssertEqual(post.studiedDateStamp, codablePost.studiedDateStamp)
        XCTAssertEqual(post.practicedDateStamp, codablePost.practicedDateStamp)
        
        // Verify relative dates (дополнительная проверка)
        let oneDay: TimeInterval = 86400
        XCTAssertEqual(post.addedDateStamp?.timeIntervalSince(testDate), oneDay)
        XCTAssertEqual(post.startedDateStamp?.timeIntervalSince(testDate), oneDay * 2)
        XCTAssertEqual(post.studiedDateStamp?.timeIntervalSince(testDate), oneDay * 3)
        XCTAssertEqual(post.practicedDateStamp?.timeIntervalSince(testDate), oneDay * 4)
    }
    
    // MARK: - JSONDecoder Tests
    
    func testJSONDecoderAppDecoderBasicDecoding() {
        // Given - ВСЕ обязательные поля должны присутствовать
        let json = """
        {
            "id": "test-id",
            "category": "SwiftUI",
            "title": "Test Title",
            "intro": "Test Intro",
            "author": "Test Author",
            "postType": "post",
            "urlString": "https://example.com",
            "postPlatform": "youtube",
            "postDate": "2024-01-20T10:30:00Z",
            "studyLevel": "beginner",
            "progress": "fresh",
            "favoriteChoice": "no",
            "postRating": null,
            "notes": "",
            "origin": "cloud",
            "draft": false,
            "date": "2024-01-20T10:30:00Z",
            "addedDateStamp": null,
            "startedDateStamp": null,
            "studiedDateStamp": null,
            "practicedDateStamp": null
        }
        """.data(using: .utf8)!
        
        print("Testing JSON decoding...")
        
        // When
        let decoder = JSONDecoder.appDecoder
        
        do {
            let codablePost = try decoder.decode(CodablePost.self, from: json)
            
            // Then
            XCTAssertEqual(codablePost.title, "Test Title")
            XCTAssertEqual(codablePost.studyLevel, .beginner)
            XCTAssertEqual(codablePost.favoriteChoice, .no)
            XCTAssertEqual(codablePost.origin, .cloud)
            XCTAssertEqual(codablePost.postPlatform, .youtube)
            XCTAssertEqual(codablePost.postType, .post)
            XCTAssertEqual(codablePost.progress, .fresh)
            XCTAssertEqual(codablePost.urlString, "https://example.com")
            XCTAssertEqual(codablePost.notes, "")
            XCTAssertEqual(codablePost.category, "SwiftUI")
            XCTAssertEqual(codablePost.intro, "Test Intro")
            XCTAssertEqual(codablePost.author, "Test Author")
            XCTAssertEqual(codablePost.draft, false)
            
            print("✅ Successfully decoded CodablePost")
            print("  Title: \(codablePost.title)")
            print("  StudyLevel: \(codablePost.studyLevel)")
            print("  FavoriteChoice: \(codablePost.favoriteChoice)")
            
        } catch {
            XCTFail("Failed to decode JSON: \(error)")
            print("❌ Decoding error: \(error)")
        }
    }

    func testJSONDecoderWithRealFormat() {
        // Given - Точная копия вашего реального JSON + добавлены недостающие обязательные поля
        let json = """
        {
            "id": "18F152F6-B9A7-43B5-ABCF-E116E3E9F51C",
            "category": "SwiftUI",
            "title": "SwiftUI Crypto App",
            "intro": "Build a cryptocurrency app that downloads live price data from an API and saves the current user's portfolio. Get comfortable with Combine, Core Data, and MVVM.",
            "author": "Nick Sarno/Swiftful Thinking",
            "postType": "course",
            "urlString": "https://www.youtube.com/playlist?list=PLwvDm4Vfkdphbc3bgy_LpLRQ9DDfFGcFu",
            "postPlatform": "youtube",
            "postDate": "2024-08-08T00:00:00Z",
            "studyLevel": "middle",
            "progress": "fresh",
            "favoriteChoice": "no",
            "postRating": null,
            "notes": "",
            "origin": "cloud",
            "draft": false,
            "date": "2026-01-16T16:16:08Z",
            "addedDateStamp": null,
            "startedDateStamp": null,
            "studiedDateStamp": null,
            "practicedDateStamp": null
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder.appDecoder
        
        do {
            let codablePost = try decoder.decode(CodablePost.self, from: json)
            
            // Then - Проверяем все поля
            XCTAssertEqual(codablePost.id, "18F152F6-B9A7-43B5-ABCF-E116E3E9F51C")
            XCTAssertEqual(codablePost.title, "SwiftUI Crypto App")
            XCTAssertEqual(codablePost.author, "Nick Sarno/Swiftful Thinking")
            XCTAssertEqual(codablePost.category, "SwiftUI")
            XCTAssertEqual(codablePost.postType, .course)
            XCTAssertEqual(codablePost.postPlatform, .youtube)
            XCTAssertEqual(codablePost.studyLevel, .middle)
            XCTAssertEqual(codablePost.progress, .fresh)
            XCTAssertEqual(codablePost.favoriteChoice, .no)
            XCTAssertEqual(codablePost.origin, .cloud)
            XCTAssertEqual(codablePost.notes, "")
            XCTAssertEqual(codablePost.draft, false)
            XCTAssertEqual(codablePost.urlString, "https://www.youtube.com/playlist?list=PLwvDm4Vfkdphbc3bgy_LpLRQ9DDfFGcFu")
            XCTAssertEqual(codablePost.intro, "Build a cryptocurrency app that downloads live price data from an API and saves the current user's portfolio. Get comfortable with Combine, Core Data, and MVVM.")
            
            // Optional поля должны быть nil
            XCTAssertNil(codablePost.postRating)
            XCTAssertNil(codablePost.addedDateStamp)
            XCTAssertNil(codablePost.startedDateStamp)
            XCTAssertNil(codablePost.studiedDateStamp)
            XCTAssertNil(codablePost.practicedDateStamp)
            
            // Проверяем даты
            let dateFormatter = ISO8601DateFormatter()
            
            if let postDate = codablePost.postDate {
                let postDateString = dateFormatter.string(from: postDate)
                XCTAssertTrue(postDateString.contains("2024-08-08"))
            } else {
                XCTFail("postDate should not be nil")
            }
            
            let dateString = dateFormatter.string(from: codablePost.date)
            XCTAssertTrue(dateString.contains("2026-01-16"))
            
            print("✅ Successfully decoded real JSON format")
            
        } catch {
            XCTFail("Failed to decode real JSON: \(error)")
            print("❌ Real JSON decoding error: \(error)")
            
            // Детальная информация об ошибке
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, _):
                    print("Missing key: \(key.stringValue)")
                default:
                    break
                }
            }
        }
    }

    // Тест для проверки всех enum значений
    func testJSONDecoderAllEnumValues() {
        let testCases: [(String, PostType, Platform, StudyLevel, StudyProgress, FavoriteChoice, PostOrigin)] = [
            ("post-youtube-beginner", .post, .youtube, .beginner, .fresh, .no, .cloud),
            ("article-website-middle", .post, .website, .middle, .started, .yes, .local),
            ("course-medium-advanced", .course, .website, .advanced, .studied, .yes, .cloudNew)
        ]
        
        for (description, postType, platform, level, progress, favorite, origin) in testCases {
            print("\nTesting: \(description)")
            
            let json = """
            {
                "id": "test-\(description)",
                "category": "Test",
                "title": "Test \(description)",
                "intro": "Intro",
                "author": "Author",
                "postType": "\(postType.rawValue)",
                "urlString": "https://example.com",
                "postPlatform": "\(platform.rawValue)",
                "postDate": "2024-01-20T10:30:00Z",
                "studyLevel": "\(level.rawValue)",
                "progress": "\(progress.rawValue)",
                "favoriteChoice": "\(favorite.rawValue)",
                "postRating": "good",
                "notes": "Notes",
                "origin": "\(origin.rawValue)",
                "draft": false,
                "date": "2024-01-20T10:30:00Z"
            }
            """.data(using: .utf8)!
            
            let decoder = JSONDecoder.appDecoder
            
            do {
                let codablePost = try decoder.decode(CodablePost.self, from: json)
                
                XCTAssertEqual(codablePost.postType, postType)
                XCTAssertEqual(codablePost.postPlatform, platform)
                XCTAssertEqual(codablePost.studyLevel, level)
                XCTAssertEqual(codablePost.progress, progress)
                XCTAssertEqual(codablePost.favoriteChoice, favorite)
                XCTAssertEqual(codablePost.origin, origin)
                XCTAssertEqual(codablePost.postRating, .good)
                
                print("✅ \(description): All enums decoded correctly")
                
            } catch {
                XCTFail("Failed to decode \(description): \(error)")
            }
        }
    }

    // Тест на обработку ошибок
    func testJSONDecoderErrorHandling() {
        let invalidJsons = [
            ("missing required field", """
            {
                "id": "test",
                "title": "Test"
                // Отсутствуют другие обязательные поля
            }
            """),
            
            ("invalid enum value", """
            {
                "id": "test",
                "category": "Test",
                "title": "Test",
                "intro": "",
                "author": "",
                "postType": "invalid_type",
                "urlString": "",
                "postPlatform": "youtube",
                "studyLevel": "beginner",
                "progress": "fresh",
                "favoriteChoice": "no",
                "notes": "",
                "origin": "cloud",
                "draft": false,
                "date": "2024-01-20T10:30:00Z"
            }
            """),
            
            ("invalid date format", """
            {
                "id": "test",
                "category": "Test",
                "title": "Test",
                "intro": "",
                "author": "",
                "postType": "post",
                "urlString": "",
                "postPlatform": "youtube",
                "postDate": "not-a-date",
                "studyLevel": "beginner",
                "progress": "fresh",
                "favoriteChoice": "no",
                "notes": "",
                "origin": "cloud",
                "draft": false,
                "date": "not-a-date"
            }
            """)
        ]
        
        for (description, jsonString) in invalidJsons {
            print("\nTesting error case: \(description)")
            
            guard let json = jsonString.data(using: .utf8) else {
                XCTFail("Failed to create JSON data")
                continue
            }
            
            let decoder = JSONDecoder.appDecoder
            
            do {
                let _ = try decoder.decode(CodablePost.self, from: json)
                XCTFail("Should have thrown error for: \(description)")
            } catch {
                print("✅ Expected error for \(description): \(error.localizedDescription)")
                // Тест проходит - ошибка ожидаема
            }
        }
    }
    func testJSONDecoderAppDecoderWithMissingOptionalFields() {
        // Given - Указываем ВСЕ обязательные поля, optional можем пропустить
        let json = """
        {
            "id": "test-minimal",
            "category": "Test",
            "title": "Minimal Test",
            "intro": "",
            "author": "",
            "postType": "post",
            "urlString": "",
            "postPlatform": "youtube",
            "studyLevel": "beginner",
            "progress": "fresh",
            "favoriteChoice": "no",
            "notes": "",
            "origin": "local",
            "draft": true,
            "date": "2024-01-20T10:30:00Z"
        }
        """.data(using: .utf8)!
        
        print("Testing JSON with minimal required fields...")
        
        // When
        let decoder = JSONDecoder.appDecoder
        let codablePost = try? decoder.decode(CodablePost.self, from: json)
        
        // Then
        XCTAssertNotNil(codablePost, "Should decode successfully with all required fields")
        
        if let post = codablePost {
            XCTAssertEqual(post.id, "test-minimal")
            XCTAssertEqual(post.title, "Minimal Test")
            XCTAssertEqual(post.category, "Test")
            XCTAssertEqual(post.postType, .post)
            XCTAssertEqual(post.draft, true)
            XCTAssertEqual(post.origin, .local)
            XCTAssertEqual(post.urlString, "")
            XCTAssertEqual(post.postPlatform, .youtube)
            XCTAssertEqual(post.studyLevel, .beginner)
            XCTAssertEqual(post.progress, .fresh)
            XCTAssertEqual(post.favoriteChoice, .no)
            XCTAssertEqual(post.notes, "")
            
            // Optional поля должны быть nil (так как их нет в JSON)
            XCTAssertNil(post.postDate)
            XCTAssertNil(post.postRating)
            XCTAssertNil(post.addedDateStamp)
            XCTAssertNil(post.startedDateStamp)
            XCTAssertNil(post.studiedDateStamp)
            XCTAssertNil(post.practicedDateStamp)
            
            print("✅ Successfully decoded with minimal fields")
        }
    }
    
    func testJSONDecoderAppDecoderWithInvalidData() {
        // Given
        let invalidJson = """
        {
            "id": "test-invalid",
            "title": 123, // Invalid: should be string
            "date": "not-a-date"
        }
        """.data(using: .utf8)!
        
        // When/Then
        let decoder = JSONDecoder.appDecoder
        XCTAssertThrowsError(try decoder.decode(CodablePost.self, from: invalidJson)) { error in
            // Verify it's a decoding error
            XCTAssertTrue(error is DecodingError)
        }
    }
    
    func testJSONDecoderAppDecoderDateFormat() {
        // Given - Добавляем ВСЕ обязательные поля
        let json = """
        {
            "id": "test-date-format",
            "category": "Test",
            "title": "Date Format Test",
            "intro": "Test",
            "author": "Author",
            "postType": "post",
            "urlString": "https://example.com",
            "postPlatform": "youtube",
            "postDate": "2024-01-20T10:30:00+00:00",
            "studyLevel": "beginner",
            "progress": "fresh",
            "favoriteChoice": "no",
            "postRating": null,
            "notes": "",
            "origin": "cloud",
            "draft": false,
            "date": "2024-01-20T10:30:00Z",
            "addedDateStamp": "2024-01-21T08:15:30Z",
            "startedDateStamp": null,
            "studiedDateStamp": null,
            "practicedDateStamp": null
        }
        """.data(using: .utf8)!
        
        print("Testing date format parsing...")
        
        // When
        let decoder = JSONDecoder.appDecoder
        let codablePost = try? decoder.decode(CodablePost.self, from: json)
        
        // Then
        XCTAssertNotNil(codablePost, "Should decode successfully")
        
        if let post = codablePost {
            XCTAssertNotNil(post.date)
            XCTAssertNotNil(post.postDate)
            XCTAssertNotNil(post.addedDateStamp)
            
            print("Decoded dates:")
            print("  date: \(post.date)")
            print("  postDate: \(String(describing: post.postDate))")
            print("  addedDateStamp: \(String(describing: post.addedDateStamp))")
            
            // Verify dates are parsed correctly
            let dateFormatter = ISO8601DateFormatter()
            
            let dateString = dateFormatter.string(from: post.date)
            XCTAssertTrue(dateString.contains("2024-01-20T10:30:00"),
                         "date should be 2024-01-20T10:30:00, got: \(dateString)")
            
            if let postDate = post.postDate {
                let postDateString = dateFormatter.string(from: postDate)
                XCTAssertTrue(postDateString.contains("2024-01-20T10:30:00"),
                             "postDate should be 2024-01-20T10:30:00, got: \(postDateString)")
            }
            
            if let addedStamp = post.addedDateStamp {
                let addedString = dateFormatter.string(from: addedStamp)
                XCTAssertTrue(addedString.contains("2024-01-21T08:15:30"),
                             "addedDateStamp should be 2024-01-21T08:15:30, got: \(addedString)")
            }
            
            // Проверяем разницу во времени (исправляем вычисление)
            if let postDate = post.postDate, let addedStamp = post.addedDateStamp {
                // Вычисляем ожидаемую разницу по частям
                let oneDay: TimeInterval = 86400
                let twoHours: TimeInterval = 2 * 3600
                let fourteenMinutes: TimeInterval = 14 * 60
                let thirtySeconds: TimeInterval = 30
                
                let expectedDifference = oneDay - twoHours - fourteenMinutes - thirtySeconds
                
                let actualDifference = addedStamp.timeIntervalSince(postDate)
                
                XCTAssertEqual(actualDifference, expectedDifference, accuracy: 1.0,
                              "Time difference should be ~\(expectedDifference) seconds, got \(actualDifference)")
                
                print("Time difference: \(actualDifference) seconds")
                print("Expected: \(expectedDifference) seconds")
            }
            
            print("✅ Date formats parsed correctly")
        }
    }

    func testJSONDecoderAppDecoderEnumValues() {
        // Given
        let json = """
        {
            "id": "test-date-format",
            "category": "Test",
            "title": "Date Format Test",
            "intro": "Test",
            "author": "Author",
            "postType": "post",
            "urlString": "https://example.com",
            "postPlatform": "youtube",
            "postDate": "2024-01-20T10:30:00+00:00",
            "studyLevel": "advanced",
            "progress": "started",
            "favoriteChoice": "no",
            "postRating": null,
            "notes": "",
            "origin": "cloud",
            "draft": false,
            "date": "2024-01-20T10:30:00Z",
            "addedDateStamp": "2024-01-21T08:15:30Z",
            "startedDateStamp": null,
            "studiedDateStamp": null,
            "practicedDateStamp": null
        }
        """.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder.appDecoder
        let codablePost = try? decoder.decode(CodablePost.self, from: json)
        
        // Then
        XCTAssertNotNil(codablePost)
        XCTAssertEqual(codablePost?.postType, .post)
        XCTAssertEqual(codablePost?.postPlatform, .youtube)
        XCTAssertEqual(codablePost?.studyLevel, .advanced)
        XCTAssertEqual(codablePost?.progress, .started)
        XCTAssertEqual(codablePost?.favoriteChoice, .no)
        XCTAssertEqual(codablePost?.origin, .cloud)
    }
    
    // MARK: - Performance Tests
    
    func testPostMigrationPerformance() {
        // Given
        var codablePosts: [CodablePost] = []
        
        for i in 0..<500 {
            let postRating: PostRating?
            if i % 5 == 0 {
                let ratings: [PostRating] = [.good, .great, .excellent]
                postRating = ratings[i % 3]
            } else {
                postRating = nil
            }
            
            let origins: [PostOrigin] = [.local, .cloud, .cloudNew]
            let post = CodablePost(
                id: "test-\(i)",
                category: "Category \(i % 5)",
                title: "Title \(i)",
                intro: "Intro \(i)",
                author: "Author \(i % 10)",
                postType: i % 2 == 0 ? .post : .course,
                urlString: i % 3 == 0 ? "https://example.com/\(i)" : "",
                postPlatform: [.youtube, .website][i % 2],
                postDate: Date().addingTimeInterval(Double(i) * -86400),
                studyLevel: [.beginner, .middle, .advanced][i % 3],
                progress: [.fresh, .started, .studied, .practiced][i % 4],
                favoriteChoice: [.yes, .no][i % 2],
                postRating: postRating,
                notes: i % 10 == 0 ? "Notes \(i)" : "",
                origin: origins[i % origins.count],
                draft: i % 7 == 0,
                status: .active,
                date: Date(),
                addedDateStamp: Date().addingTimeInterval(Double(i) * -3600),
                startedDateStamp: i % 3 == 0 ? Date().addingTimeInterval(Double(i) * -7200) : nil,
                studiedDateStamp: i % 4 == 0 ? Date().addingTimeInterval(Double(i) * -10800) : nil,
                practicedDateStamp: i % 5 == 0 ? Date().addingTimeInterval(Double(i) * -14400) : nil
            )
            codablePosts.append(post)
        }
        
        // When/Then
        measure {
            let posts = codablePosts.map { PostMigrationHelper.convertFromCodable($0) }
            XCTAssertEqual(posts.count, 500)
        }
    }
    
    func testJSONDecodingPerformance() {
        // Given
        let jsonArray = (0..<100).map { i in """
            {
                "id": "perf-test-\(i)",
                "category": "Cat \(i % 5)",
                "title": "Performance Test \(i)",
                "intro": "Intro for test \(i)",
                "author": "Author \(i % 10)",
                "postType": "post",
                "urlString": "https://test.com/\(i)",
                "postPlatform": "youtube",
                "postDate": "2024-01-20T10:30:00Z",
                "studyLevel": "beginner",
                "progress": "fresh",
                "favoriteChoice": "no",
                "postRating": null,
                "notes": "Notes for test \(i)",
                "origin": "cloud",
                "draft": false,
                "date": "2024-01-20T10:30:00Z",
                "addedDateStamp": null,
                "startedDateStamp": null,
                "studiedDateStamp": null,
                "practicedDateStamp": null
            }
            """
        }
        
        let jsonData = "[\(jsonArray.joined(separator: ","))]".data(using: .utf8)!
        
        print("Testing JSON decoding performance for 100 posts...")
        
        // When/Then
        measure {
            let decoder = JSONDecoder.appDecoder
            let posts = try? decoder.decode([CodablePost].self, from: jsonData)
            XCTAssertEqual(posts?.count, 100)
            
            // Быстрая проверка что данные корректны
            if let firstPost = posts?.first {
                XCTAssertEqual(firstPost.title, "Performance Test 0")
                XCTAssertEqual(firstPost.postPlatform, .youtube)
            }
        }
        
        print("✅ Performance test completed")
    }}
