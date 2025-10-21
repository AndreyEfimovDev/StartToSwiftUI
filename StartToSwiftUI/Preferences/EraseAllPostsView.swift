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
    
    @State var isDeleted: Bool = false
    @State var isShowingShareBackupSheet: Bool = false
    
    
    @State private var postCount: Int = 0
    
    var body: some View {
        VStack {
            VStack(spacing: 12) {
                Text("""
                You are about to delete all posts.
                
                What you can do next:
                """
                )
                //                .multilineTextAlignment(.center)
                
                Text("""
                - create a single post,
                - load persistent App posts, or
                - load back-up from your device.
                """
                )
                .multilineTextAlignment(.leading)
                
                Text("""
                ***
                It is recommended to
                Backup Posts before
                erasing them.
                ***
                """)
                .foregroundStyle(.red)
                .bold()
                
                //                .multilineTextAlignment(.center)
            }
            .managingPostsTextFormater()
            
            CapsuleButtonView(
                primaryTitle: "Share/Backup Posts") {
                    isShowingShareBackupSheet.toggle()
                }
                .padding(.top, 30)
                .disabled(isDeleted)
                .sheet(isPresented: $isShowingShareBackupSheet) {
                    ShareStorePostsView()
                }
            
            CapsuleButtonView(
                primaryTitle: "Erase All Posts",
                secondaryTitle: "\(postCount) Posts Erased!",
                buttonColorPrimary: Color.mycolor.myRed,
                buttonColorSecondary: Color.mycolor.myGreen,
                isToChangeTitile: isDeleted) {
                    vm.eraseAllPosts{
                        isDeleted.toggle()
                    }
                }
                .onChange(of: vm.allPosts.count, { oldValue, newValue in
                    postCount = oldValue
                })
                .disabled(isDeleted)
            Spacer()
        }
        .padding(.horizontal, 30)
        .padding(.top, 30)
        .padding(30)
        .onAppear {
            hapticManager.notification(type: .warning)
        }
    }
}

#Preview {
    EraseAllPostsView()
        .environmentObject(PostsViewModel())
    
}
