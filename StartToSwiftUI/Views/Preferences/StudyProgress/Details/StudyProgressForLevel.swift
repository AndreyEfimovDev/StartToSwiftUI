//
//  StudyProgressForLevel.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 04.12.2025.
//

import SwiftUI
import SwiftData

struct StudyProgressForLevel: View {
    
    @EnvironmentObject private var vm: PostsViewModel
    @State private var refreshID = UUID()

    let studyLevel: StudyLevel?
    
    private var fontForSectionTitle: Font {
        UIDevice.isiPad ? .subheadline : .headline
    }
    
    private var lineWidth: Double {
        UIDevice.isiPad ? 4.0 : 8.0
    }

    var titleForStudyLevel: String {
        if let studyLevel = studyLevel {
            studyLevel.displayName
        } else { "All" }
    }

    private var postsForStudyLevel: [Post] {
        if let studyLevel = studyLevel {
            return vm.allPosts.filter { $0.studyLevel == studyLevel}
        }
        return vm.allPosts
    }
    
    var body: some View {
        
        VStack {
            // TITLE
            sectionTitle
            
            // PROGRESS VIEWS
            ForEach([StudyProgress.practiced, StudyProgress.studied , StudyProgress.started, StudyProgress.fresh], id: \.self) { progressLevel in
                HStack (spacing: 0) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack (spacing: 3){
                            progressLevel.icon
                            Text(progressLevel.displayName)
                        }
                        Text("\(levelPostsCount(for: progressLevel))")
                            .foregroundStyle(Color.mycolor.myAccent)
                    }
                    .foregroundStyle(progressLevel.color)
                    .font(fontForSectionTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
                    
                    Spacer()
                    
                    ProgressIndicator(
                        progress: progressCount(for: progressLevel),
                        colour: progressLevel.color,
                        fontForTitle: fontForSectionTitle,
                        lineWidth: lineWidth
                    )
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                }
                .background(.ultraThinMaterial)
                .clipShape(
                    RoundedRectangle(cornerRadius: 15)
                )
//                .overlay(
//                    RoundedRectangle(cornerRadius: 15)
//                        .stroke(.blue, lineWidth: 1)
//                )
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
        
        let filteredPostsForProgressLevel = postsForStudyLevel.filter { $0.progress == progressLevel }
        return Double(filteredPostsForProgressLevel.count) / Double(postsForStudyLevel.count)
    }
    
    private func levelPostsCount(for progressLevel: StudyProgress) -> Int {
        postsForStudyLevel.filter { $0.progress == progressLevel }.count
    }

}

#Preview {
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppSyncState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    
    let vm = PostsViewModel(modelContext: context)
        
    NavigationStack {
        StudyProgressForLevel(studyLevel: nil)
    }
    .environmentObject(vm)
    
}
