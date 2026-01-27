//
//  StudyProgressWidget.swift
//  StudyProgressWidget
//
//  Created by Andrey Efimov on 26.01.2026.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct StudyProgressEntry: TimelineEntry {
    let date: Date
    let data: StudyProgressData
}

// MARK: - Timeline Provider

struct StudyProgressProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> StudyProgressEntry {
        StudyProgressEntry(date: Date(), data: .preview)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (StudyProgressEntry) -> Void) {
        let data = WidgetDataManager.shared.loadProgressData()
        let entry = StudyProgressEntry(date: Date(), data: data)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<StudyProgressEntry>) -> Void) {
        let data = WidgetDataManager.shared.loadProgressData()
        let entry = StudyProgressEntry(date: Date(), data: data)
        
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
}

// MARK: - Widget Views

struct StudyProgressWidgetEntryView: View {
    
    @Environment(\.widgetFamily) var widgetFamily
    var entry: StudyProgressProvider.Entry
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetView(data: entry.data)
        case .systemMedium:
            MediumWidgetView(data: entry.data)
        case .systemLarge:
            LargeWidgetView(data: entry.data)
        case .accessoryCircular:
            AccessoryCircularView(data: entry.data)
        case .accessoryRectangular:
            AccessoryRectangularView(data: entry.data)
        case .accessoryInline:
            AccessoryInlineView(data: entry.data)
        default:
            SmallWidgetView(data: entry.data)
        }
    }
}

// MARK: - Small Widget

