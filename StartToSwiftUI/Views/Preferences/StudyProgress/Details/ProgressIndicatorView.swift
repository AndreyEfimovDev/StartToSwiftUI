//
//  ProgressIndicatorView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 04.12.2025.
//

import SwiftUI

struct ProgressIndicatorView: View {
    
    @State private var trim: Double = 0
    @State private var isAppear: Bool = false
    
    let progress: Double
    let count: Int
    let colour: Color
    
    private let opacity: Double = 0.3
    private var lineWidth: Double {
        UIDevice.isiPad ? 4.0 : 8.0
    }

    var body: some View {
        ZStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: lineWidth)
                    .foregroundStyle(Color.mycolor.mySecondary)
                    .opacity(opacity)
                Circle()
                    .trim(from: 0, to: trim)
                    .stroke(style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round,
                        lineJoin: .round))
                    .foregroundStyle(colour)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.8), value: trim)
            }
            .padding(lineWidth / 2)
            
            VStack {
                Text("\(count)")
                    .font(.largeTitle)
                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    Text("(")
                    Text(String(format: "%.1f", trim * 100))
                    Text("%")
                        .font(.caption2)
                    Text(")")
                }
                .font(UIDevice.isiPad ? .footnote : .callout)
            }
            .bold()
            .foregroundStyle(Color.mycolor.myAccent)
        }
        .opacity(isAppear ? 1 : 0)
        .onAppear {
            isAppear.toggle()
            trim = progress
        }
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
