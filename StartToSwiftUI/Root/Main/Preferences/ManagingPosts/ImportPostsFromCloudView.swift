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
    //    private let selectedURL = Constants.cloudPostsURL
    
    @State private var isInProgress: Bool = false
    @State private var isLoaded: Bool = false
    
    @State private var postCount: Int = 0
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            VStack {
                textSection
                    .managingPostsTextFormater()
                
                CapsuleButtonView(
                    primaryTitle: "Confirm and Download",
                    secondaryTitle: "\(postCount) Posts Downloaded",
                    isToChange: isLoaded) {
                        isInProgress = true
                        importFromCloud()
                    }
                    .onChange(of: vm.allPosts.count) { oldValue, newValue in
                        postCount = newValue - oldValue
                    }
                    .disabled(isLoaded)
                    .padding(.top, 30)
                
                CapsuleButtonView(
                    primaryTitle: "Don't confirm",
                    textColorPrimary: Color.mycolor.myButtonTextRed,
                    buttonColorPrimary: Color.mycolor.myButtonBGRed) {
                        dismiss()
                    }
                    .opacity(isLoaded ? 0 : 1)
                
                Spacer()
                
            }
            if isInProgress {
                CustomProgressView()
            }
        }
        .padding(.horizontal, 30)
        .padding(.top, 30)
        .alert("Download Error", isPresented: $vm.showErrorMessageAlert) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        } message: {
            Text(vm.errorMessage ?? "Unknown error")
        }
        .navigationTitle("Import posts from cloud")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                CircleStrokeButtonView(iconName: "chevron.left", isShownCircle: false) {
                    dismiss()
                }
            }
        }

    }
    
    
    // MARK: Subviews
    
    private var textSection: some View {
        VStack {
            Group {
                Text("""
                    The curated collection of links to SwiftUI tutorials and articles are compiled by the developer from open sources for the purpose of learning the SwiftUI functionality.

                    """)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("**IMPORTANT NOTICE:**")
                    .foregroundStyle(Color.mycolor.myRed)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("""
                Clicking **Confirm and Download** constitutes your agreement to the following terms:
                
                """)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("""
                1. The materials will be used solely for non-commercial educational purposes.
                2. All intellectual property rights in the materials are retained by the original authors.
                3. You will make every effort to access and reference the original source materials.
                """
                )
                .font(.subheadline)
            }
            .multilineTextAlignment(.leading)
        }

    }
    
    private func importFromCloud() {
        
//                vm.loadPersistentPosts() {
//                    isInProgress = false
//                    isLoaded = true
//        //            vm.isFirstImportPostsCompleted = true
//                    hapticManager.notification(type: .success)
//                    DispatchQueue.main.asyncAfter(deadline: vm.dispatchTime) {
//                        dismiss()
//                    }
//                }
        
        
        vm.importPostsFromCloud() {
            isInProgress = false
            if !vm.showErrorMessageAlert {
                isLoaded = true
                if !vm.isFirstImportPostsCompleted {
                    vm.isFirstImportPostsCompleted = true
                }
                hapticManager.notification(type: .success)
                DispatchQueue.main.asyncAfter(deadline: vm.dispatchTime) {
                    dismiss()
                }
            }
        }
        
        
    } // func importFromCloud()
    
}

#Preview {
    NavigationStack{
        ImportPostsFromCloudView()
            .environmentObject(PostsViewModel())
    }
}
