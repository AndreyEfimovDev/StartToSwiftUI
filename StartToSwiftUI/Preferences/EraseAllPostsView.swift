//
//  EraseAllPostsView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 09.09.2025.
//

import SwiftUI

struct EraseAllPostsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: PostsViewModel
    
    private let hapticManager = HapticManager.shared
    
    @State private var isDeleted: Bool = false
    @State private var isShowingShareBackupSheet: Bool = false
    @State private var isInProgress = false
    
    @State private var postCount: Int = 0
    
    var body: some View {
        VStack {
            textSection
                .managingPostsTextFormater()
            
            CapsuleButtonView(
                primaryTitle: "Erase All Posts",
                secondaryTitle: "\(postCount) Posts Erased!",
                buttonColorPrimary: Color.mycolor.myRed,
                buttonColorSecondary: Color.mycolor.myGreen,
                isToChangeTitile: isDeleted) {
                    isInProgress = true
                    vm.eraseAllPosts{
                        isDeleted = true
                        isInProgress = false
                        hapticManager.notification(type: .success)
                        DispatchQueue.main.asyncAfter(deadline: vm.dispatchTime) {
                            dismiss()
                        }
                    }
                }
                .padding(.top, 30)
                .onChange(of: vm.allPosts.count, { oldValue, _ in
                    postCount = oldValue
                })
                .disabled(isDeleted)
            
            Spacer()
            
            if isInProgress {
                ProgressView("Erasing posts...")
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal, 30)
        .padding(.top, 30)
        .padding(30)
        .onAppear {
            hapticManager.notification(type: .warning)
        }
    }
    
    // MARK: Subviews

    private var textSection: some View {
        VStack(spacing: 12) {
            Text("""
            You are about to delete all posts.
            
            What you can do after:
            """
            )
            
            Text("""
            - create a single post,
            - import pre-loaded posts, or
            - restore backup.
            """
            )
            .multilineTextAlignment(.leading)
            
            Text("""
            It is recommended to
            backup posts before
            erasing them.
            """)
            .foregroundStyle(.red)
            .bold()
        }
    }
}

#Preview {
    EraseAllPostsView()
        .environmentObject(PostsViewModel())
    
}
