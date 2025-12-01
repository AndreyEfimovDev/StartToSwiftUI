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
//    @StateObject private var speechRecogniser = SpeechRecogniser()

    @State private var visibility: NavigationSplitViewVisibility = .doubleColumn

//    @State private var selectedPostId: String? = nil

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
                    .navigationSplitViewColumnWidth(400)
            } else {
                notSelectedEmptyView(text: "Select Category")
            }
        }
        detail: {
                if let selectedPostId = vm.selectedPostId {
                    PostDetailsView(postId: selectedPostId)
                    .navigationTitle("Details")
                    .navigationBarTitleDisplayMode(.inline)
                } else {
                    notSelectedEmptyView(text: "Select Topic")
                }
        }
        .sheet(isPresented: $showPreferencesView) {
            PreferencesView()
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
    }
    
}

#Preview {
    SidebarView()
        .environmentObject(PostsViewModel())
        .environmentObject(NoticeViewModel())
}
