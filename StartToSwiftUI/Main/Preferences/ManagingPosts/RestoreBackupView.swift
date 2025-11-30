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
                .textFormater()
            
            CapsuleButtonView(
                primaryTitle: "Restore",
                secondaryTitle: "\(postCount) posts restored!",
                isToChange: isBackedUp
            ) {
                showDocumentPicker = true
            }
            .disabled(isBackedUp)
            .padding(.top, 30)
            .padding(.horizontal, 50)

            Spacer()
            
            if isInProgress {
                CustomProgressView()
            }
        }
        .padding(.horizontal, 30)
        .padding(.top, 30)
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
        .navigationTitle("Restore backup")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
//        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButtonView() { dismiss() }
            }
        }

    }
    
    // MARK: Subviews

    private var textSection: some View {
        Text("""
              You are about to restore materials from backup on the device.
              
              The materials from the backup will be added to all current materials in the App.
            """)
//        .multilineTextAlignment(.leading)

    }
}


#Preview {
    NavigationStack{
        RestoreBackupView()
            .environmentObject(PostsViewModel())
    }
}
