//
//  SidebarView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 30.11.2025.
//

import SwiftUI

struct SidebarView: View {
     
    @EnvironmentObject private var vm: PostsViewModel
    @EnvironmentObject private var noticevm: NoticeViewModel

    @State private var visibility: NavigationSplitViewVisibility = .doubleColumn

    
    @State private var categories: [String] = ["SwiftUI"]

    @State private var selectedCategory: String?
    @State private var selectedPostId: String? = nil

    var body: some View {
        
        NavigationSplitView (columnVisibility: $visibility) {
            List(vm.filteredPosts, selection: $selectedPostId) { post in
                    NavigationLink(post.title, value: post)
            }
            .navigationTitle("SwiftUI Topics")
        } detail: {
//            Group {
                if let selectedPostId {
                    VStack {
                        Text(vm.post(id: selectedPostId)?.title ?? "")
                        Text(vm.post(id: selectedPostId)?.author ?? "")
                        Text(vm.post(id: selectedPostId)?.studyLevel.displayName ?? "")
                        Text(vm.post(id: selectedPostId)?.favoriteChoice.displayName ?? "")
                    }
                    .font(.largeTitle)
                    .bold()
                    //                PostDetailsView(postId: selectedPostId)
                    .navigationTitle("Details")
                    .navigationBarTitleDisplayMode(.inline)
                } else {
                    VStack {
                        Image("AppIcon_blue_3477F5")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300)
                        Text("Select Topic")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                    }
                }
//            }
//            .toolbarVisibility(.hidden, for: .navigationBar)
        }
        .navigationSplitViewStyle(.balanced)
        .toolbar {
            Button {
                visibility = .automatic
            } label: {
                Text("Automatic")
            }
            Button {
                visibility = .all
            } label: {
                Text("All Columns")
            }
            Button {
                visibility = .doubleColumn
            } label: {
                Text("Double Column")
            }
            Button {
                visibility = .detailOnly
            } label: {
                Text("Detail Only")
            }

        }

    }
    
    
}

#Preview {
    SidebarView()
        .environmentObject(PostsViewModel())
        .environmentObject(NoticeViewModel())

}
