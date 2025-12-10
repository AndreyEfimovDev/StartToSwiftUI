//
//  StudyProgressForLevel.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 04.12.2025.
//

import SwiftUI

struct StudyProgressForLevel: View {
    
    @EnvironmentObject private var vm: PostsViewModel
    @State private var refreshID = UUID()

    let studyLevel: StudyLevel?
    
    private var fontForTitle: Font {
        UIDevice.isiPad ? .body : .title3
    }
    
    private var postsForStudyLevel: [Post] {
        if let level = studyLevel {
            return vm.allPosts.filter { $0.studyLevel == level }
        }
        return vm.allPosts
    }
    
    var body: some View {
        
        VStack (spacing: 0) {
            // TITLE
            var titleForStudyLevel: String {
                if let studyLevel = studyLevel {
                    studyLevel.displayName + " materials"
                } else { "All materials" }
            }
            HStack {
                Image(systemName: "hare")
                Text(titleForStudyLevel + " (\(totalPostsCount))")
                    .font(.title3)
            }
            .foregroundStyle(studyLevel?.color ?? Color.mycolor.myAccent)
            .padding()
            
            // PROGRESS VIEWS
            ForEach(StudyProgress.allCases, id: \.self) { progressLevel in
                HStack {
                    VStack(spacing: 0) {
                        progressLevel.icon
                            .foregroundStyle(progressLevel.color)
                            .padding(.bottom, 8)
                        Text(progressLevel.displayName)
                        Text("(\(levelPostsCount(for: progressLevel)))")
                            .font(.caption2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(fontForTitle)
                    .foregroundStyle(Color.mycolor.myAccent)
                    .padding()
                    .padding(.leading, 30)
                    
                    Spacer()
                    
                    ProgressIndicator(
                        progress: progressCount(for: progressLevel),
                        colour: progressLevel.color,
                        fontForTitle: fontForTitle
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(
                    RoundedRectangle(cornerRadius: 30)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(.blue, lineWidth: 1)
                )
                .padding(8)
            }
        }
        .bold()
        .padding()
        .id(refreshID)
        .onAppear {
            refreshID = UUID()
        }
    }
    
    private func progressCount(for progressLevel: StudyProgress) -> Double {
        
        guard !postsForStudyLevel.isEmpty else { return 0 }
        
        let filteredPosts = postsForStudyLevel.filter { $0.progress == progressLevel }
        return Double(filteredPosts.count) / Double(postsForStudyLevel.count)
    }
    
    private func levelPostsCount(for progressLevel: StudyProgress) -> Int {
        postsForStudyLevel.filter { $0.progress == progressLevel }.count
    }

    private var totalPostsCount: Int {
        postsForStudyLevel.count
    }
}

#Preview {
        
    NavigationStack {
        StudyProgressForLevel(studyLevel: nil)
    }
    .environmentObject(PostsViewModel())
    
}
