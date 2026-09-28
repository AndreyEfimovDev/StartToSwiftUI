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

// MARK: - Calendar date (postDate)
//
// postDate — дата без времени ("опубликовано 11 апреля"). Договорённость:
// хранится как 12:00 UTC этого дня, показывается и сравнивается в UTC.
// Тогда день одинаков в любом часовом поясе. (Полдень, а не полночь, —
// страховка: даже показанный по местному времени, он остаётся тем же днём
// почти во всех поясах.)

extension Calendar {
    /// Календарь для дат без времени (`postDate`): григорианский, в UTC.
    static let calendarDate: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return calendar
    }()
}

extension Date {

    /// Календарная дата — 12:00 UTC указанного дня.
    ///
    /// - Returns: `nil`, если такой даты нет.
    static func calendarDate(year: Int, month: Int, day: Int) -> Date? {
        DateComponents(calendar: .calendarDate, year: year, month: month, day: day, hour: 12).date
    }

    /// Тот же календарный день, что у этой даты в `calendar`, как 12:00 UTC.
    ///
    /// - Parameter calendar: Календарь (часовой пояс), в котором берётся день:
    ///   `.current` — день, который видит пользователь; `.calendarDate` — день
    ///   значения из DatePicker, работающего в UTC.
    /// - Returns: 12:00 UTC этого дня.
    func calendarDateNoonUTC(in calendar: Calendar) -> Date {
        let day = calendar.dateComponents([.year, .month, .day], from: self)
        return DateComponents(
            calendar: .calendarDate,
            year: day.year, month: day.month, day: day.day, hour: 12
        ).date ?? self
    }

    /// Календарная дата для показа (числовой формат, без времени) — в UTC.
    var calendarDateText: String {
        formatted(Date.FormatStyle(date: .numeric, time: .omitted, timeZone: .gmt))
    }
}
