//
//  Enums.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 31.08.2025.
//

import Foundation
import SwiftUI

//enum LanguageOptions: String, CaseIterable, Codable {
//    case english
//    case russian
//    
//    var displayName: String {
//        switch self {
//        case .english: return "EN"
//        case .russian: return "RU"
//        }
//    }
//}

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
    
//    var displayName: String {
//        switch self {
//        case .local: return "Local"
//        case .cloud: return "Cloud"
//        }
//    }
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
    case others
    
    var displayName: String {
        switch self {
        case .youtube: return "YouTube"
        case .website: return "Website"
        case .others: return "Others"
        }
    }
}


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


// for AddEditPostView
enum PostFields: Hashable {
    case postTitle
    case intro
    case author
    case urlString
    case additionalInfo
//    case postDate
}
