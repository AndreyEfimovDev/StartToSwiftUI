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
    
    private let hapticManager = HapticManager.shared
    private let selectedURL = Constants.cloudPostsURL
    
    @State private var followingText: String = "Checking for posts updates"
    @State private var buttonFirstText: String = "Check for updates"
    @State private var followingTextColor: Color = Color.mycolor.myAccent
    @State private var isInProgress: Bool = true
    @State private var isPostsUpdateAvailavle: Bool = false
    @State private var isPostsUpdated: Bool = false
    @State private var isImported: Bool = false
    @State private var postCount: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section {
                        HStack {
                            Text(followingText)
                                .foregroundStyle(followingTextColor)
                                .border(.red)
                            
                            Spacer()
                            if isInProgress {
                                ProgressView()
                                //                                .padding()
                                    .background(.regularMaterial)
                                //                                .cornerRadius(10)
                            }
                        }
                        HStack {
                            Text("Last update from:")
                            Spacer()
                            Text(vm.localLastUpdated.formatted(date: .numeric, time: .omitted))
                        }
                    }
                    .foregroundStyle(Color.mycolor.myAccent)
                    
                    textSection
                        .managingPostsTextFormater()
                        .padding(.horizontal, 30)
                        .padding(30)
                        .listRowBackground(Color.clear)
                } // Form
                .background(Color.blue)
//                .border(.yellow)
                
                if isImported {
                    CapsuleButtonView(
                        primaryTitle: buttonFirstText,
                        secondaryTitle: "Imported \(postCount) posts",
                        isToChangeTitile: isImported) {
                            
                            isInProgress = true
                            
                            vm.importPostsFromCloud(urlString: selectedURL) {
                                
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
                Spacer()

            } // VStack
            .onAppear {
                checkForUpdates()
            }
            .alert("Import Error", isPresented: $vm.showCloudImportAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(vm.cloudImportError ?? "Unknown error")
            }
        }
    }
        
    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .foregroundStyle(Color.mycolor.myAccent)
            .textCase(.uppercase)
    }

    private var textSection: some View {
        Text("""
            The pre-loaded posts are a collection of tutorials and articles from open sources that explain the SwiftUI functionality.
                       
            The new version of the pre-loaded posts appends all current posts in the App, excluding duplicates by post title.
            """)
    }
    
    
    // MARK: Functions

    private func checkForUpdates() {
        vm.checkCloudForUpdates { hasUpdates in
            if hasUpdates {
                followingText = "Updates available"
                followingTextColor = Color.mycolor.myRed
                buttonFirstText = "Update"
                isPostsUpdateAvailavle = true
                isInProgress = false
                print("Updates available")
                
            } else {
                followingText = "You are up to date"
                followingTextColor = Color.mycolor.myGreen
                isPostsUpdateAvailavle = false
                isPostsUpdated = true
                isInProgress = false
                print("No updates available")
            }
        }
    }


}

#Preview {
    CheckForPostsUpdateView()
        .environmentObject(PostsViewModel())
}
