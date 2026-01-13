//
//  StudyProgressTabsView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 13.01.2026.
//

import SwiftUI
import SwiftData

struct StudyProgressView: View {
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var vm: PostsViewModel
    @EnvironmentObject private var coordinator: AppCoordinator

    @State private var selectedTab = 0
    let tabs = ["Overview", "Details"]
    
    var body: some View {
        ViewWrapperWithCustomNavToolbar(
            title: "Achievements",
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
                .background(Color(.systemBackground))
                
                TabView(selection: $selectedTab) {
                    LearningProgressChartView(posts: vm.allPosts)
                        .tag(0)
                    StudyProgressDetailsView()
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppSyncState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    
    let vm = PostsViewModel(modelContext: context)

    StudyProgressView()
        .modelContainer(container)
        .environmentObject(vm)
        .environmentObject(AppCoordinator())
}
