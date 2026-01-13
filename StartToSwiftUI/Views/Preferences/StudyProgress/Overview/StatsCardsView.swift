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
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatCard(title: "Added", value: "\(stats.added)", color: StudyProgress.added.color)
                StatCard(title: "Started", value: "\(stats.started)", color: StudyProgress.started.color)
            }
            
            HStack(spacing: 12) {
                StatCard(title: "Learnt", value: "\(stats.studied)", color: StudyProgress.studied.color)
                StatCard(title: "Practiced", value: "\(stats.practiced)", color: StudyProgress.practiced.color)
            }
            
            // Completion percentage
            HStack {
                Text("Completion:")
                    .font(.subheadline)
                    .foregroundStyle(Color.mycolor.mySecondary)
                Spacer()
                Text(String(format: "%.1f%%", stats.completionRate))
                    .font(.headline)
                    .foregroundStyle(Color.mycolor.myAccent)
            }
            .padding()
            .background(Color.mycolor.myBackground)
            .clipShape(
                RoundedRectangle(cornerRadius: 15)
            )
        }
    }
}
