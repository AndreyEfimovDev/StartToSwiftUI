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
    
    private let hapticManager = HapticService.shared
    private let selectedURL = Constants.cloudPostsURL
    
    @State private var isInProgress: Bool = false
    @State private var isImported: Bool = false
    @State private var postCount: Int = 0
    
    var body: some View {
        
        VStack {
            textSection
                .managingPostsTextFormater()
            
            CapsuleButtonView(
                primaryTitle: "Confirm and Download",
                secondaryTitle: "\(postCount) Posts Downloaded",
                isToChange: vm.isFirstImportPostsCompleted) {
                    isInProgress = true
                    importFromCloud()
                }
                .onChange(of: vm.allPosts.count) { oldValue, newValue in
                    postCount = newValue - oldValue
                }
                .disabled(vm.isFirstImportPostsCompleted)
                .padding(.top, 30)
            
            CapsuleButtonView(
                primaryTitle: "Don't confirm",
                textColorPrimary: Color.mycolor.myButtonTextRed,
                buttonColorPrimary: Color.mycolor.myButtonBGRed) {
                    dismiss()
                }
//                .padding(.top, 30)
            
            Spacer()
            
            if isInProgress {
                ProgressView("Downloading posts...")
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal, 30)
        .padding(.top, 30)
        .padding(30)
        .alert("Download Error", isPresented: $vm.showCloudImportAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(vm.cloudImportError ?? "Unknown error")
        }
    }
    
    // MARK: Subviews

    private var textSection: some View {
        VStack {
            Text("""
            The curated collection of links to SwiftUI tutorials and articles has been compiled from open sources by the developer for the purpose of learning the SwiftUI functionality.
            """)
            
            Group {
                Text("""
                    
                    **Please confirm that you**:
                    
                    """)
//                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)

                Text("""
                1. Will use the materials only for non-commercial educational purposes
                2. Understand that all rights to the materials belong to their authors
                3. Commit to accessing original sources
                """
                )
                .font(.subheadline)
                .multilineTextAlignment(.leading)
            }
            .foregroundStyle(Color.mycolor.myRed)
//            .multilineTextAlignment(.leading)
        }
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
            vm.isFirstImportPostsCompleted = true
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
