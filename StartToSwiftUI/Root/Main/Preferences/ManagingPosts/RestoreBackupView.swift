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

    private let hapticManager = HapticService.shared
    
    @State private var isBackedUp: Bool = false
    @State private var postCount: Int = 0
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
                CustomProgressView()
            }
        }
        .padding(.horizontal, 30)
        .padding(30)
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker(
                onDocumentPicked: { url in
                    isInProgress = true
                    vm.getPostsFromBackup(url: url) { count in
                        postCount = count
                        isBackedUp = true
                        isInProgress = false
                        if !vm.showErrorMessageAlert {
                            DispatchQueue.main.asyncAfter(deadline: vm.dispatchTime) {
                                dismiss()
                            }
                        }
                    }
                },
                onCancel: {
                    isInProgress = false
                    print("Document picker cancelled")
                }
            )
        }
        .alert("Error", isPresented: $vm.showErrorMessageAlert) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        } message: {
            Text(vm.errorMessage ?? "Unknown error")
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
}


#Preview {
    RestoreBackupView()
        .environmentObject(PostsViewModel())

}
