//
//  ArchivedPostsView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.02.2026.
//

import SwiftUI

struct ArchivedPostsView: View {
    
    // MARK: - Dependencies
    @EnvironmentObject private var vm: PostsViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    
    private let hapticManager = HapticManager.shared
    
    @State private var selectedPostToDelete: Post?
    @State private var isShowingDeleteConfirmation: Bool = false
    @State private var selectedTab: PostStatus = .hidden
   
    let tabs: [PostStatus] = [.hidden, .deleted]

    // MARK: - Computed Properties
    private var hiddenPosts: [Post] {
        vm.allPosts.filter { $0.status == .hidden }
    }
    
    private var deletedPosts: [Post] {
        vm.allPosts.filter { $0.status == .deleted }
    }

    private var disableView: Bool {
        isShowingDeleteConfirmation
    }

    // MARK: Body
    var body: some View {
        FormCoordinatorToolbar(
            title: "Managing archived posts",
            showHomeButton: true
        ) {
            VStack {
                UnderlineSermentedPickerNotOptional(
                    selection: $selectedTab,
                    allItems: tabs,
                    titleForCase: { $0.displayName },
                    selectedFont: .footnote
                )
                .padding()
                
                if selectedTab == .hidden {
                    List { hiddenSection }
                } else {
                    List { deletedSection }
                }
            }
            .disabled(disableView)
            .overlay { deleteConfirmationOverlay }
            .onAppear {
                if hiddenPosts.isEmpty {
                    selectedTab = .deleted
                }
            }
        }
    }
    
    @ViewBuilder
    private var deleteConfirmationOverlay: some View {
        if isShowingDeleteConfirmation {
            postDeletionConfirmation
                .transition(.move(edge: .bottom))
        }
    }
    
    private var postDeletionConfirmation: some View {
        ZStack {
            Color.mycolor.myAccent.opacity(0.001)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    isShowingDeleteConfirmation = false
                }
            VStack(spacing: 8) {
                Text("Are you sure you want to delete the material?")
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
                    primaryTitle: "Delete",
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
}

extension ArchivedPostsView {
        
    @ViewBuilder
    private var hiddenSection: some View {
        ForEach(hiddenPosts) { post in
            PostRowView(post: post)
                .swipeActions(edge: .trailing) {
                    Button("Delete", systemImage: "trash") {
                        vm.setPostDeleted(post)
                    }
                    .tint(Color.mycolor.myRed)
                    
                    Button("Restore", systemImage: "eye") {
                        vm.setPostActive(post)
                    }
                    .tint(Color.mycolor.myGreen)
                }
        }
    }
    
    @ViewBuilder
    private var deletedSection: some View {
        ForEach(deletedPosts) { post in
            PostRowView(post: post)
                .swipeActions(edge: .trailing) {
                    Button("Erase", systemImage: "trash.fill") {
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
    ArchivedPostsView()
}
