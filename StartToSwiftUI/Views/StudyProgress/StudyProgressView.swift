//
//  StudyProgressTabsView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 13.01.2026.
//

import SwiftUI
import SwiftData

struct StudyProgressView: View {
    
    @EnvironmentObject private var vm: PostsViewModel
    @EnvironmentObject private var coordinator: AppCoordinator

    @State private var selectedTab = 0
    let tabs = ["Overview", "Details"]
    
    var body: some View {
        FormCoordinatorToolbar(
            title: "Study progress",
            showHomeButton: true
        ) {
            VStack(spacing: 0) {
                Picker("Select tab", selection: $selectedTab) {
                    ForEach(0..<tabs.count, id: \.self) { index in
                        Text(tabs[index])
                            .tag(index)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .background(Color.mycolor.myBackground)
                
                TabView(selection: $selectedTab) {
                    StudyProgressChartView(posts: vm.filteredPosts.filter { !$0.draft })
                        .tag(0)
                    StudyProgressDetailsView(posts: vm.filteredPosts.filter { !$0.draft })
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
    }
}

#Preview("With Extended Posts") {
    
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

    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppSyncState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    NavigationStack {
        StudyProgressView()
            .modelContainer(container)
            .environmentObject(postsVM)
            .environmentObject(AppCoordinator())
            .onAppear {
                print("🔍 Preview: Total test posts = \(extendedPosts.count)")
                print("🔍 Preview: Posts in VM = \(postsVM.allPosts.count)")
            }


    }
}

// Extension for easy date creation
extension Post {
    func withDateStamp(_ type: StudyProgress, date: Date) -> Post {
        switch type {
        case .started: self.startedDateStamp = date
        case .studied: self.studiedDateStamp = date
        case .practiced: self.practicedDateStamp = date
        default: break
        }
        return self
    }
}




