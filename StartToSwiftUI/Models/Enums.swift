//
//  Enums.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 31.08.2025.
//

import Foundation
import SwiftUI

// MARK: Colour scheme

enum Theme: String, CaseIterable, Codable {
    case light
    case dark
    case system

    var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .system: return "System"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

// MARK: Tabs to shift study levels in StudyProgressView

enum StudyLevelTabs: String, CaseIterable, Codable, Hashable {
    case all
    case beginner
    case middle
    case advanced
    
    var displayName: String {
        studyLevel?.displayName ?? "All"
    }
    
    var studyLevel: StudyLevel? {
        switch self {
        case .all: return nil
        case .beginner: return .beginner
        case .middle: return .middle
        case .advanced: return .advanced
        }
    }
}

// MARK: Sorting options

enum SortOption: String, CaseIterable {
    case newestFirst
    case oldestFirst
    
    var displayName: String {
        switch self {
        case .newestFirst: return "Newest"
        case .oldestFirst: return "Oldest"
        }
    }
}

// MARK: Focusing post fields in AddEditPostView

enum PostFields: Hashable {
    case postTitle
    case intro
    case author
    case postType
    case studyLevel
    case platform
    case postDate
    case urlString
    case notes
}

// MARK: Enums for Post model


enum Platform: String, CaseIterable, Codable {
    case youtube
    case website
    
    var displayName: String {
        switch self {
        case .youtube: return "Video"
        case .website: return "Article"
        }
    }
}

enum PostType: String, CaseIterable, Codable {
    case post
    case course
    case article
    case solution  // для обратной совместимости
    case bug
    case other
    
    var displayName: String {
        switch self {
        case .post: return "Lesson"
        case .course: return "Course"
        case .article: return "Article"
        case .solution: return "Article"  // показываем как Article
        case .bug: return "Bug"
        case .other: return "Other"
        }
    }
    // Исключаем solution из выбора в UI
    static var selectablePostTypeCases: [PostType] {
        [.post, .course, .article, .bug, .other]
    }

}


enum PostStatus: String, CaseIterable, Codable {
    case active
    case hidden
    case deleted
}

enum PostOrigin: String, CaseIterable, Codable {
    case local
    case cloud
    case cloudNew
    
    var icon: Image {
        switch self {
        case .local: return Image(systemName: "archivebox") // tray cube  archivebox folder arrow.up.folder text.document
        case .cloud: return Image(systemName: "cloud")
        case .cloudNew: return Image(systemName: "cloud.fill")
        }
    }
}

enum FavoriteChoice: String, CaseIterable, Codable {
    case no
    case yes
    
    var displayName: String {
        switch self {
        case .no: return "No"
        case .yes: return "Yes"
        }
    }

    var icon: Image {
        switch self {
        case .yes: return Image(systemName: "star")
        case .no: return Image(systemName: "star.fill")
        }
    }
}

enum PostRating: String, CaseIterable, Codable {
    case good, great, excellent
    
    var displayName: String {
        switch self {
        case .good: return "Good"
        case .great: return "Great"
        case .excellent: return "Excellent"
        }
    }
    
    var icon: Image { // for other options look at TestSFSymbolsForRating
        switch self {
        case .good: return Image(systemName: "face.smiling")
        case .great: return Image(systemName: "star.fill")
        case .excellent: return Image(systemName: "crown.fill")
        }
    }
    
    var value: Int {
        switch self {
        case .good: return 1
        case .great: return 2
        case .excellent: return 3
        }
    }
    
    var color: Color {
        switch self {
        case .good: return Color.mycolor.myBlue
        case .great: return Color.mycolor.myGreen
        case .excellent: return Color.mycolor.myPurple
        }
    }
}

enum StudyLevel: String, CaseIterable, Codable {
    case beginner
    case middle
    case advanced
    
    var displayName: String {
        switch self {
        case .beginner: return "Beginner"
        case .middle: return "Intermediate"
        case .advanced: return "Advanced"
        }
    }
    
    var color: Color {
        switch self {
        case .beginner: return Color.mycolor.myGreen
        case .middle: return Color.mycolor.myBlue
        case .advanced: return Color.mycolor.myRed
        }
    }
}

// MARK: - Type of progress
enum StudyProgress: String, CaseIterable, Codable { // progress in mastering educational materials
    case added, started, studied, practiced
    
    // 􀐾 chart.bar, 􀓎 hare, 􁗟 bird, 􁝯 tree, 􀑁 chart.line.uptrend.xyaxis
    
    var displayName: String {
        switch self {
        case .added: return "Added"
        case .started: return "Started"
        case .studied: return "Learnt"
        case .practiced: return "Practiced"
        }
    }
    
    var icon: Image { // for other options look at TestSFSymbolsForProgress
        switch self {
        case .added: return Image(systemName: "square.and.arrow.down") // lightbulb signpost.right sparkles
        case .started: return Image(systemName: "sunrise") // sunrise signpost.right
        case .studied: return Image(systemName: "bolt") // brain.head.profile flag.checkered
        case .practiced: return Image(systemName: "flag.checkered") // hand.raised.fingers.spread mountain.2.fill bolt
        }
    }
    
