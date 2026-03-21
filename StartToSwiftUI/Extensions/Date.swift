//
//  Date.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 24.10.2025.
//

import Foundation

extension Date {
    
    static func from(year: Int, month: Int, day: Int, hour: Int = 1, minute: Int = 8) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? Date()
    }
}
