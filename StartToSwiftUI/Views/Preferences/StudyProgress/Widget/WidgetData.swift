//
//  WidgetData.swift
//  StudyProgressWidget
//
//  Created by Andrey Efimov on 26.01.2026.
//

import Foundation

/// Shared data structure for widget
/// Used to pass study progress from main app to widget
struct StudyProgressData: Codable {
  
    let freshCount: Int
    let startedCount: Int
    let studiedCount: Int
    let practicedCount: Int
    let lastUpdated: Date
    
    var totalCount: Int {
            freshCount
        }
    
//    var completedCount: Int {
//        practicedCount
//    }
    
//    var inProgressCount: Int {
//        startedCount + studiedCount
//    }
    
    var completionPercentage: Double {
        guard totalCount > 0 else { return 0 }
        return Double(practicedCount) / Double(totalCount) * 100
    }
    
    var progressPercentage: Double { // startedCount + studiedCount + practicedCount
        guard totalCount > 0 else { return 0 }
        return Double(startedCount + studiedCount + practicedCount) / Double(totalCount) * 100
    }
    
    static let empty = StudyProgressData(
        
        freshCount: 0,
        startedCount: 0,
        studiedCount: 0,
        practicedCount: 0,
        lastUpdated: Date()
    )
    
    static let preview = StudyProgressData(
        
        freshCount: 25,
        startedCount: 7,
        studiedCount: 5,
        practicedCount: 5,
        lastUpdated: Date()
    )
}

/// App Group identifier for sharing data between app and widget
enum AppGroupConfig {
    static let suiteName = "group.PELSH.StartToSwiftUI"
    static let widgetDataKey = "studyProgressWidgetData"
}

/// Helper class for reading/writing widget data
final class WidgetDataManager {
    
    static let shared = WidgetDataManager()
    
    private let userDefaults: UserDefaults?
    
    private init() {
        userDefaults = UserDefaults(suiteName: AppGroupConfig.suiteName)
    }
    
    func saveProgressData(_ data: StudyProgressData) {
        guard let userDefaults = userDefaults else { return }
        
        if let encoded = try? JSONEncoder().encode(data) {
            userDefaults.set(encoded, forKey: AppGroupConfig.widgetDataKey)
            userDefaults.synchronize()
        }
    }
    
    func loadProgressData() -> StudyProgressData {
        guard let userDefaults = userDefaults,
              let data = userDefaults.data(forKey: AppGroupConfig.widgetDataKey),
              let decoded = try? JSONDecoder().decode(StudyProgressData.self, from: data)
        else {
            return .empty
        }
        return decoded
    }
}
