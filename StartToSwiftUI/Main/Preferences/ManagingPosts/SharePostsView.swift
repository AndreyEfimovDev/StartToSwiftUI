//
//  SharePostsView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 23.10.2025.
//

import SwiftUI

struct SharePostsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: PostsViewModel

    private let hapticManager = HapticService.shared
    
    @State private var showActivityView = false
    @State private var isShareCompleted = false
    @State private var isInProgress = false
    
    @State private var shareURL: URL?
        
    var body: some View {
        VStack {
            textSection
                .textFormater()
            
            CapsuleButtonView(
                primaryTitle: "Perform",
                secondaryTitle: "Completed",
                isToChange: isShareCompleted
            ) {
                isInProgress = true
                prepareDocumentSharing()
                showActivityView = true
            }
            .disabled(isShareCompleted)
            .padding(.top, 30)
            .padding(.horizontal, 50)

            Spacer()
            
            if isInProgress {
                CustomProgressView()
            }
        }
        .padding(.horizontal, 30)
        .padding(.top, 30)
        .sheet(isPresented: $showActivityView) {
            if let url = shareURL {
                handleDocumentSharing(fileURL: url)
            }
        }
        .alert("Sharing Error", isPresented: $vm.showErrorMessageAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(vm.errorMessage ?? "Unknown error")
        }
        .navigationTitle("Share/Store")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
//        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                CircleStrokeButtonView(iconName: "chevron.left", isShownCircle: false) {
                    dismiss()
                }
            }
        }
    }
    
    private func prepareDocumentSharing() {
        
        let pathResult = vm.getFilePath(fileName: Constants.localPostsFileName)
        switch pathResult {
        case .success(let path):
            shareURL = path
            showActivityView = true
        case .failure(let error):
            vm.errorMessage = error.localizedDescription
            vm.showErrorMessageAlert = true
        }
    }

    
    // MARK: Subviews

    @ViewBuilder
    private func handleDocumentSharing(fileURL: URL) -> some View {
        ActivityView(activityItems: [fileURL], applicationActivities: nil) { result in
            if result.completed {
                // Successful sharing
                isInProgress = false 
                hapticManager.notification(type: .success)
                isShareCompleted = true // Change Share Button status and disable it
                showActivityView = false // Close sheet after sharing completion
                print("✅ Successfully shared via: \(result.activityName)")
                DispatchQueue.main.asyncAfter(deadline: vm.dispatchTime) {
                    dismiss()
                }
            } else {
                // Sharing is cancelled
                isInProgress = false
                hapticManager.impact(style: .light)
                print("✅ Shared is cancelled.")
            }
        }
    }
    
    private var textSection: some View {
        Text("""
            You are about to store the materials on your local device in JSON format 
            or
            share them directly via AirDop / Mail / Messenger / etc.
            
            While storing on local device please use a name different from 'app_posts' for your convenience, i.e. 'app_posts_backup'.
            
            """)
        .multilineTextAlignment(.center)
    }
}

#Preview {
    NavigationStack{
        SharePostsView()
            .environmentObject(PostsViewModel())
    }
}

