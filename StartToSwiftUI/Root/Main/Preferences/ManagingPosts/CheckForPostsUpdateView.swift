//
//  CheckForPostsUpdateView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 27.10.2025.
//

import SwiftUI

struct CheckForPostsUpdateView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: PostsViewModel
    
    private let hapticManager = HapticService.shared
//    private let selectedURL = Constants.cloudPostsURL
    
    @State private var followingText: String = "Checking for updates..."
    @State private var followingTextColor: Color = Color.mycolor.myAccent
    
    @State private var isInProgress: Bool = true
    @State private var isPostsUpdateAvailable: Bool = false
    @State private var isPostsUpdated: Bool = false
    @State private var isImported: Bool = false
    @State private var postCount: Int = 0
    
    var body: some View {
            VStack {
                Form {
                    section_1
                    section_2
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: vm.dispatchTime + 1) {
                    checkForUpdates()
                }
            }
            .alert("Import Error", isPresented: $vm.showErrorMessageAlert) {
                Button("OK", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text(vm.errorMessage ?? "Unknown error")
            }
            .navigationTitle("Check for posts update")
            .navigationBarBackButtonHidden(true)
//            .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
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
    
    private var section_1: some View {
        Section {
            HStack {
                Text(followingText)
                    .foregroundStyle(followingTextColor)
                Spacer()
                if isInProgress {
                    CustomProgressView(scale: 1)
                }
            }
            HStack {
                Text("Last update from:")
                Spacer()
                Text(vm.localLastUpdated.formatted(date: .numeric, time: .omitted))
            }
        }
        .foregroundStyle(Color.mycolor.myAccent)

    }
    
    private var section_2: some View {
        Group {
            textSection
                .managingPostsTextFormater()
                .padding(.horizontal, 30)
            
            if !isPostsUpdated && !isInProgress {
                CapsuleButtonView(
                    primaryTitle: "Update now",
                    secondaryTitle: "Imported \(postCount) posts",
                    isToChange: isImported) {
                        
                        isInProgress = true
                        vm.importPostsFromCloud() {
                            isInProgress = false
                            isImported = true
                            hapticManager.notification(type: .success)
                            DispatchQueue.main.asyncAfter(deadline: vm.dispatchTime) {
                                dismiss()
                            }
                        }
                    }
                    .onChange(of: vm.allPosts.count) { oldValue, newValue in
                        postCount = newValue - oldValue
                    }
                    .padding(.horizontal, 30)
                    .padding(30)
                    .disabled(isImported)
                
            }
        }
        .listRowBackground(Color.clear)
    }

    private var textSection: some View {
        Text("""
            The curated collection of links to SwiftUI tutorials and articles has been compiled from open sources by the developer for the purpose of learning the SwiftUI functionality.
                       
            The collection **will be appended** to all current posts in the App, excluding duplicates based on the post title.
            """)
        .multilineTextAlignment(.leading)

    }
    
    // MARK: Functions
    
    private func checkForUpdates() {
        vm.checkCloudForUpdates { hasUpdates in
            if hasUpdates {
                followingText = "Updates available!"
                followingTextColor = Color.mycolor.myRed
                isPostsUpdateAvailable = true
                isInProgress = false
                print("Updates available")
                
            } else {
                followingText = "No update available"
                followingTextColor = Color.mycolor.myGreen
                isPostsUpdateAvailable = false
                isPostsUpdated = true
                isInProgress = false
                print("No updates available")
            }
        }
    }

}

#Preview {
    NavigationStack{
        CheckForPostsUpdateView()
            .environmentObject(PostsViewModel())
    }
}
