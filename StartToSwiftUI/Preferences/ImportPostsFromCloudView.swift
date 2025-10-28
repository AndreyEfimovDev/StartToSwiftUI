//
//  CloudImportView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.10.2025.
//

import SwiftUI

struct ImportPostsFromCloudView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: PostsViewModel
    
    private let hapticManager = HapticManager.shared
    private let selectedURL = Constants.cloudPostsURL
    
    @State private var isInProgress: Bool = false
    @State private var isImported: Bool = false
    @State private var postCount: Int = 0
    
    var body: some View {
        
        VStack {
            textSection
                .managingPostsTextFormater()
            
            CapsuleButtonView(
                primaryTitle: "Import Posts",
                secondaryTitle: "\(postCount) Posts Imported",
                isToChangeTitile: isImported) {
                    isInProgress = true
                    importFromCloud()
                }
                .onChange(of: vm.allPosts.count) { oldValue, newValue in
                    postCount = newValue - oldValue
                }
                .disabled(isImported)
                .padding(.top, 30)
            
            Spacer()
            
            if isInProgress {
                ProgressView("Importing posts...")
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal, 30)
        .padding(.top, 30)
        .padding(30)
        .alert("Import Error", isPresented: $vm.showCloudImportAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(vm.cloudImportError ?? "Unknown error")
        }
    }
    
    // MARK: Subviews

    private var textSection: some View {
        Text("""
            You are about to import pre-loaded posts from the cloud.
                       
            The pre-loaded posts will append all current posts in the App, excluding duplicates by post title.
            
            """)
    }
    
    private func importFromCloud() {

//        vm.loadPersistentPosts() {
//            isInProgress = false
//            isImported = true
//            hapticManager.notification(type: .success)
//            DispatchQueue.main.asyncAfter(deadline: vm.dispatchTime) {
//                dismiss()
//            }
//        }
        
        vm.importPostsFromCloud(urlString: selectedURL) {
            isInProgress = false
            isImported = true
            hapticManager.notification(type: .success)
            DispatchQueue.main.asyncAfter(deadline: vm.dispatchTime) {
                dismiss()
            }
        }
        
    } // func importFromCloud()
    
}

#Preview {
    ImportPostsFromCloudView()
        .environmentObject(PostsViewModel())
}
