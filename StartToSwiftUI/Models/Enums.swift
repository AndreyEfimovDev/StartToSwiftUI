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
    case notSorted
    case newestFirst
    case oldestFirst
    case random
    
    var displayName: String {
        switch self {
        case .notSorted: return "Original"
        case .newestFirst: return "Newest"
        case .oldestFirst: return "Oldest"
        case .random: return "Random"
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
    
    var displayName: String {
        switch self {
        case .active: return "Active"
        case .hidden: return "Hidden"
        case .deleted: return "Deleted"
        }
    }

}

enum PostOrigin: String, CaseIterable, Codable {
    case local
    case cloud
    case cloudNew
    
    var icon: Image {
        switch self {
        case .local: return Image(systemName: "person")
        case .cloud: return Image(systemName: "cloud")
        case .cloudNew: return Image(systemName: "cloud.sun")
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
        case .no: return Image(systemName: "star.slash")
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
    
    var icon: Image {
        switch self {
        case .good: return Image(systemName: "hand.thumbsup")
        case .great: return Image(systemName: "star")
        case .excellent: return Image(systemName: "crown")
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
        case .middle: return "Middle"
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
// 􀐾 chart.bar, 􀓎 hare, 􁗟 bird, 􁝯 tree, 􀑁 chart.line.uptrend.xyaxis
enum StudyProgress: String, CaseIterable, Codable, Hashable {
    case added, started, studied, practiced
    
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
        case .added: return Image(systemName: "plus")
        case .started: return Image(systemName: "sunrise")
        case .studied: return Image(systemName: "bolt")
        case .practiced: return Image(systemName: "flag.checkered")
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
