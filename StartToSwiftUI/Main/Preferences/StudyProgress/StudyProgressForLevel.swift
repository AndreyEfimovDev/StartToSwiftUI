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
    
    private var postsForStudyLevel: [Post] {
        if let level = studyLevel {
            return vm.allPosts.filter { $0.studyLevel == level }
        }
        return vm.allPosts
    }
    
    var body: some View {
        
        VStack (spacing: 0) {
            if let level = studyLevel {
                Text(level.displayName + " level" + " (\(totalPostsCount))")
                    .font(.title3)
                    .foregroundStyle(level.color)
            } else {
                Text("All levels" + " (\(totalPostsCount))")
                    .font(.title3)
                    .foregroundStyle(Color.mycolor.myAccent)
            }
                        
            ForEach(StudyProgress.allCases, id: \.self) { progressLevel in
                HStack {
                    
                    let count = levelPostsCount(for: progressLevel)
                    
                    Text(progressLevel.displayName + " (\(count))" + ":")
                        .font(.title3)
                        .foregroundStyle(progressLevel.color)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 30)
                    
                    Spacer()
                    
                    ProgressIndicator(progress: progressCount(for: progressLevel), colour: progressLevel.color)
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
            }
        }
        .foregroundStyle(.blue)
        .bold()
        .padding(.bottom, 45)
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
