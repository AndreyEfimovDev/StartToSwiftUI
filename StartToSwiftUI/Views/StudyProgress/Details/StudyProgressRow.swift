//
//  StudyProgressRow.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 24.02.2026.
//

import SwiftUI

struct StudyProgressRow: View {
    
    let level: StudyProgress
    let count: Int
    let progress: Double
    
    private var fontForSectionTitle: Font {
        UIDevice.isiPad ? .subheadline : .headline
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 8) {
                level.icon
                Text(level.displayName)
            }
            .font(fontForSectionTitle)
            .foregroundStyle(level.color)
            .padding()
            .padding(.vertical, UIDevice.isiPad ? 0 : 8)
            .padding(.leading, 15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .overlay(RoundedRectangle(cornerRadius: 30).stroke(.blue, lineWidth: 1))
            
            ProgressIndicatorView(
                progress: progress,
                count: count,
                colour: level.color
            )
            .background(.ultraThinMaterial)
            .clipShape(Circle())
            .padding(.trailing, 15)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.vertical, UIDevice.isiPad ? 0 : 8)
        .padding(.horizontal, UIDevice.isiPad ? 75 : 0)
        .padding(4)
    }
    
}
#Preview {
    let calendar = Calendar.current
    let now = Date()

    let extendedPosts = [
        Post(title: "Post 1", intro: "Intro 1", studyLevel: .beginner, progress: .started)
            .withDateStamp(.started, date: calendar.date(byAdding: .month, value: -2, to: now)!),
        
        Post(title: "Post 2", intro: "Intro 2", studyLevel: .middle, progress: .studied)
            .withDateStamp(.started, date: calendar.date(byAdding: .month, value: -1, to: now)!)
            .withDateStamp(.studied, date: calendar.date(byAdding: .month, value: -2, to: now)!),
        
        Post(title: "Post 3", intro: "Intro 3", studyLevel: .advanced, progress: .practiced)
            .withDateStamp(.started, date: calendar.date(byAdding: .month, value: -3, to: now)!)
            .withDateStamp(.studied, date: calendar.date(byAdding: .month, value: -2, to: now)!)
            .withDateStamp(.practiced, date: calendar.date(byAdding: .month, value: -1, to: now)!),
        
        Post(title: "Post 4", intro: "Intro 4", studyLevel: .middle, progress: .added),
        
        Post(title: "Post 5", intro: "Intro 5", studyLevel: .beginner, progress: .started)
            .withDateStamp(.started, date: now),
        
        Post(title: "Post 6", intro: "Intro 6", studyLevel: .advanced, progress: .studied)
            .withDateStamp(.started, date: calendar.date(byAdding: .month, value: -4, to: now)!)
            .withDateStamp(.studied, date: calendar.date(byAdding: .month, value: -3, to: now)!),
    ]
    
    let postsVM = PostsViewModel(
        dataSource: MockPostsDataSource(posts: extendedPosts)
    )
        
    NavigationStack {
        StudyProgressForLevel(posts: postsVM.allPosts, studyLevel: nil)
    }
    .environmentObject(postsVM)
    
}
