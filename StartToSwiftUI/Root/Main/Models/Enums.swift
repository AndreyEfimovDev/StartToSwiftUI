//
//  Enums.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 31.08.2025.
//

import Foundation
import SwiftUI

enum LanguageOptions: String, CaseIterable, Codable {
    case english
    case russian
    
    var displayName: String {
        switch self {
        case .english: return "EN"
        case .russian: return "RU"
        }
    }
}

enum FavoriteChoice: String, CaseIterable, Codable {
    case yes
    case no
    
    var displayName: String {
        switch self {
        case .yes: return "Yes"
        case .no: return "No"
        }
    }

    var icon: Image {
        switch self {
        case .yes: return Image(systemName: "star")
//                .font(.body)
//                .foregroundStyle(Color.mycolor.yellow)
//                .frame(width: 30, height: 30)
        case .no: return Image(systemName: "star.fill")
//                .font(.body)
//                .foregroundStyle(Color.mycolor.secondaryText)
//                .frame(width: 30, height: 30)
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
        case .middle: return Color.mycolor.middle
        case .advanced: return Color.mycolor.myRed
        }
    }
}

enum Platform: String, CaseIterable, Codable {
    case youtube = "YouTube"
    case website = "WebSite"
    case others = "Others"
    
    var displayName: String {
        switch self {
        case .youtube: return "YouTube"
        case .website: return "WebSite"
        case .others: return "Others"
        }
    }
}


enum Theme: String, CaseIterable, Codable {
    case light, dark, system
    
    var displayName: String { rawValue.capitalized }
    
    var displayName2: String {
        switch self {
        case .light: return "🌞 Light"
        case .dark: return "🌙 Dark"
        case .system: return "⚙️ System"
        }
    }
}


