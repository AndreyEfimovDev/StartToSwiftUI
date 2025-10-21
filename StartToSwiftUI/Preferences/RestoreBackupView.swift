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
    
    @State var isBackedUp: Bool = false
    @State var isPerformingBackup: Bool = false
    @State private var postCount: Int = 0
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        
        VStack {
            Text("""
            You are about to restored posts from backup on the device.
            
            The posts from backup will replace
            all current posts in App.
            
            """)
            .managingPostsTextFormater()

            CapsuleButtonView(
                primaryTitle: "Restore Backup",
                secondaryTitle: "\(postCount) Posts Restored!",
                isToChangeTitile: isBackedUp
            ) {
                isPerformingBackup.toggle()
            }
            .disabled(isBackedUp || isLoading)
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
        
        isLoading = true
        
        // Tracking url for debug
        print("🔍 Restore: Selected file URL: \(url)")
        print("🔍 Restore: File path: \(url.path)")
        
        // Gaining access to security-scoped resource
        guard url.startAccessingSecurityScopedResource() else {
            showError("Restore: No access to selected file")
            isLoading = false
            return
        }
        
        defer {
            url.stopAccessingSecurityScopedResource()
            isLoading = false
        }
        
        do {
            // Read data from the selected file
            let data = try Data(contentsOf: url)
            
            guard !data.isEmpty else {
                showError("Restore: The selected file is empty")
                return
            }
            
            // Checking JSON structure
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            guard jsonObject is [Any] else {
                showError("Restore: Invalid JSON format: expected array of posts")
                return
            }
            
            // Decoding posts
            let posts = try JSONDecoder().decode([Post].self, from: data)
            
            // Updating posts in VM
            DispatchQueue.main.async {
                vm.allPosts = posts
                fileManager.savePosts(posts)
                postCount = posts.count
                isBackedUp = true
                
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
            
        } catch let decodingError as DecodingError {
            handleDecodingError(decodingError)
        } catch {
            showError("Restore: Failed to import: \(error.localizedDescription)")
        }
    }

    private func handleDecodingError(_ error: DecodingError) {
            switch error {
            case .dataCorrupted(let context):
                showError("Restore: Invalid JSON format: \(context.debugDescription)")
            case .keyNotFound(let key, let context):
                showError("Restore: Missing field '\(key.stringValue)' in JSON in context: \(context.debugDescription)")
            case .typeMismatch(let type, let context):
                showError("Restore: Type mismatch for '\(type)' in JSON in context: \(context.debugDescription)")
            case .valueNotFound(let type, let context):
                showError("Restore: Missing value for type '\(type)' in JSON in context: \(context.debugDescription)")
            @unknown default:
                showError("Restore: Unknown JSON decoding error")
            }
        }
        
    private func showError(_ message: String) {
        errorMessage = message
        showErrorAlert = true
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }    
}



#Preview {
    RestoreBackupView()
}
