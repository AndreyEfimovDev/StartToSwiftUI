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
                LineMark(
                    x: .value("Month", dataPoint.month, unit: .month),
                    y: .value("Quantity", dataPoint.count)
                )
                .foregroundStyle(by: .value("Type", dataPoint.type.displayName))
                .symbol(by: .value("Type", dataPoint.type.displayName))
                .interpolationMethod(.catmullRom)
                
                AreaMark(
                    x: .value("Month", dataPoint.month, unit: .month),
                    y: .value("Quantity", dataPoint.count)
                )
                .foregroundStyle(by: .value("Type", dataPoint.type.displayName))
                .opacity(0.1)
            }
            .chartForegroundStyleScale([
                StudyProgress.added.displayName: StudyProgress.added.color,
                StudyProgress.started.displayName: StudyProgress.started.color,
                StudyProgress.studied.displayName: StudyProgress.studied.color,
                StudyProgress.practiced.displayName: StudyProgress.practiced.color
            ])
            .chartXAxis {
                AxisMarks(values: .stride(by: .month, count: selectedPeriod.months <= 6 ? 1 : 2)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.abbreviated).year(.twoDigits))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .padding()
            
            // Legend
            LegendView()
                .padding(.horizontal)
            
            Spacer()

            SegmentedOneLinePickerNotOptional(
                selection: $selectedPeriod,
                allItems: TimePeriod.allCases,
                titleForCase: { $0.displayName },
                selectedFont: UIDevice.isiPad ? .headline : .subheadline
            )
            .padding(.horizontal)
        }
        .bold()
        .padding()
    }
    
    // Generating data for the graph
    private func generateChartData(posts: [Post], period: TimePeriod) -> [ChartDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .month, value: -period.months, to: now) ?? now
        
        var dataPoints: [ChartDataPoint] = []
        
        // Create an array of months
        for i in 0..<period.months {
            guard let monthDate = calendar.date(byAdding: .month, value: -period.months + i + 1, to: now) else { continue }
            let monthStart = calendar.startOfMonth(for: monthDate)
            
            // Calculate for each type of progress
            let addedCount = posts.filter { post in
                guard post.date >= startDate else { return false }
                return calendar.isDate(post.date, equalTo: monthStart, toGranularity: .month)
            }.count
            
            let startedCount = posts.filter { post in
                guard let date = post.startedDateStamp, date >= startDate else { return false }
                return calendar.isDate(date, equalTo: monthStart, toGranularity: .month)
            }.count
            
            let studiedCount = posts.filter { post in
                guard let date = post.studiedDateStamp, date >= startDate else { return false }
                return calendar.isDate(date, equalTo: monthStart, toGranularity: .month)
            }.count
            
            let practicedCount = posts.filter { post in
                guard let date = post.practicedDateStamp, date >= startDate else { return false }
                return calendar.isDate(date, equalTo: monthStart, toGranularity: .month)
            }.count
            
            dataPoints.append(ChartDataPoint(month: monthStart, type: .added, count: addedCount))
            dataPoints.append(ChartDataPoint(month: monthStart, type: .started, count: startedCount))
            dataPoints.append(ChartDataPoint(month: monthStart, type: .studied, count: studiedCount))
            dataPoints.append(ChartDataPoint(month: monthStart, type: .practiced, count: practicedCount))
        }
        
        return dataPoints
    }
}

// MARK: - Preview
#Preview {
    let samplePosts = [
        Post(
            date: Date(),
            startedDateStamp: Date(),
            studiedDateStamp: Date(),
            practicedDateStamp: Date()
        ),
        Post(
            date: Calendar.current.date(byAdding: .month, value: -1, to: Date())!,
            startedDateStamp: Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        ),
        Post(
            date: Calendar.current.date(byAdding: .month, value: -2, to: Date())!
        ),
        Post(
            date: Calendar.current.date(byAdding: .month, value: -3, to: Date())!,
            studiedDateStamp: Calendar.current.date(byAdding: .month, value: -2, to: Date())!
        )
    ]
    
    LearningProgressChartView(posts: samplePosts)
}
