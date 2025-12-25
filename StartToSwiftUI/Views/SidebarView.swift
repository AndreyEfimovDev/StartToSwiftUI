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
    @EnvironmentObject private var coordinator: NavigationCoordinator
    
    @State private var visibility: NavigationSplitViewVisibility = .doubleColumn
    @State private var showPreferencesView = false
    
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
                HomeView(selectedCategory: selectedCategory)
                    .navigationSplitViewColumnWidth(430)
            } else {
                notSelectedEmptyView(text: "Select Category")
            }
        }
        detail: {
                if let selectedPostId = vm.selectedPostId {
                    PostDetailsView(postId: selectedPostId)
                    .id(selectedPostId)
                } else {
                    notSelectedEmptyView(text: "Select Topic")
                }
        }
        .sheet(isPresented: $showPreferencesView) {
            PreferencesView()
        }
        .onAppear {
            vm.selectedCategory = "SwiftUI"
        }
    }
    
    private func notSelectedEmptyView(text: String) -> some View {
        VStack {
            Image("A_1024x1024_PhosphateInline_tr")
                .resizable()
                .scaledToFit()
                .frame(width: 300)
                .opacity(0.15)
            Text(text)
                .font(.largeTitle)
                .bold()
                .padding()
        }
        .foregroundStyle(Color.mycolor.myAccent)
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
