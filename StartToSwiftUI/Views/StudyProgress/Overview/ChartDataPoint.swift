//
//  ChartDataPoint.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 13.01.2026.
//

import Foundation

// MARK: - Data for Chart
struct ChartDataPoint: Identifiable {
    let id = UUID()
    let month: Date
    let type: StudyProgress
    let count: Int
    
    var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: month)
    }
}
