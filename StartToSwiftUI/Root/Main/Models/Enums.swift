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
    case light, dark, system

    var displayName: String {
        switch self {
        case .light: return "🌞 Light"
        case .dark: return "🌙 Dark"
        case .system: return "⚙️ System"
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
        case .course: return "Collection"
        case .solution: return "Solution"
        case .bug: return "Bug"
        case .other: return "Other"
        }
    }
}

enum PostOrigin: String, CaseIterable, Codable {
    case local
    case cloud
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
