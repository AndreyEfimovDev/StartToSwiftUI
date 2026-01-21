//
//  StatsCardsView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 13.01.2026.
//

import SwiftUI

// MARK: - Statistics cards
struct StatsCardsView: View {
    
    let stats: ProgressStats
    
    var body: some View {
        VStack(spacing: 6) {
            
            let layout: AnyLayout = UIDevice.isiPad ? AnyLayout(VStackLayout(spacing: 6)) : AnyLayout(HStackLayout(spacing: 6))
            
            layout {
                StatCard(title: "Practiced", value: "\(stats.practiced)", color: StudyProgress.practiced.color)
                StatCard(title: "Learnt", value: "\(stats.studied)", color: StudyProgress.studied.color)
                StatCard(title: "Started", value: "\(stats.started)", color: StudyProgress.started.color)
                StatCard(title: "Added", value: "\(stats.added)", color: StudyProgress.fresh.color)
            }
        }
    }
}

#Preview {
    let mockPosts = [
        Post(date: Date()),
        Post(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!),
        Post(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!),
        Post(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, startedDateStamp: Date()),
        Post(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, startedDateStamp: Date()),
        Post(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, startedDateStamp: Date(), studiedDateStamp: Date()),
        Post(date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, startedDateStamp: Date(), studiedDateStamp: Date(), practicedDateStamp: Date())
    ]
    
    let stats = ProgressStats(posts: mockPosts, period: .quarter)
    
    return StatsCardsView(stats: stats)
        .padding()
}
