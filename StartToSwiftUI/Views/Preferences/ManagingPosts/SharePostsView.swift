//
//  SharePostsView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 23.10.2025.
//

import SwiftUI
import SwiftData

struct SharePostsView: View {
    
    // MARK: - Dependencies
    
    @EnvironmentObject private var vm: PostsViewModel
    @EnvironmentObject private var coordinator: AppCoordinator

    private let hapticManager = HapticManager.shared
    
    // MARK: - State

    @State private var showActivityView = false
    @State private var isShareCompleted = false
    @State private var isInProgress = false
    @State private var shareURL: URL?
 
    // MARK: - Body

    var body: some View {
        FormCoordinatorToolbar(
            title: "Share/Backup",
            showHomeButton: true
        ) {
            VStack {
                descriptionText
                    .textFormater()
                
                CapsuleButtonView(
                    primaryTitle: "Share/Backup",
                    secondaryTitle: "Completed",
                    isToChange: isShareCompleted
                ) {
                    prepareAndShare()
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
                    sharingActivityView(for: url)
                }
            }
        }
    }
    
    // MARK: - Subviews

    private var descriptionText: some View {
        Text("""
            You are about to backup the study materials on your local device (JSON format) or,
            share them directly via
            AirDop / Mail / Messenger / etc.            
            """)
        .multilineTextAlignment(.center)
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
            hapticManager.notification(type: .error)
            ErrorManager.shared.handle(error, message: "Failed to export posts")
        }
    }
    
    @ViewBuilder
    private func sharingActivityView(for fileURL: URL) -> some View {
        ActivityView(activityItems: [fileURL], applicationActivities: nil) { result in
            handleSharingResult(result, fileURL: fileURL)
        }
    }
    
    // MARK: - Actions
    
    private func prepareAndShare() {
        isInProgress = true
        
        switch vm.exportPostsToJSON() {
        case .success(let url):
            shareURL = url
            showActivityView = true
            isInProgress = false
            
        case .failure(let error):
            isInProgress = false
            hapticManager.notification(type: .error)
            ErrorManager.shared.handle(error, message: "Failed to export posts")
        }
    }
    
    private func handleSharingResult(_ result: ActivityResult, fileURL: URL) {
        cleanupTempFile(fileURL)
        
        if result.completed {
            hapticManager.notification(type: .success)
            isShareCompleted = true
            showActivityView = false
            log("✅ Successfully shared via: \(result.activityName)", level: .info)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                coordinator.closeModal()
            }
        } else {
            hapticManager.impact(style: .light)
            log("✅ Share cancelled.", level: .info)
        }
        
        isInProgress = false
        shareURL = nil
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

