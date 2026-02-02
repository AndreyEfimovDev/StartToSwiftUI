//
//  StudyProgressForLevel.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 04.12.2025.
//

import SwiftUI
import SwiftData

struct StudyProgressForLevel: View {
    
    let posts: [Post]
    let studyLevel: StudyLevel?

    @State private var refreshID = UUID()

    private var fontForSectionTitle: Font {
        UIDevice.isiPad ? .subheadline : .headline
    }
    
    private var lineWidth: Double {
        UIDevice.isiPad ? 4.0 : 8.0
    }

    var titleForStudyLevel: String {
        if let studyLevel = studyLevel {
            "All " + studyLevel.displayName
        } else { "All Levels" }
    }

    private var postsForStudyLevel: [Post] {
        if let studyLevel = studyLevel {
            return posts.filter { $0.studyLevel == studyLevel}
        }
        return posts
    }
    
    var body: some View {
        
        VStack {
            // TITLE
            sectionTitle
            
            // PROGRESS VIEWS
            ForEach([StudyProgress.practiced, StudyProgress.studied , StudyProgress.started], id: \.self) { level in
                HStack {
                    
                    let count = levelPostsCount(for: level)
                    
                    VStack(spacing: 8) {
                        level.icon
                        Text(level.displayName)
                        Text("(\(count))")
                            .frame(maxWidth: .infinity)
                    }
                    .font(fontForSectionTitle)
                    .foregroundStyle(level.color)

                    Spacer()
                    
                    ProgressIndicator(
                        progress: progressCount(for: level),
                        colour: level.color,
                        lineWidth: lineWidth
                    )
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.vertical)
                .padding(.trailing, 30)
                .background(.ultraThinMaterial)
                .clipShape(
                    RoundedRectangle(cornerRadius: 30)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(.blue, lineWidth: 1)
                )
                .padding(8)
            } // ForEach
        }
        .padding(.horizontal, 30)
        .bold()
        .id(refreshID)
        .onAppear {
            refreshID = UUID()
        }
    }
    
    private var sectionTitle: some View {
        HStack {
            Image(systemName: "hare")
            Text(titleForStudyLevel + " (\(postsForStudyLevel.count))")
        }
        .font(.footnote)
        .bold()
        .foregroundStyle(studyLevel?.color ?? Color.mycolor.myAccent)
    }
    
    private func progressCount(for progressLevel: StudyProgress) -> Double {
        
        guard !postsForStudyLevel.isEmpty else { return 0 }
        let count = levelPostsCount(for: progressLevel)
        return Double(count) / Double(postsForStudyLevel.count)
    }
    
    private func levelPostsCount(for progressLevel: StudyProgress) -> Int {
        switch progressLevel {
        case .added:
            return postsForStudyLevel.filter { $0.addedDateStamp != nil }.count
        case .started:
            return postsForStudyLevel.filter { $0.startedDateStamp != nil }.count
        case .studied:
            return postsForStudyLevel.filter { $0.studiedDateStamp != nil }.count
        case .practiced:
            return postsForStudyLevel.filter { $0.practicedDateStamp != nil }.count
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
