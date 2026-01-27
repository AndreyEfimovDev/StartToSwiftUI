//
//  Calendar.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 13.01.2026.
//

import Foundation

// MARK: - Helper Extension
extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}

