//
//  PostDraftsView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 13.11.2025.
//

import SwiftUI
import SwiftData

struct PostDraftsView: View {
    
    @EnvironmentObject private var vm: PostsViewModel
    @EnvironmentObject private var coordinator: AppCoordinator

    private let hapticManager = HapticManager.shared
        
    var body: some View {
        FormCoordinatorToolbar(
            title: "Post drafts",
            showHomeButton: true
        ) {
            ZStack(alignment: .bottomTrailing) {
                if vm.hasDrafts {
                    draftsList
                } else {
                    postDraftsIsEmpty
                }
            }
        }
    }
    
    private var draftsList: some View {
        List {
            ForEach(vm.drafts) { post in
                PostDraftsRowView(post: post)
                    .background(.black.opacity(0.001))
                    .onTapGesture {
                        coordinator.pushModal(.editPost(post))
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button("Delete", systemImage: "trash") {
                            withAnimation {
                                vm.deletePost(post)
                                hapticManager.notification(type: .success)
                            }
                        }
                        .tint(Color.mycolor.myRed)
                    }
            }
            .listRowBackground(Color.clear)
            .listRowSeparatorTint(Color.mycolor.myAccent.opacity(0.35))
            .listRowSeparator(.hidden, edges: [.top])
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
        .listStyle(.plain)
    }

    private var postDraftsIsEmpty: some View {
        ContentUnavailableView(
            "No Post Drafts",
            systemImage: "square.stack.3d.up",
            description: Text("Post drafts will appear here when you save drafts.")
        )
    }
    
}

#Preview("With Drafts") {
    let vm = PostsViewModel(dataSource: MockPostsDataSource())
    vm.allPosts = PreviewData.samplePostsWithDrafts
    
    return PostDraftsView()
        .environmentObject(vm)
        .environmentObject(AppCoordinator())
}

#Preview("Empty Drafts") {
    let vm = PostsViewModel(dataSource: MockPostsDataSource())
    vm.allPosts = PreviewData.samplePosts  // Without draft: true
    
    return PostDraftsView()
        .environmentObject(vm)
        .environmentObject(AppCoordinator())
}
