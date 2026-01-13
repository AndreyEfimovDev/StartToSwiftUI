//
//  StudyProgressChartView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 12.01.2026.
//

import SwiftUI
import Charts

// MARK: - Main Chart
struct LearningProgressChartView: View {
    
    let posts: [Post]
    @State private var selectedPeriod: TimePeriod = .halfYear
    @State private var showStats = true
    
    private var chartData: [ChartDataPoint] {
        generateChartData(posts: posts, period: selectedPeriod)
    }
    
    private var stats: ProgressStats {
        ProgressStats(posts: posts, period: selectedPeriod)
    }
    
    // Calculate the maximum value for the Y-axis based on all data
    private var chartYAxisMax: Int {
        let maxStarted = stats.started
        let maxStudied = stats.studied
        let maxPracticed = stats.practiced
        let maxValue = max(maxStarted, maxStudied, maxPracticed)
        return max(maxValue, 5) // Минимум 5 для читаемости
    }
    
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "hare")
                Text("Overview")
                    .font(.title3)
            }
            .padding(.horizontal)
            
            // Statistics
            if showStats {
                StatsCardsView(stats: stats)
                    .padding(.horizontal)
            }
            
            // Chart
            Chart(chartData) { dataPoint in
                
                /*
                 Динамика изменения количества материалов по месяцам - сколько материалов было начато/изучено/практически освоено в каждом конкретном месяце.
                 Линии показывают тренды: растёт ли активность, есть ли спады, в какие месяцы  были наиболее продуктивными.
                 */
                
                LineMark(
                    x: .value("Month", dataPoint.month, unit: .month),
                    y: .value("Quantity", dataPoint.count)
                )
                .foregroundStyle(by: .value("Type", dataPoint.type.displayName))
                .symbol(by: .value("Type", dataPoint.type.displayName))
                .interpolationMethod(.catmullRom)
                
                /*
                 Накопительный объём, визуализация:
                 * Интенсивность активности - чем больше заливка, тем больше материалов было в изучении
                 * Соотношение между типами - визуально сравниваются объёмы Started vs Learnt vs Practiced
                 * Периоды высокой/низкой активности - цветные области делают "впадины" и "пики" более заметными
                 */
                AreaMark(
                    x: .value("Month", dataPoint.month, unit: .month),
                    y: .value("Quantity", dataPoint.count)
                )
                .foregroundStyle(by: .value("Type", dataPoint.type.displayName))
                .opacity(0.3)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .month, count: selectedPeriod.months <= 6 ? 1 : 2)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.abbreviated).year(.twoDigits))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartYScale(domain: 0...chartYAxisMax)
            .chartForegroundStyleScale([
                StudyProgress.started.displayName: StudyProgress.started.color,
                StudyProgress.studied.displayName: StudyProgress.studied.color,
                StudyProgress.practiced.displayName: StudyProgress.practiced.color
            ])
            .chartLegend(.hidden)
            .frame(maxHeight: .infinity)
            
            // Legends
            // Dynamics of changes in the number of materials by month
            LineMarkLegendView()
            // Cumulative progress
            CumulativeLegendView()
            
            SegmentedOneLinePickerNotOptional(
                selection: $selectedPeriod,
                allItems: TimePeriod.allCases,
                titleForCase: { $0.displayName },
                selectedFont: UIDevice.isiPad ? .headline : .subheadline
            )
            .padding(.horizontal)
            .padding(.top, 16)
        }
        .bold()
        .padding()
        
    }
    
    // Generating data for the graph
    private func generateChartData(posts: [Post], period: TimePeriod) -> [ChartDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        
        // Start from the beginning of the current month
        let currentMonthStart = calendar.startOfMonth(for: now)
        
        var dataPoints: [ChartDataPoint] = []
        
        // Create an array of months (from period.months back to and including the current month)
        for i in 0...period.months {
            guard let monthDate = calendar.date(byAdding: .month, value: -period.months + i, to: currentMonthStart) else { continue }
            
            // Calculate for each type of progress
            let startedCount = posts.filter { post in
                guard let date = post.startedDateStamp else { return false }
                return calendar.isDate(date, equalTo: monthDate, toGranularity: .month)
            }.count
            
            let studiedCount = posts.filter { post in
                guard let date = post.studiedDateStamp else { return false }
                return calendar.isDate(date, equalTo: monthDate, toGranularity: .month)
            }.count
            
            let practicedCount = posts.filter { post in
                guard let date = post.practicedDateStamp else { return false }
                return calendar.isDate(date, equalTo: monthDate, toGranularity: .month)
            }.count
            
            dataPoints.append(ChartDataPoint(month: monthDate, type: .started, count: startedCount))
            dataPoints.append(ChartDataPoint(month: monthDate, type: .studied, count: studiedCount))
            dataPoints.append(ChartDataPoint(month: monthDate, type: .practiced, count: practicedCount))
        }
        
        return dataPoints
    }
    
}

// MARK: - Preview
#Preview {
    let calendar = Calendar.current
    let now = Date()
    
    var samplePosts: [Post] = []
    
    // Generate data for the last 12 months
    for monthOffset in 0...12 {
        guard let monthDate = calendar.date(byAdding: .month, value: -monthOffset, to: now) else { continue }
        
        // Different amount of materials each month
        let postsCount = Int.random(in: 3...8)
        
        for _ in 0..<postsCount {
            let daysOffset = Int.random(in: 0...28)
            let postDate = calendar.date(byAdding: .day, value: -daysOffset, to: monthDate) ?? monthDate
            
            // Random progress for each material
            let hasStarted = Bool.random()
            let hasStudied = hasStarted && Double.random(in: 0...1) > 0.3
            let hasPracticed = hasStudied && Double.random(in: 0...1) > 0.5
            
            let post = Post(
                date: postDate,
                startedDateStamp: hasStarted ? calendar.date(byAdding: .day, value: Int.random(in: 1...7), to: postDate) : nil,
                studiedDateStamp: hasStudied ? calendar.date(byAdding: .day, value: Int.random(in: 8...21), to: postDate) : nil,
                practicedDateStamp: hasPracticed ? calendar.date(byAdding: .day, value: Int.random(in: 22...35), to: postDate) : nil
            )
            samplePosts.append(post)
        }
    }
    
    // Adding some recent materials with a full cycle
    for i in 0..<5 {
        let recentDate = calendar.date(byAdding: .day, value: -i, to: now) ?? now
        let post = Post(
            date: recentDate,
            startedDateStamp: recentDate,
            studiedDateStamp: calendar.date(byAdding: .day, value: 3, to: recentDate),
            practicedDateStamp: calendar.date(byAdding: .day, value: 7, to: recentDate)
        )
        samplePosts.append(post)
    }
    
    // Adding materials that have just been added
    for i in 0..<10 {
        let addedOnlyDate = calendar.date(byAdding: .day, value: -i*3, to: now) ?? now
        let post = Post(date: addedOnlyDate)
        samplePosts.append(post)
    }
    
    return LearningProgressChartView(posts: samplePosts)
}
