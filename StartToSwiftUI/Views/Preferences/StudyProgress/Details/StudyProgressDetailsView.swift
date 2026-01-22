//
//  StudyProgressView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 04.12.2025.
//

import SwiftUI
import SwiftData

struct StudyProgressDetailsView: View {
    
    let posts: [Post]

    @EnvironmentObject private var coordinator: AppCoordinator
    
    @State private var selectedTab: StudyLevelTabs = .all
    
    private var tabs: [StudyLevelTabs] {
        [.all, .beginner, .middle, .advanced]
    }
    
    var body: some View {
        VStack(spacing: 0)  {
            Group {
                switch selectedTab {
                case .all:
                    StudyProgressForLevel(posts: posts, studyLevel: nil)
                        .opacity(selectedTab == .all ? 1 : 0)
                case .beginner:
                    StudyProgressForLevel(posts: posts, studyLevel: .beginner)
                        .opacity(selectedTab == .beginner ? 1 : 0)
                case .middle:
                    StudyProgressForLevel(posts: posts, studyLevel: .middle)
                        .opacity(selectedTab == .middle ? 1 : 0)
                case .advanced:
                    StudyProgressForLevel(posts: posts, studyLevel: .advanced)
                        .opacity(selectedTab == .advanced ? 1 : 0)
                }
            }
            .transition(.slide)
            .animation(.linear(duration: 0.3), value: selectedTab)
            
            Spacer()
            
            UnderlineSermentedPickerNotOptional(
                selection: $selectedTab,
                allItems: StudyLevelTabs.allCases,
                titleForCase: { $0.displayName },
                selectedFont: UIDevice.isiPad ? .footnote : .subheadline
            )
            .padding(.horizontal)
            .padding(.top)
        }
        .padding()
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
        
        Post(title: "Post 4", intro: "Intro 4", studyLevel: .middle, progress: .fresh),
        
        Post(title: "Post 5", intro: "Intro 5", studyLevel: .beginner, progress: .started)
            .withDateStamp(.started, date: now),
        
        Post(title: "Post 6", intro: "Intro 6", studyLevel: .advanced, progress: .studied)
            .withDateStamp(.started, date: calendar.date(byAdding: .month, value: -4, to: now)!)
            .withDateStamp(.studied, date: calendar.date(byAdding: .month, value: -3, to: now)!),
    ]
    
    let postsVM = PostsViewModel(
        dataSource: MockPostsDataSource(posts: extendedPosts)
    )

    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppSyncState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    NavigationStack{
        StudyProgressDetailsView(posts: postsVM.allPosts)
            .environmentObject(postsVM)
            .environmentObject(AppCoordinator())
    }
}
