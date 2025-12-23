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
    
    private var fontForTitle: Font {
        UIDevice.isiPad ? .body : .headline
    }
    
    private var postsForStudyLevel: [Post] {
        if let studyLevel = studyLevel {
            return vm.allPosts.filter { $0.studyLevel == studyLevel }
        }
        return vm.allPosts
    }
    
    var titleForStudyLevel: String {
        if let studyLevel = studyLevel {
            studyLevel.displayName + " materials"
        } else { "All materials" }
    }

//    private var postsCountForStudyLevel: Int {
//        if let studyLevel = studyLevel {
//            return vm.allPosts.filter({ $0.studyLevel == studyLevel }).count
//        }
//        return vm.allPosts.count
//    }

    
    var body: some View {
        
            VStack {
                // TITLE
                HStack {
                    Image(systemName: "hare")
                    Text(titleForStudyLevel + " (\(totalPostsCount))")
                        .font(.title3)
                }
                .foregroundStyle(studyLevel?.color ?? Color.mycolor.myAccent)
                .padding(.bottom)
                
                // PROGRESS VIEWS
                ForEach(StudyProgress.allCases, id: \.self) { progressLevel in
                    HStack (spacing: 0) {
                        VStack(spacing: 8) {
                            progressLevel.icon
                            HStack (alignment: .lastTextBaseline, spacing: 0){
                                Text(progressLevel.displayName)
                                Text("(\(levelPostsCount(for: progressLevel)))")
                            }
                        }
                        .foregroundStyle(progressLevel.color)
                        .font(fontForTitle)
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                        Spacer()
                        
                        ProgressIndicator(
                            progress: progressCount(for: progressLevel),
                            colour: progressLevel.color,
                            fontForTitle: fontForTitle
                        )
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                    }
                    .background(.ultraThinMaterial)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 30)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(.blue, lineWidth: 1)
                    )
                } // ForEach
            }
            .padding(.horizontal, 30)
            .bold()
            .id(refreshID)
            .onAppear {
                refreshID = UUID()
            }
    }
    
    private func progressCount(for progressLevel: StudyProgress) -> Double {
        
        guard !postsForStudyLevel.isEmpty else { return 0 }
        
        let filteredPostsForProgressLevel = postsForStudyLevel.filter { $0.progress == progressLevel }
        return Double(filteredPostsForProgressLevel.count) / Double(postsForStudyLevel.count)
    }
    
    private func levelPostsCount(for progressLevel: StudyProgress) -> Int {
        postsForStudyLevel.filter { $0.progress == progressLevel }.count
    }

    private var totalPostsCount: Int {
        postsForStudyLevel.count
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
