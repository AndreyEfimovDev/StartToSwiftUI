//
//  PostDraftsView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 13.11.2025.
//

import SwiftUI

struct PostDraftsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: PostsViewModel
    
    private let hapticManager = HapticService.shared
    
    //    @State private var postDrafts: [Post] = []
    
    
    //    @State private var selectedPostId: String?
    @State private var selectedPost: Post?
    @State private var selectedPostToDelete: Post?
    
    //    @State private var showDetailView: Bool = false
    //    @State private var showPreferancesView: Bool = false
    //    @State private var showAddPostView: Bool = false
    //    @State private var showTermsOfUse: Bool = false
    
    
    //    @State private var showOnTopButton: Bool = false
    //    @State private var isFilterButtonPressed: Bool = false
    
    //    @State private var isShowingDeleteConfirmation: Bool = false
    //    @State private var isAnyChanges: Bool = false
    
    // MARK: VIEW BODY
    
    var body: some View {
        ZStack (alignment: .bottomTrailing) {
            
            if vm.allPosts.filter({ $0.draft == true }).isEmpty {
                postDraftsIsEmpty
            } else {
                    List {
                        ForEach(vm.allPosts.filter { $0.draft == true }) { post in
                            PostDraftsRowView(post: post)
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
                        }
//                        .onDelete(perform: deleteDraftPost)
                    } // List
                    .navigationTitle("Post drafts")
//                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(.ultraThinMaterial, for: .navigationBar)

//                    .toolbar {
//                        ToolbarItem(placement: .topBarTrailing) {
//                            EditButton()
//                        }
//                    }
            }
        }
        .fullScreenCover(item: $selectedPost) { selectedPostToEdit in
            AddEditPostSheet(post: selectedPostToEdit)
        } // ForEach

    }
    
    private var postDraftsIsEmpty: some View {
        ContentUnavailableView(
            "No Post Drafts",
            systemImage: "square.stack.3d.up",
            description: Text("Post drafts will appear here when you save drafts.")
        )
    }
    
//    private func deleteDraftPost(at offsets: IndexSet) {
//        withAnimation {
//            for index in offsets {
//                let post = vm.allPosts.filter { $0.draft == true }[index]
//                vm.deletePost(post: post)
//            }
//            hapticManager.notification(type: .success)
//        }
//    }
    
    
    
}

#Preview {
    NavigationStack {
        PostDraftsView()
            .environmentObject(PostsViewModel())
    }
}
