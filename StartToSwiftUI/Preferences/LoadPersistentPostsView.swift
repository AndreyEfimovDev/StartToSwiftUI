//
//  LoadPersistenPostsView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 09.09.2025.
//

import SwiftUI

struct LoadPersistentPostsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: PostsViewModel
    
    private let hapticManager = HapticManager.shared

    @State var isLoaded: Bool = false
    @State private var postCount: Int = 0
    
    var body: some View {
        VStack {
            textSection
            .managingPostsTextFormater()

            CapsuleButtonView(
                primaryTitle: "Load Posts",
                secondaryTitle: "\(postCount) Posts Loaded!",
                isToChangeTitile: isLoaded) {
                    vm.loadPersistentPosts {
                        isLoaded.toggle()
                        hapticManager.notification(type: .success)
                    }
                }
            .onChange(of: vm.allPosts.count) { _, newValue in
                postCount = newValue
            }
            .disabled(isLoaded)
            .padding(.top, 30)
 
            Spacer()
        }
        .padding(.horizontal, 30)
        .padding(.top, 30)
        .padding(30)
    }
    
    private var textSection: some View {
        Text("""
            You are about to download initial posts to App persisted in the cloud.
            
            The persistent posts are created by the app developer themselves.
            
            The persistent posts will append all current posts in the App, excluding duplicates by post title.
            
            Enjoy!
            """)
    }
}

#Preview {
    LoadPersistentPostsView()
        .environmentObject(PostsViewModel())
    
}
