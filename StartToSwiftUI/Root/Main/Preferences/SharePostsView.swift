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

    private let fileManager = FileStorageService.shared
    private let hapticManager = HapticService.shared
    
    let fileName = Constants.localFileName

    @State private var showActivityView = false
    @State private var isShareCompleted = false
    @State private var isInProgress = false
        
    var body: some View {
        VStack {
            textSection
                .managingPostsTextFormater()
            
            CapsuleButtonView(
                primaryTitle: "Share/Store posts",
                secondaryTitle: "Posts Shared/Stored",
                isToChange: isShareCompleted
            ) {
                isInProgress = true
                showActivityView = true
            }
            .disabled(isShareCompleted)
            .padding(.top, 30)
                        
            Spacer()
            
            if isInProgress {
                ProgressView("Sharing posts...")
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal, 30)
        .padding(.top, 30)
        .padding(30)
        .sheet(isPresented: $showActivityView) {
            if let fileURL = fileManager.getFileURL(fileName: fileName) {
                handleDocumentSharing(fileURL: fileURL)
            }
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
            You are about to store posts
            in JSON format
            on your local device or
            share them directly via
            AirDop / Mail / Messenger / etc.
            
            """)
        .multilineTextAlignment(.leading)

    }
}

#Preview {
    SharePostsView()
        .environmentObject(PostsViewModel())
}

