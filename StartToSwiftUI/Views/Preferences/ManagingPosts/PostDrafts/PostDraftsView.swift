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
    @EnvironmentObject private var coordinator: NavigationCoordinator

    private let hapticManager = HapticService.shared
    
    @State private var selectedPost: Post?
    @State private var selectedPostToDelete: Post?
    
    // MARK: VIEW BODY
    
    var body: some View {
        ZStack (alignment: .bottomTrailing) {
            
            if vm.allPosts.filter({ $0.draft == true }).isEmpty {
                postDraftsIsEmpty
            } else {
                List {
                    ForEach(vm.allPosts.filter { $0.draft == true }) { post in
                        PostDraftsRowView(post: post)
                            .background(.black.opacity(0.001))
                            .onTapGesture {
                                coordinator.push(.editPost(post))
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Delete", systemImage: "trash") {
                                    selectedPostToDelete = post
                                    withAnimation {
                                        vm.deletePost(post: selectedPostToDelete ?? nil)
                                        hapticManager.notification(type: .success)
                                    }
                                }.tint(Color.mycolor.myRed)
                            }
                    } // ForEach
                    .listRowBackground(Color.clear)
                    .listRowSeparatorTint(Color.mycolor.myAccent.opacity(0.35))
                    .listRowSeparator(.hidden, edges: [.top])
                    .listRowInsets(
                        EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                    )
                } // List
                .listStyle(.plain)
            } // if empty
        } // ZStack
        .navigationTitle("Post drafts")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButtonView() {
                    coordinator.pop()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    coordinator.popToRoot()
                } label: {
                    Image(systemName: "house")
                        .foregroundStyle(Color.mycolor.myAccent)
                }
            }
        }
//        .navigationDestination(item: $selectedPost) {selectedPostToEdit in
//            AddEditPostSheet(post: selectedPostToEdit)
//        }
    }
    
    private var postDraftsIsEmpty: some View {
        ContentUnavailableView(
            "No Post Drafts",
            systemImage: "square.stack.3d.up",
            description: Text("Post drafts will appear here when you save drafts.")
        )
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
        PostDraftsView()
            .environmentObject(vm)
            .environmentObject(NavigationCoordinator())
    }
}