    var color: Color {
        switch self {
        case .added: return Color.mycolor.myGreen
        case .started: return Color.mycolor.myPurple
        case .studied: return Color.mycolor.myBlue
        case .practiced: return Color.mycolor.myRed
        }
    }
}


// MARK: - Time periods for statistics
enum TimePeriod: String, CaseIterable, Identifiable {
    case quarter
    case halfYear
    case year
    case twoYears
    case threeYears
    
    var id: String { rawValue }
    
    var months: Int {
        switch self {
        case .quarter: return 3
        case .halfYear: return 6
        case .year: return 12
        case .twoYears: return 24
        case .threeYears: return 36
        }
    }
    
    var displayName: String {
        switch self {
        case .quarter: return "3M"
        case .halfYear: return "6M"
        case .year: return "12M"
        case .twoYears: return "24M"
        case .threeYears: return "36M"
        }
    }

}
// MARK: - Network Errors
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponseStatus
    case dataTaskError(String)
    case corruptData
    case decodingError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("The endpoint URL is invalid", comment: "")
        case .invalidResponseStatus:
            return NSLocalizedString("The APIO failed to issue a valid response.", comment: "")
        case .dataTaskError(let string):
            return string
        case .corruptData:
            return NSLocalizedString("The data provided appears to be corrupt", comment: "")
        case .decodingError(let string):
            return string
        }
    }
}


// MARK: - Debug print states + func
enum LogLevel {
    case debug, info, warning, error
    
    var icon: String {
        switch self {
        case .debug: return "🔥"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        }
    }
}



// MARK: - File Storage Errors

enum FileStorageError: LocalizedError {
    case fileNotFound
    case invalidURL
    case encodingFailed(Error)
    case decodingFailed(Error)
    case fileSystemError(Error)
    case exportError(String)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "File not found"
        case .invalidURL:
            return "Invalid file URL"
        case .encodingFailed(let error):
            return "Encoding failed: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Decoding failed: \(error.localizedDescription)"
        case .fileSystemError(let error):
            return "File system error: \(error.localizedDescription)"
        case .exportError(let message):
            return message
        }
    }
}


// MARK: - Navigation Routes
enum AppRoute: Hashable, Identifiable {
    
    // Dealing with details
    case postDetails(postId: String) // postId - associated value
    
    // Adding and editing posts
    case addPost
    case editPost(Post)
        
    // Preferences
    case preferences
    
    // Managing notices
    case notices // called from HomeView and Preferences
    case noticeDetails(noticeId: String)

    // Study progress
    case studyProgress
    
    // Managing posts
    case postDrafts
    case checkForUpdates
    case importFromCloud
    case shareBackup
    case restoreBackup
    case erasePosts
    
    // Gratitude
    case acknowledgements
    
    // About App
    case aboutApp
    case welcome
    case introduction
    case functionality
    case whatIsNew
    
    // Legal information
    case legalInfo
    case termsOfUse
    case privacyPolicy
    case copyrightPolicy
    case fairUseNotice
    
    // Set root modal Views to manage different behaviour
    var isRootModal: Bool {
        switch self {
        case .preferences, .notices, .aboutApp, .legalInfo:
            return true  // These items open as root modal Views
        default:
            return false // Other open inside other modal Views
        }
    }

    var id: String {
        switch self {
        case .postDetails(let postId):
            return "postDetails_\(postId)"
        case .addPost:
            return "addPost"
        case .editPost(let post):
            return "editPost_\(post.id)"
        case .preferences:
            return "preferences"
        case .notices:
            return "notices"
        case .noticeDetails(let noticeId):
            return "noticeDetails_\(noticeId)"
        case .studyProgress:
            return "studyProgress"
        case .postDrafts:
            return "postDrafts"
        case .checkForUpdates:
            return "checkForUpdates"
        case .importFromCloud:
            return "importFromCloud"
        case .shareBackup:
            return "shareBackup"
        case .restoreBackup:
            return "restoreBackup"
        case .erasePosts:
            return "erasePosts"
        case .acknowledgements:
            return "acknowledgements"
        case .aboutApp:
            return "aboutApp"
        case .welcome:
            return "welcome"
        case .introduction:
            return "introduction"
        case .functionality:
            return "functionality"
        case .whatIsNew:
            return "whatIsNew"
        case .legalInfo:
            return "legalInfo"
        case .termsOfUse:
            return "termsOfUse"
        case .privacyPolicy:
            return "privacyPolicy"
        case .copyrightPolicy:
            return "copyrightPolicy"
        case .fairUseNotice:
            return "fairUseNotice"
        }
    }
}


//var id: String {
//    switch self {
//    case .postDetails(let postId): return "postDetails_\(postId)"
//    case .editPost(let post): return "editPost_\(post.id)"
//    case .noticeDetails(let noticeId): return "noticeDetails_\(noticeId)"
//    default: return String(describing: self)
//    }
//}

