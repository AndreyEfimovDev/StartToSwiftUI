//
//  SharePostsView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 23.10.2025.
//

import SwiftUI
import SwiftData

struct SharePostsView: View {
    
    @EnvironmentObject private var vm: PostsViewModel
    @EnvironmentObject private var coordinator: AppCoordinator

    private let hapticManager = HapticService.shared
    
    @State private var showActivityView = false
    @State private var isShareCompleted = false
    @State private var isInProgress = false
    
    @State private var shareURL: URL?
        
    var body: some View {
        ViewWrapperWithCustomNavToolbar(
            title: "Share/Store",
            showHomeButton: true
        ) {
            VStack {
                textSection
                    .textFormater()
                
                CapsuleButtonView(
                    primaryTitle: "Share/Store",
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
                    CustomProgressView(isNoText: true)
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
                Button("OK", role: .cancel) {
                    vm.errorMessage = nil
                    isInProgress = false
                }
            } message: {
                Text(vm.errorMessage ?? "Unknown error")
            }
        }
    }
    
    private func prepareDocumentSharing() {
        // Export data from SwiftData
        let exportResult = vm.exportPostsToJSON()

        switch exportResult {
        case .success(let url):
            isInProgress = false
            shareURL = url
            showActivityView = true
        case .failure(let error):
            isInProgress = false
            vm.errorMessage = error.localizedDescription
            hapticManager.notification(type: .error)
            vm.showErrorMessageAlert = true
        }
    }
    
    // MARK: Subviews
    @ViewBuilder
    private func handleDocumentSharing(fileURL: URL) -> some View {
        ActivityView(activityItems: [fileURL], applicationActivities: nil) { result in
            if result.completed {
                // Successful sharing
                hapticManager.notification(type: .success)
                isShareCompleted = true // Change Share Button status and disable it
                showActivityView = false // Close sheet after sharing completion
                
                // Clearing the temporary file after sharing
                cleanupTempFile(fileURL)
                
                log("✅ Successfully shared via: \(result.activityName)", level: .info)
                
                // Automatic closing after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    coordinator.closeModal()
                }

            } else {
                // Sharing is cancelled
                hapticManager.impact(style: .light)
                // Clearing the temporary file
                cleanupTempFile(fileURL)
                log("✅ Shared is cancelled.", level: .info)
            }
            // Resetting the states
            isInProgress = false
            shareURL = nil

        }
    }
    
    /// Clearing temporary file after use
    private func cleanupTempFile(_ url: URL) {
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
                log("🧹 Cleaned up temp file: \(url.lastPathComponent)", level: .info)
            }
        } catch {
            log("⚠️ Failed to cleanup temp file: \(error)", level: .error)
        }
    }
    
    private var textSection: some View {
        Text("""
            You are about to store the materials
            on your local device (JSON format) 
            or
            share them directly via
            AirDop / Mail / Messenger / etc.            
            """)
        .multilineTextAlignment(.center)
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppSyncState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    
    let vm = PostsViewModel(modelContext: context)
    
    NavigationStack{
        SharePostsView()
            .environmentObject(vm)
            .environmentObject(AppCoordinator())
    }
}

