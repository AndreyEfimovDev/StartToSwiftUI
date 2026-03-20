//
//  ArchivedPostsView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.02.2026.
//

import SwiftUI
import SwiftData

struct DeletedPostsView: View {
    
    // MARK: - Dependencies
    @EnvironmentObject private var vm: PostsViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    
    private let hapticManager = HapticManager.shared
    
    @State private var selectedPostToDelete: Post?
    @State private var isShowingDeleteConfirmation: Bool = false

    // MARK: - Computed Properties
    private var deletedPosts: [Post] {
        vm.allPosts.filter { $0.status == .deleted }
    }

    // MARK: Body
    var body: some View {
        FormCoordinatorToolbar(
            title: "Deleted materials",
            showHomeButton: true
        ) {
            
            Group {
                if deletedPosts.isEmpty {
                    emptyView(text: "No Deleted Materials", subText: "")
                } else {
                    List { deletedPostsSection }
                        .scrollContentBackground(.hidden)
                }
            }
            .background(StatusOptions.deleted.color.opacity(0.5))
            .disabled(isShowingDeleteConfirmation)
            .overlay {
                if isShowingDeleteConfirmation {
                    postEraseConfirmation
                }
            }
        }
    }
        
    private var postEraseConfirmation: some View {
        ZStack {
            Color.mycolor.myAccent.opacity(0.001)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    isShowingDeleteConfirmation = false
                }
            VStack(spacing: 8) {
                Text("Permanently erase the material?")
                    .font(.headline)
                    .foregroundColor(Color.mycolor.myRed)
                    .multilineTextAlignment(.center)
                    .padding(.vertical)
                Text(selectedPostToDelete?.title ?? "No material selected")
                    .font(.subheadline)
                    .foregroundColor(Color.mycolor.myAccent)
                    .minimumScaleFactor(0.75)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
                Text("This cannot be undone.")
                    .font(.caption2)
                    .foregroundColor(Color.mycolor.myAccent)
                    .padding(.vertical)
                ClearCupsuleButton(
                    primaryTitle: "Erase",
                    primaryTitleColor: Color.mycolor.myRed) {
                        withAnimation {
                            vm.erasePost(selectedPostToDelete)
                            hapticManager.notification(type: .success)
                            isShowingDeleteConfirmation = false
                        }
                    }
                ClearCupsuleButton(
                    primaryTitle: "Cancel",
                    primaryTitleColor: Color.mycolor.myAccent) {
                        isShowingDeleteConfirmation = false
                    }
            }
            .padding()
            .background(.ultraThinMaterial)
            .menuFormater()
            .padding(.horizontal, 40)
        }
    }
    
    private func emptyView(text: String, subText: String) -> some View {
        ContentUnavailableView(
            text,
            systemImage: "square.stack.3d.up",
            description: Text(subText)
        )
    }

}

extension DeletedPostsView {
    
    @ViewBuilder
    private var deletedPostsSection: some View {
        ForEach(deletedPosts) { post in
            PostRowView(post: post)
                .swipeActions(edge: .trailing) {
                    Button("Erase", systemImage: "trash") { // xmark.bin
                        selectedPostToDelete = post
                        hapticManager.notification(type: .warning)
                        isShowingDeleteConfirmation = true
                    }
                    .tint(Color.mycolor.myRed)
                    
                    Button("Restore", systemImage: "arrow.uturn.left") {
                        vm.setPostActive(post)
                    }
                    .tint(Color.mycolor.myGreen)
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
    
    let hiddenPost = Post(title: "Hidden Post", intro: "Some intro", author: "Author")
    hiddenPost.status = .hidden
    context.insert(hiddenPost)
    
    let deletedPost = Post(title: "Deleted Post", intro: "Some intro", author: "Author")
    deletedPost.status = .deleted
    context.insert(deletedPost)
    
    let vm = PostsViewModel(modelContext: context)
    vm.loadPostsFromSwiftData()
    
    return DeletedPostsView()
        .modelContainer(container)
        .environmentObject(vm)
        .environmentObject(AppCoordinator())
}
