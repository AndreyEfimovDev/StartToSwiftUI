//
//  DocumentPickerView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.10.2025.
//

import SwiftUI

struct RestoreBackupView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: PostsViewModel

    private let fileManager = FileStorageService.shared
    private let hapticManager = HapticService.shared
    
    @State private var isBackedUp: Bool = false
    @State private var postCount: Int = 0
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var isInProgress = false
    
    @State private var showDocumentPicker = false
    @State private var importedURL: URL?
    
    var body: some View {
        VStack {
            textSection
                .managingPostsTextFormater()
            
            CapsuleButtonView(
                primaryTitle: "Restore Backup",
                secondaryTitle: "\(postCount) Posts Restored!",
                isToChange: isBackedUp
            ) {
                showDocumentPicker = true
            }
            .disabled(isBackedUp)
            .padding(.top, 30)
            
            Spacer()
            
            if isInProgress {
                ProgressView("Restoring posts...")
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal, 30)
        .padding(.top, 30)
        .padding(30)
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker(
                onDocumentPicked: { url in
                    isInProgress = true
                    restorePostsFromBackup(from: url)
                    DispatchQueue.main.asyncAfter(deadline: vm.dispatchTime) {
                        dismiss()
                    }
                },
                onCancel: {
                    isInProgress = false
                    print("Document picker cancelled")
                }
            )
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: Subviews

    private var textSection: some View {
        Text("""
              You are about to restore posts from backup on the device.
              
              The posts from backup will replace all current posts in App.
            """)
        .multilineTextAlignment(.leading)

    }
    
    private func restorePostsFromBackup(from url: URL) {
                
        // Checking file for existence
        
        if !fileManager.checkIfFileExists(at: url) {
            isInProgress = false
            showError("File does not exist")
            return
        }
        
        
        do {
            // Read data from the selected file
            let data = try Data(contentsOf: url)
            
            guard !data.isEmpty else {
                showError("The selected file is empty")
                return
            }
            
            // Checking JSON structure
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            guard jsonObject is [Any] else {
                showError("Invalid JSON format: expected array of posts")
                return
            }
            let decodedPosts = try JSONDecoder.appDecoder.decode([Post].self, from: data)
            
            // Checking posts with the same Title to local posts - do not append such posts from BackUp
            let existingTitlesInLocalPosts = Set(vm.allPosts.map { $0.title })
            let postsAfterCheckForUniqueTitle = decodedPosts.filter { !existingTitlesInLocalPosts.contains($0.title) }
            
//            let postsAfterCheckForUniqueTitle = posts.filter { post in
//                !vm.allPosts.contains(where: { $0.title == post.title })
//            }
//            
            // Checking posts with the same ID to local posts - do not append such posts from BackUp
            let existingIdInLocalPosts = Set(vm.allPosts.map { $0.id })
            let postsAfterCheckForUniqueID = postsAfterCheckForUniqueTitle.filter { !existingIdInLocalPosts.contains($0.id) }

//            let postsAfterCheckForUniqueID = postsAfterCheckForUniqueTitle.filter { post in
//                !vm.allPosts.contains(where: { $0.id == post.id })
//            }

            DispatchQueue.main.async {
                isInProgress = false
                isBackedUp = true
                postCount = postsAfterCheckForUniqueID.count
                
                vm.allPosts.append(contentsOf: postsAfterCheckForUniqueID)
                print("✅ Restore: Restored \(postsAfterCheckForUniqueID.count) posts from \(url.lastPathComponent)")

                hapticManager.notification(type: .success)
            }
            
        } catch let decodingError as DecodingError {
            isInProgress = false
            handleDecodingError(decodingError)
        } catch {
            isInProgress = false
            showError("Failed to import: \(error.localizedDescription)")
        }
    }
    
    private func handleDecodingError(_ error: DecodingError) {
        switch error {
        case .dataCorrupted(let context):
            showError("Invalid JSON format: \(context.debugDescription)")
        case .keyNotFound(let key, let context):
            showError("Missing field '\(key.stringValue)' in JSON: \(context.debugDescription)")
        case .typeMismatch(let type, let context):
            showError("Type mismatch for '\(type)' in JSON: \(context.debugDescription)")
        case .valueNotFound(let type, let context):
            showError("Missing value for type '\(type)' in JSON: \(context.debugDescription)")
        @unknown default:
            showError("Unknown JSON decoding error")
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showErrorAlert = true
        hapticManager.notification(type: .error)
    }
}


#Preview {
    RestoreBackupView()
        .environmentObject(PostsViewModel())

}
