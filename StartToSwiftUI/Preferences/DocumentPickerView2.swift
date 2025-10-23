//
//  DocumentPickerView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.10.2025.
//

import SwiftUI

struct DocumentPickerView2: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: PostsViewModel

    private let fileManager = FileStorageService.shared
    private let hapticManager = HapticManager.shared
    
    @State private var isBackedUp: Bool = false
    @State private var postCount: Int = 0
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    // Для DocumentPicker
    @State private var showDocumentPicker = false
    @State private var importedURL: URL?
    
    var body: some View {
        VStack {
            Text("""
              You are about to restore posts from backup on the device.
              
              The posts from backup will replace
              all current posts in App.
              """)
            .managingPostsTextFormater()
            
            CapsuleButtonView(
                primaryTitle: "Restore Backup",
                secondaryTitle: "\(postCount) Posts Restored!",
                isToChangeTitile: isBackedUp
            ) {
                isLoading.toggle()
                showDocumentPicker = true
            }
            .disabled(isBackedUp)
            .padding(.top, 30)
            
            Spacer()
            
            if isLoading {
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
                    importPosts(from: url)
                },
                onCancel: {
                    isLoading = false
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
    
    private func importPosts(from url: URL) {
        isLoading = true

        // Tracking url for debug
        print("Restore: Selected file URL: \(url)")
        print("Restore: File path: \(url.path)")
        
        // Checking file for existence
        guard FileManager.default.fileExists(atPath: url.path) else {
            showError("File does not exist")
            isLoading = false
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
            
            // Decoding posts
            let posts = try JSONDecoder().decode([Post].self, from: data)
            
            DispatchQueue.main.async {
                vm.allPosts = posts
                fileManager.savePosts(posts)
                postCount = posts.count
                
                isBackedUp = true
                isLoading = false
                
                hapticManager.notification(type: .success)
                
                print("✅ Restored \(postCount) posts from \(url.lastPathComponent)")
            }
            
        } catch let decodingError as DecodingError {
            handleDecodingError(decodingError)
        } catch {
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
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}

#Preview {
    DocumentPickerView2()
        .environmentObject(PostsViewModel())

}
