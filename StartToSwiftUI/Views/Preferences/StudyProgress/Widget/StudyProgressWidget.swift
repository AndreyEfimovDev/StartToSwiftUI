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
        VStack(/*alignment: .leading, */spacing: 8) {
            HStack {
                Image(systemName: "hare")
                    .foregroundStyle(.blue)
                Text("Study Progress")
                    .fontWeight(.bold)
            }
            .font(.caption2)
            
            Spacer()
            
            // Progress ring
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                
                Circle()
                    .trim(from: 0, to: data.progressPercentage / 100)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 0) {
                    Text("\(Int(data.progressPercentage))%")
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                }
            }
            .frame(width: 70, height: 70)
            .frame(maxWidth: .infinity)
            
            Spacer()
            
            Text("\(data.practicedCount)/\(data.totalCount) completed")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let data: StudyProgressData
    
    var body: some View {
        HStack(spacing: 16) {
            // Left side - Progress ring
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "hare")
                        .foregroundStyle(.blue)
                    Text("Study Progress")
                        .fontWeight(.bold)
                }
                .font(.footnote)
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 10)
                    
                    Circle()
                        .trim(from: 0, to: data.progressPercentage / 100)
                        .stroke(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 0) {
                        Text("\(Int(data.progressPercentage))%")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)
                        Text("progress")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 80, height: 80)
                
                Spacer()
            }
            
            // Right side - Stats
            VStack(alignment: .leading, spacing: 6) {
                StatRow(icon: "square.and.arrow.down", label: "Added", count: data.freshCount, color: .green)
                StatRow(icon: "sunrise", label: "Started", count: data.startedCount, color: .purple)
                StatRow(icon: "bolt", label: "Learnt", count: data.studiedCount, color: .blue)
                StatRow(icon: "flag.checkered", label: "Practiced", count: data.practicedCount, color: .red)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
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
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text("\(count)")
                .font(.caption)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Large Widget

struct LargeWidgetView: View {
    let data: StudyProgressData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "hare")
                    .foregroundStyle(.blue)
                Text("Study Progress")
                    .font(.headline)
                
                Spacer()
                
                Text("\(data.totalCount) materials")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            
            // Progress ring centered
            HStack {
                Spacer()
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 15)
                    
                    Circle()
                        .trim(from: 0, to: data.progressPercentage / 100)
                        .stroke(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 15, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 2) {
                        Text("\(Int(data.progressPercentage))%")
                            .font(.system(.largeTitle, design: .rounded))
                            .fontWeight(.bold)
                        Text("overall progress")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 120, height: 120)
                Spacer()
            }
            
            Divider()
            
            // Stats grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                LargeStatCard(icon: "square.and.arrow.down", label: "Added", count: data.freshCount, color: .green)
                LargeStatCard(icon: "sunrise", label: "Started", count: data.startedCount, color: .purple)
                LargeStatCard(icon: "bolt", label: "Learnt", count: data.studiedCount, color: .blue)
                LargeStatCard(icon: "flag.checkered", label: "Practiced", count: data.practicedCount, color: .red)
            }
            
            Spacer()
            
            // Footer
            Text("Updated: \(data.lastUpdated.formatted(date: .abbreviated, time: .shortened))")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
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
                    .foregroundStyle(.secondary)
                Text("\(count)")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            
            Spacer()
        }
        .padding(10)
        .background(color.opacity(0.1))
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
    }
}

struct AccessoryRectangularView: View {
    let data: StudyProgressData
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Study Progress")
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
    }
}

struct AccessoryInlineView: View {
    let data: StudyProgressData
    
    var body: some View {
        Text("📚 \(Int(data.progressPercentage))% • \(data.practicedCount)/\(data.totalCount)")
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
