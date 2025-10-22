///
//  BackupView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 09.09.2025.
//

import SwiftUI

struct RestoreBackupView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: PostsViewModel
    
    private let fileManager = FileStorageManager.shared
    private let hapticManager = HapticManager.shared
    
    @State var isBackedUp: Bool = false // disabel a "Restore Backup" burtton when done
    @State var isPerformingBackup: Bool = false // to launch .fileImporter
    @State private var postCount: Int = 0 // show how many posts restored
    @State private var showErrorAlert = false // handle error messages
    @State private var errorMessage = ""
    @State private var isInProgress = false // showing a progress of restoring
    
    var body: some View {
        
        VStack {
            textSection
            .managingPostsTextFormater()

            CapsuleButtonView(
                primaryTitle: "Restore Backup",
                secondaryTitle: "\(postCount) Posts Restored",
                isToChangeTitile: isBackedUp
            ) {
                isPerformingBackup.toggle()
            }
            .disabled(isBackedUp || isInProgress)
            .padding(.top, 30)
            .fileImporter(
                isPresented: $isPerformingBackup,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result)
            }
            
            Spacer()
        }
        .padding(.horizontal, 30)
        .padding(.top, 30)
        .padding(30)
        .overlay {
            if isInProgress {
                ProgressView("Restoring posts...")
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(10)
            }
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var textSection: some View {
        VStack(spacing: 12) {
            Text("""
            You are about to restore posts from backup on your local device.
            
            """)
            .multilineTextAlignment(.center)
            
            Text("""
            The posts from backup will replace
            all current posts in App.
            """)
            .foregroundStyle(.red)
            .bold()
        }
    }
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                importPosts(from: url)
            }
        case .failure(let error):
            showError("Restore: File selection error: \(error.localizedDescription)")
        }
    }
    
    private func importPosts(from url: URL) {
        
        isInProgress = true
        
        // Tracking url for debug
        print("Restore: Selected file URL: \(url)")
        print("Restore: File path: \(url.path)")
        
        // Gaining access to security-scoped resource: users' folders
        guard url.startAccessingSecurityScopedResource() else {
            showError("❌ Restore: No access to selected file")
            isInProgress = false
            return
        }
        // Revoking access to security-scoped resource when finished
        defer {
            url.stopAccessingSecurityScopedResource()
            isInProgress = false
        }
        
        do {
            // Read data from the selected file
            let data = try Data(contentsOf: url)
            
            guard !data.isEmpty else {
                showError("❌ Restore: The selected file is empty")
                return
            }
            
            // Checking JSON structure
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            guard jsonObject is [Any] else {
                showError("❌ Restore: Invalid JSON format: expected array of posts")
                return
            }
            
            // Decoding posts
            let posts = try JSONDecoder().decode([Post].self, from: data)
            
            // Updating posts in VM
            //            DispatchQueue.main.async {
            
            // avoding posts with dublicated titles
//            let newPosts = posts.filter { newPost in
//                !vm.allPosts.contains(where: { $0.title == newPost.title })
//            }
            vm.allPosts = posts
            fileManager.savePosts(posts)
            postCount = posts.count
            
            isBackedUp = true
            print("✅ Restore: Imported \(postCount) posts from \(url.lastPathComponent)")
            
            hapticManager.notification(type: .success)
            //            }
            
        } catch let decodingError as DecodingError {
            handleDecodingError(decodingError)
        } catch {
            showError("❌ Restore: Failed to import: \(error.localizedDescription)")
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
}
