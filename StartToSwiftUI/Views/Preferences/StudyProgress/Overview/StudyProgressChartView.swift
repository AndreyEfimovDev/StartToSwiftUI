//
//  StudyProgressChartView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 12.01.2026.
//

import SwiftUI
import Charts

// MARK: - Main Chart
struct StudyProgressChartView: View {
    
    let posts: [Post]
    @State private var selectedPeriod: TimePeriod = .halfYear
    
    var body: some View {
        VStack(spacing: 10) {
            // Данные считаются один раз за перерисовку и передаются дальше:
            // максимум оси Y берётся из уже готовых точек, stats — общий.
            let chartData = ChartDataPoint.monthlyPoints(posts: posts, period: selectedPeriod)
            let chartYAxisMax = ChartDataPoint.yAxisMax(for: chartData)
            let stats = ProgressStats(posts: posts, period: selectedPeriod)

            // Completion percentage
            completion(stats: stats)
            
            let UIDeviceLayout: AnyLayout = UIDevice.isiPad ? AnyLayout(HStackLayout(spacing: 6)) : AnyLayout(VStackLayout(spacing: 6))

            UIDeviceLayout {
                StatsCardsView(stats: stats)
                    .frame(maxWidth: UIDevice.isiPad ? 100 : .infinity)
                
                // Chart
                Chart(chartData) { dataPoint in
                    /*
                     Monthly change in the number of materials covered – how much material was started/learnt/practicied in each specific month.
                     The lines show trends: whether activity is increasing, whether there are declines, and which months were the most productive.
                     */
                    LineMark(
                        x: .value("Month", dataPoint.month, unit: .month),
                        y: .value("Quantity", dataPoint.count)
                    )
                    .foregroundStyle(by: .value("Type", dataPoint.type.displayName))
                    .symbol(by: .value("Type", dataPoint.type.displayName))
                    .interpolationMethod(.catmullRom)
                    
                    /*
                     Cumulative volume, visualisation:
                     - Activity intensity - the higher the color, the more material was covered
                     - Correlation between types - visually compares the volumes of Started vs. Learned vs. Practiced
                     - Periods of high/low activity - colored areas make "dents" and "peaks" more visible
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
            }
            
            UIDeviceLayout {
                // Dynamics of changes in the number of materials by month
                LineMarkLegendView()
                // Cumulative progress
                CumulativeLegendView()

            }

            UnderlineSermentedPickerNotOptional(
                selection: $selectedPeriod,
                allItems: TimePeriod.allCases,
                titleForCase: { $0.displayName },
                selectedFont: UIDevice.isiPad ? .footnote : .subheadline
            )
            .padding(.horizontal)
            .padding(.top, 16)
        }
        .bold()
        .padding()
        
    }
    
    /// Строка "Completion: N% (всего постов)" над графиком.
    private func completion(stats: ProgressStats) -> some View {
        HStack {
            Image(systemName: "hare")
            Text("Completion:")
            Text("\(Int(stats.completionRate))%")
            Text("(\(posts.count))")
        }
        .font(.footnote)
        .bold()
        .foregroundStyle(Color.mycolor.myAccent)
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
    
    return StudyProgressChartView(posts: samplePosts)
}
