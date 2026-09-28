//
//  ChartDataPoint.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 13.01.2026.
//

import Foundation

// MARK: - Data for Chart
struct ChartDataPoint: Identifiable {
    let month: Date
    let type: StudyProgress
    let count: Int

    // Стабильный id из месяца и типа: с UUID() каждая перерисовка давала
    // новые id, и Charts считал все точки новыми (без плавной анимации).
    var id: String { "\(month.timeIntervalSince1970)-\(type.rawValue)" }
}

// MARK: - Chart Data Generation
extension ChartDataPoint {

    /// Строит точки графика: для каждого месяца периода (от `period.months`
    /// месяцев назад до текущего включительно) — сколько постов начато,
    /// изучено и отработано в этом месяце (по датам этапов, без Added).
    ///
    /// - Parameters:
    ///   - posts: Посты, по которым считается статистика.
    ///   - period: Период графика.
    ///   - now: Текущий момент — параметр, чтобы результат был проверяем в тестах.
    ///   - calendar: Календарь для разбивки по месяцам.
    /// - Returns: По три точки (started, studied, practiced) на каждый месяц, от старых к новым.
    static func monthlyPoints(
        posts: [Post],
        period: TimePeriod,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> [ChartDataPoint] {
        let currentMonthStart = calendar.startOfMonth(for: now)
        var dataPoints: [ChartDataPoint] = []

        for i in 0...period.months {
            guard let monthDate = calendar.date(byAdding: .month, value: -period.months + i, to: currentMonthStart) else { continue }

            /// Сколько постов имеют дату этапа в этом месяце.
            func count(_ dateStamp: (Post) -> Date?) -> Int {
                posts.filter { post in
                    guard let date = dateStamp(post) else { return false }
                    return calendar.isDate(date, equalTo: monthDate, toGranularity: .month)
                }.count
            }

            dataPoints.append(ChartDataPoint(month: monthDate, type: .started, count: count { $0.startedDateStamp }))
            dataPoints.append(ChartDataPoint(month: monthDate, type: .studied, count: count { $0.studiedDateStamp }))
            dataPoints.append(ChartDataPoint(month: monthDate, type: .practiced, count: count { $0.practicedDateStamp }))
        }

        return dataPoints
    }

    /// Верхняя граница оси Y: наибольшая сумма всех типов за один месяц,
    /// но не меньше 5 — чтобы график с малыми значениями оставался читаемым.
    ///
    /// - Parameter points: Точки графика из `monthlyPoints(posts:period:now:calendar:)`.
    /// - Returns: Максимум оси Y.
    static func yAxisMax(for points: [ChartDataPoint]) -> Int {
        let sumsByMonth = Dictionary(grouping: points, by: \.month)
            .mapValues { $0.reduce(0) { $0 + $1.count } }
        return max(sumsByMonth.values.max() ?? 0, 5)
    }
}
