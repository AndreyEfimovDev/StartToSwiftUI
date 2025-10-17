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
    
    @State var isLoaded: Bool = false
    @State private var postCount: Int = 0
    
    var body: some View {
        VStack {
            Text("""
                You are about to download initial posts to App persisted in the cloud.
                
                The persistent posts are created by the app developer themselves.
                
                The persistent posts will append all current posts in the App, excluding duplicates by post title.
                
                Enjoy!
                """)
            .managingPostsTextFormater()
//            .font(.callout)
//            .foregroundStyle(Color.mycolor.accent)
//            .multilineTextAlignment(.center)
//            .padding(20)
//            .frame(maxWidth: .infinity)
//            .background(.ultraThinMaterial)
//            .clipShape(RoundedRectangle(cornerRadius: 15))
//            .overlay(
//                RoundedRectangle(cornerRadius: 15)
//                    .stroke(Color.mycolor.accent.opacity(0.3), lineWidth: 1)
//            )
            
            CapsuleButtonView(
                primaryTitle: "Load Posts",
                secondaryTitle: "\(postCount) Posts Loaded!",
                isToChangeTitile: isLoaded) {
                    vm.loadPersistentPosts {
                        isLoaded.toggle()
                    }
                }
            
            
//            Button {
//                vm.loadPersistentPosts {
//                    isLoaded.toggle()
////                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
////                            dismiss()
////                        }
//                }
//            } label: {
//                Text(isLoaded ? "\(postCount) Posts Loaded!" : "Load Posts")
//                    .font(.body)
//                    .fontWeight(.semibold)
//                    .foregroundColor(Color.mycolor.background)
//                    .frame(height: 55)
//                    .frame(maxWidth: .infinity)
//                    .background(isLoaded ? Color.mycolor.green : Color.mycolor.blue)
//                    .cornerRadius(30)
//                    .padding(.top, 30)
//
//            }
            .onChange(of: vm.allPosts.count, { oldValue, newValue in
                postCount = newValue
            })
            .disabled(isLoaded)
            .padding(.top, 30)
 
            Spacer()
        }
        .padding(.horizontal, 30)
        .padding(.top, 30)
        .padding(30)
    }
}

#Preview {
    LoadPersistentPostsView()
        .environmentObject(PostsViewModel())
    
}
