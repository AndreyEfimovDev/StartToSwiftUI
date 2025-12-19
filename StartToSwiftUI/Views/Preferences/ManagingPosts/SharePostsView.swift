//
//  SharePostsView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 23.10.2025.
//

import SwiftUI
import SwiftData

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
            Button("OK", role: .cancel) {
                vm.errorMessage = nil
                isInProgress = false
            }
        } message: {
            Text(vm.errorMessage ?? "Unknown error")
        }
        .navigationTitle("Share/Store")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButtonView() { dismiss() }
            }
        }
    }
    
    private func prepareDocumentSharing() {
        
        print("🍓 Preparing document sharing from SwiftData...")
        
        // 1. Экспортируем данные из SwiftData
        let exportResult = vm.exportPostsToJSON()

        switch exportResult {
        case .success(let url):
            isInProgress = false
            shareURL = url
            showActivityView = true
            print("🍓✅ Document ready for sharing: \(url.lastPathComponent)")
        case .failure(let error):
            isInProgress = false
            vm.errorMessage = error.localizedDescription
            hapticManager.notification(type: .error)
            vm.showErrorMessageAlert = true
            print("🍓❌ Export failed: \(error.localizedDescription)")
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
                
                // Очищаем временный файл после успешного шаринга
                cleanupTempFile(fileURL)
                
                print("✅ Successfully shared via: \(result.activityName)")
                
                // Автоматическое закрытие через 2 секунды
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    dismiss()
                }

            } else {
                // Sharing is cancelled
                hapticManager.impact(style: .light)
                // Очищаем временный файл после успешного шаринга
                cleanupTempFile(fileURL)
                print("✅ Shared is cancelled.")
            }
            // Сбрасываем состояние
            isInProgress = false
            shareURL = nil

        }
    }
    
    /// Очистка временного файла после использования
    private func cleanupTempFile(_ url: URL) {
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
                print("🧹 Cleaned up temp file: \(url.lastPathComponent)")
            }
        } catch {
            print("⚠️ Failed to cleanup temp file: \(error)")
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
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    
    let vm = PostsViewModel(modelContext: context)
    
    NavigationStack{
        SharePostsView()
            .environmentObject(vm)
    }
}

