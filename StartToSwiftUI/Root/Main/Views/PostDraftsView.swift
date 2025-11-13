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
    
//    private let hapticManager = HapticService.shared
    
    @State private var postDrafts: [Post] = []

    
    @State private var selectedPostId: String?
    @State private var selectedPost: Post?
    @State private var selectedPostToDelete: Post?
    
    @State private var showDetailView: Bool = false
    @State private var showPreferancesView: Bool = false
    @State private var showAddPostView: Bool = false
    @State private var showTermsOfUse: Bool = false
    
    
    @State private var showOnTopButton: Bool = false
    @State private var isFilterButtonPressed: Bool = false
    
    @State private var isShowingDeleteConfirmation: Bool = false
    //    @State private var isAnyChanges: Bool = false
    
    // MARK: VIEW BODY
    
    var body: some View {
        
        ForEach(vm.allPosts.filter { $0.draft == true }) { post in
            PostRowView(post: post)
        }
    }
}

#Preview {
    NavigationStack {
        PostDraftsView()
            .environmentObject(PostsViewModel())
    }
}
