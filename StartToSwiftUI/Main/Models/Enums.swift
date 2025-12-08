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

// MARK: Sorting option

enum SortOption: String, CaseIterable {
    case newestFirst
    case oldestFirst
    case random
    
    var displayName: String {
        switch self {
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
    case urlString
    case additionalInfo
//    case postDate
}


// MARK: - DataModel Errors

enum PostType: String, CaseIterable, Codable {
    case post
    case course
    case solution
    case bug
    case other
    
    var displayName: String {
        switch self {
        case .post: return "Single"
        case .course: return "Course"
        case .solution: return "Solution"
        case .bug: return "Bug"
        case .other: return "Other"
        }
    }
}

enum PostOrigin: String, CaseIterable, Codable {
    case local
    case cloud
    case statical
    
    var icon: Image {
        switch self {
        case .local: return Image(systemName: "archivebox") // tray cube  archivebox folder arrow.up.folder text.document
        case .cloud: return Image(systemName: "cloud")
        case .statical: return Image(systemName: "arrow.2.squarepath") // line.3.horizontal square.grid.2x2 s.circle arrow.2.squarepath
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

enum StudyProgress: String, CaseIterable, Codable { // progress in mastering educational materials
    case fresh, studied, practiced
    
    // 􀐾 chart.bar, 􀓎 hare, 􁗟 bird, 􁝯 tree, 􀑁 chart.line.uptrend.xyaxis
    
    var displayName: String {
        switch self {
        case .fresh: return "New"
        case .studied: return "Studied"
        case .practiced: return "Practiced"
        }
    }
    
    var icon: Image { // for other options look at TestSFSymbolsForProgress
        switch self {
        case .fresh: return Image(systemName: "signpost.right") // lightbulb signpost.right
        case .studied: return Image(systemName: "flag.checkered") // brain.head.profile flag.checkered
        case .practiced: return Image(systemName: "mountain.2.fill") // hand.raised.fingers.spread mountain.2.fill
        }
    }
    
    var color: Color {
        switch self {
        case .fresh: return Color.mycolor.myGreen
        case .studied: return Color.mycolor.myBlue
        case .practiced: return Color.mycolor.myRed
        }
    }

}

enum Platform: String, CaseIterable, Codable {
    case youtube
    case website
//    case others
    
    var displayName: String {
        switch self {
        case .youtube: return "YouTube"
        case .website: return "Website"
//        case .others: return "Others"
        }
    }
}

// MARK: - Network Errors

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case noData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .noData:
            return "No data received"
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
        }
    }
}
