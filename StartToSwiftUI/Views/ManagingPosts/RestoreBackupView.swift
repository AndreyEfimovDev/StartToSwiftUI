//
//  DocumentPickerView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.10.2025.
//

import SwiftUI
import SwiftData

struct RestoreBackupView: View {
    
    // MARK: - Dependencies
    
    @EnvironmentObject private var vm: PostsViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    
    private let hapticManager = HapticService.shared
    
    // MARK: - State
    
    @State private var isRestored = false
    @State private var restoredCount = 0
    @State private var isInProgress = false
    @State private var showDocumentPicker = false
    
    // MARK: - Body
    
    var body: some View {
        FormCoordinatorToolbar(
            title: "Restore backup",
            showHomeButton: true
        ) {
            VStack {
                descriptionText
                    .textFormater()
                
                CapsuleButtonView(
                    primaryTitle: "Restore",
                    secondaryTitle: "\(restoredCount) posts restored!",
                    isToChange: isRestored
                ) {
                    showDocumentPicker = true
                }
                .disabled(isRestored)
                .padding(.top, 30)
                .padding(.horizontal, 50)
                
                Spacer()
                
                if isInProgress {
                    CustomProgressView(isNoText: true)
                }
            }
            .padding(.horizontal, 30)
            .padding(.top, 30)
            .sheet(isPresented: $showDocumentPicker) {
                documentPicker
            }
            .alert("Error", isPresented: $vm.showErrorMessageAlert) {
                Button("OK", role: .cancel) {
                    coordinator.pop()
                }
            } message: {
                Text(vm.errorMessage ?? "Unknown error")
            }
        }
    }
    
    // MARK: Subviews
    
    private var descriptionText: some View {
        Text("""
              You are about to restore study materials from backup on the device.
              
              The materials from the backup will be added to all current materials in the App.
            """)
    }
    
    private var documentPicker: some View {
        DocumentPicker(
            onDocumentPicked: { url in
                handleDocumentPicked(url: url)
            },
            onCancel: {
                isInProgress = false
            }
        )
    }
    
    // MARK: - Actions
    
    private func handleDocumentPicked(url: URL) {
        isInProgress = true
        
        vm.getPostsFromBackup(url: url) { count in
            restoredCount = count
            isRestored = true
            isInProgress = false
            
            if !vm.showErrorMessageAlert {
                DispatchQueue.main.asyncAfter(deadline: vm.dispatchTime) {
                    coordinator.closeModal()
                }
            }
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
        RestoreBackupView()
            .environmentObject(vm)
            .environmentObject(AppCoordinator())
    }
}
