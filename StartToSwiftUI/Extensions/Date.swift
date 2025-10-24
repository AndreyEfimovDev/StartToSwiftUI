//
//  Date.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 24.10.2025.
//

import Foundation

extension Date {
    static func from(year: Int, month: Int, day: Int) -> Date? {
        
        // "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        var utcCalendar = Calendar.current
        if let utcTimeZone = TimeZone(secondsFromGMT: 0) {
            utcCalendar.timeZone = utcTimeZone
            
        }
        
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.timeZone = utcCalendar.timeZone
        
        return utcCalendar.date(from: components)
    }
}
