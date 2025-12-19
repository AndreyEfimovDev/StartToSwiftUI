//
//  PostDraftsView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 13.11.2025.
//

import SwiftUI
import SwiftData

struct PostDraftsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: PostsViewModel
    
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
                                selectedPost = post
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
            ToolbarItem(placement: .navigationBarLeading) {
                CircleStrokeButtonView(
                    iconName: "chevron.left",
                    imageColorPrimary: Color.mycolor.myAccent,
                    isShownCircle: false
                ) {
                    dismiss()
                }
            }
        }
        .navigationDestination(item: $selectedPost) {selectedPostToEdit in
            AddEditPostSheet(post: selectedPostToEdit)
        }
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
        for: Post.self, Notice.self, AppState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    
    let vm = PostsViewModel(modelContext: context)
    
    NavigationStack {
        PostDraftsView()
            .environmentObject(vm)
    }
}
