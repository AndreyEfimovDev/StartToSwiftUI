//
//  SidebarView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 30.11.2025.
//

import SwiftUI
import SwiftData

struct SidebarView: View {
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var vm: PostsViewModel
    @EnvironmentObject private var noticevm: NoticeViewModel
    @EnvironmentObject private var coordinator: Coordinator
    
    @State private var visibility: NavigationSplitViewVisibility = .doubleColumn
    
    var body: some View {
        
        NavigationSplitView (columnVisibility: $visibility) {
//            if let categories = vm.allCategories {
//                List(categories, id: \.self, selection: $vm.selectedCategory) { category in
//                    //                    NavigationLink(post.title, value: post)
//                    Text(category)
//                }
//                .navigationTitle("Categories")
//            .navigationSplitViewColumnWidth(150)
//            } else {
//                Text("No categories")
//            }
            //        } content: {
            if let selectedCategory = vm.selectedCategory {
                NavigationStack(path: $coordinator.path) {
                    HomeView(selectedCategory: selectedCategory)
                        .navigationDestination(for: AppRoute.self) { route in
                        }
                }
                .navigationSplitViewColumnWidth(430)
            } else {
                postNotSelectedEmptyView(text: "Select Category")
            }
        }
        detail: {
                if let selectedPostId = vm.selectedPostId {
                    PostDetailsView(postId: selectedPostId)
                    .id(selectedPostId)
                } else {
                    postNotSelectedEmptyView(text: "Select Topic")
                }
        }
        .onAppear {
            vm.selectedCategory = "SwiftUI"
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
    let noticevm = NoticeViewModel(modelContext: context)
    
    SidebarView()
        .environmentObject(vm)
        .environmentObject(noticevm)
}