struct SmallWidgetView: View {
    let data: StudyProgressData
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "hare")
                    .foregroundStyle(Color.mycolor.myBlue)
                Text("Progress")
                    .fontWeight(.bold)
                    .foregroundStyle(Color.mycolor.myAccent)
            }
            .font(.caption)
            
            Spacer()
            // Progress ring
            ZStack {
                Circle()
                    .stroke(Color.mycolor.mySecondary.opacity(0.3), lineWidth: 8)
                
                Circle()
                    .trim(from: 0, to: data.progressPercentage / 100)
                    .stroke(
                        LinearGradient(
                            colors: [Color.mycolor.myBlue, Color.mycolor.myPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 0) {
                    Text("\(Int(data.progressPercentage))%")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(Color.mycolor.myAccent)
                }
            }
            .frame(width: 70, height: 70)
            .frame(maxWidth: .infinity)
            
            Spacer()
            
            Text("\(data.practicedCount)/\(data.totalCount) completed")
                .font(.caption2)
                .foregroundStyle(Color.mycolor.mySecondary)
        }
        .padding(.vertical)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let data: StudyProgressData
    
    var body: some View {
        VStack(/*spacing: 16*/) {
            HStack {
                Image(systemName: "hare")
                    .foregroundStyle(Color.mycolor.myBlue)
                Text("Progress")
                    .foregroundStyle(Color.mycolor.myAccent)
            }
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            // Left side - Progress ring
            HStack(spacing: 4) {
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color.mycolor.mySecondary.opacity(0.3), lineWidth: 8)
                    
                    Circle()
                        .trim(from: 0, to: data.progressPercentage / 100)
                        .stroke(
                            LinearGradient(
                                colors: [Color.mycolor.myBlue, Color.mycolor.myPurple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 0) {
                        Text("\(Int(data.progressPercentage))%")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(Color.mycolor.myAccent)
                        
                        Text("overall")
                            .font(.caption2)
                            .foregroundStyle(Color.mycolor.mySecondary)
                    }
                }
                .frame(width: 80, height: 80)
                
                Spacer()
                Spacer()
                // Right side - Stats
                VStack(alignment: .leading, spacing: 6) {
                    StatRow(icon: "square.and.arrow.down", label: "Added", count: data.freshCount, color: Color.mycolor.myGreen)
                    StatRow(icon: "sunrise", label: "Started", count: data.startedCount, color: Color.mycolor.myPurple)
                    StatRow(icon: "bolt", label: "Learnt", count: data.studiedCount, color: Color.mycolor.myBlue)
                    StatRow(icon: "flag.checkered", label: "Practiced", count: data.practicedCount, color: Color.mycolor.myRed)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
        }
        .padding(8)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct StatRow: View {
    let icon: String
    let label: String
    let count: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
                .frame(width: 16)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.mycolor.mySecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Spacer()
            
            Text("\(count)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.mycolor.myAccent)
        }
    }
}

// MARK: - Large Widget

struct LargeWidgetView: View {
    let data: StudyProgressData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header
            HStack {
                Image(systemName: "hare")
                    .foregroundStyle(Color.mycolor.myBlue)
                Text("Study Progress")
                    .font(.headline)
                    .foregroundStyle(Color.mycolor.myAccent)
                
                Spacer()
                
                Text("\(data.totalCount) materials")
                    .font(.subheadline)
                    .foregroundStyle(Color.mycolor.mySecondary)
            }
            
            Spacer()
            // Progress ring centered
            HStack {
                Spacer()
                ZStack {
                    Circle()
                        .stroke(Color.mycolor.mySecondary.opacity(0.3), lineWidth: 11)
                    
                    Circle()
                        .trim(from: 0, to: data.progressPercentage / 100)
                        .stroke(
                            LinearGradient(
                                colors: [Color.mycolor.myBlue, Color.mycolor.myPurple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 11, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 0) {
                        Text("\(Int(data.progressPercentage))%")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(Color.mycolor.myAccent)
                        Text("overall")
                            .font(.caption2)
                            .foregroundStyle(Color.mycolor.mySecondary)
                    }
                }
                .frame(width: 110, height: 110)
                Spacer()
            }
            Spacer()
            // Stats grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                LargeStatCard(icon: "square.and.arrow.down", label: "Added", count: data.freshCount, color: Color.mycolor.myGreen)
                LargeStatCard(icon: "sunrise", label: "Started", count: data.startedCount, color: Color.mycolor.myPurple)
                LargeStatCard(icon: "bolt", label: "Learnt", count: data.studiedCount, color: Color.mycolor.myBlue)
                LargeStatCard(icon: "flag.checkered", label: "Practiced", count: data.practicedCount, color: Color.mycolor.myRed)
            }
            
            Spacer()
            // Footer
            Text("Updated: \(data.lastUpdated.formatted(date: .abbreviated, time: .shortened))")
                .font(.caption2)
                .foregroundStyle(Color.mycolor.mySecondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(8)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct LargeStatCard: View {
    let icon: String
    let label: String
    let count: Int
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(Color.mycolor.mySecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text("\(count)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.mycolor.myAccent)
            }
            
            Spacer()
        }
        .padding(4)
        .background(color.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Lock Screen Widgets (iOS 16+)

struct AccessoryCircularView: View {
    let data: StudyProgressData
    
    var body: some View {
        Gauge(value: data.progressPercentage, in: 0...100) {
            Image(systemName: "hare")
        } currentValueLabel: {
            Text("\(Int(data.progressPercentage))")
                .font(.system(.body, design: .rounded))
        }
        .gaugeStyle(.accessoryCircular)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct AccessoryRectangularView: View {
    let data: StudyProgressData
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Progress")
                    .font(.headline)
                    .widgetAccentable()
                
                Text("\(data.practicedCount)/\(data.totalCount) completed")
                    .font(.caption)
                
                Gauge(value: data.progressPercentage, in: 0...100) {
                    EmptyView()
                }
                .gaugeStyle(.accessoryLinear)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct AccessoryInlineView: View {
    let data: StudyProgressData
    
    var body: some View {
        Text("📚 \(Int(data.progressPercentage))% • \(data.practicedCount)/\(data.totalCount)")
            .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Widget Configuration

struct StudyProgressWidget: Widget {
    let kind: String = "StudyProgressWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StudyProgressProvider()) { entry in
            StudyProgressWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Study Progress")
        .description("Track your learning progress at a glance.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

// MARK: - Widget Bundle

@main
struct StudyProgressWidgetBundle: WidgetBundle {
    var body: some Widget {
        StudyProgressWidget()
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    StudyProgressWidget()
} timeline: {
    StudyProgressEntry(date: Date(), data: .preview)
}

#Preview("Medium", as: .systemMedium) {
    StudyProgressWidget()
} timeline: {
    StudyProgressEntry(date: Date(), data: .preview)
}

#Preview("Large", as: .systemLarge) {
    StudyProgressWidget()
} timeline: {
    StudyProgressEntry(date: Date(), data: .preview)
}

#Preview("Circular", as: .accessoryCircular) {
    StudyProgressWidget()
} timeline: {
    StudyProgressEntry(date: Date(), data: .preview)
}

#Preview("Rectangular", as: .accessoryRectangular) {
    StudyProgressWidget()
} timeline: {
    StudyProgressEntry(date: Date(), data: .preview)
}
