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
                .opacity(vm.isFirstImportPostsCompleted ? 0 : 1)
            
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
            The curated collection of links to SwiftUI tutorials and articles are compiled by the developer from open sources for the purpose of learning the SwiftUI functionality.
            """)
            .multilineTextAlignment(.leading)

            
            Group {
                Text("""
                    
                    **IMPORTANT NOTICE**
                    
                    **Clicking
                    "Confirm and Download"
                    constitutes your agreement to the following terms:**:
                    
                    """)

                Text("""
                1. The materials will be used solely for non-commercial educational purposes.
                2. All intellectual property rights in the materials are retained by the original authors.
                3. You will make every effort to access and reference the original source materials.
                """
                )
                .font(.subheadline)
                .multilineTextAlignment(.leading)
            }
            .foregroundStyle(Color.mycolor.myRed)
        }
    }
    
    private func importFromCloud() {

        vm.loadPersistentPosts() {
            isInProgress = false
            vm.isFirstImportPostsCompleted = true
            hapticManager.notification(type: .success)
            DispatchQueue.main.asyncAfter(deadline: vm.dispatchTime) {
                dismiss()
            }
        }
        
//        vm.importPostsFromCloud(urlString: selectedURL) {
//            isInProgress = false
//            vm.isFirstImportPostsCompleted = true
//            hapticManager.notification(type: .success)
//            DispatchQueue.main.asyncAfter(deadline: vm.dispatchTime) {
//                dismiss()
//            }
//        }
    } // func importFromCloud()
    
}

#Preview {
    ImportPostsFromCloudView()
        .environmentObject(PostsViewModel())
}
