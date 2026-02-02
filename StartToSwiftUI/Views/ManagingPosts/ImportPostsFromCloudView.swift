//
//  CloudImportView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.10.2025.
//

import SwiftUI
import SwiftData

struct ImportPostsFromCloudView: View {
    
    // MARK: - Dependencies
    
    @EnvironmentObject private var vm: PostsViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    
    private let hapticManager = HapticService.shared
    
    // MARK: - State
    
    @State private var isInProgress = false
    @State private var isLoaded = false
    @State private var importedCount = 0
    @State private var initialPostCount = 0
    
    // MARK: - Body
    
    var body: some View {
        FormCoordinatorToolbar(
            title: "Import materials from cloud",
            showHomeButton: true
        ) {
            ZStack(alignment: .bottom) {
                VStack {
                    descriptionText
                        .textFormater()
                    
                    buttonsSection
                        .padding(.horizontal, 50)
                    Spacer()
                    
                }
                if isInProgress {
                    CustomProgressView(isNoText: true)
                }
            }
            .padding(.horizontal, 30)
            .padding(.top, 30)
            .alert("Download Error", isPresented: $vm.showErrorMessageAlert) {
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
        VStack {
            Group {
                Text("""
                    The collection of SwiftUI tutorials and articles compiled by the developer using open sources to make it easy for complete beginners to get started.

                    """)
                
                Text("**IMPORTANT NOTICE:**")
                    .foregroundStyle(Color.mycolor.myRed)
                
                Text("""
                Clicking **Confirm and Download** constitutes your agreement to the following terms:
                
                """)
                
                Text("""
                1. The materials will be used solely for non-commercial educational purposes.
                2. All intellectual property rights in the materials are retained by the original authors.
                3. You will make every effort to access and reference the original source materials.
                """
                )
                .font(.subheadline)
                .multilineTextAlignment(.leading)
            }
        }
    }
    
    private var buttonsSection: some View {
        Group {
            CapsuleButtonView(
                primaryTitle: "Confirm and Download",
                secondaryTitle: "\(importedCount) New Materials Added",
                isToChange: isLoaded
            ) {
                performImport()
            }
            .disabled(isLoaded || isInProgress)
            .padding(.top, 30)
            
            CapsuleButtonView(
                primaryTitle: "Don't confirm",
                textColorPrimary: Color.mycolor.myButtonTextRed,
                buttonColorPrimary: Color.mycolor.myButtonBGRed
            ) {
                coordinator.popToRoot()
            }
            .opacity(isLoaded ? 0 : 1)
            .disabled(isInProgress)
        }
    }
    
    // MARK: - Actions
    
    private func performImport() {
        isInProgress = true
        initialPostCount = vm.allPosts.count
        
        Task {
            await importFromCloud()
        }
    }
    
    private func importFromCloud() async {
 
        await loadFromCloudService()
        
    }

    /// Downloading from a cloud service
    private func loadFromCloudService() async {
        await vm.importPostsFromCloud() {
            isInProgress = false
            
            if !vm.showErrorMessageAlert {
                isLoaded = true
                
                // Updating the counter of downloaded posts
                importedCount = vm.allPosts.count - initialPostCount
                hapticManager.notification(type: .success)
                
                // Closing in 1.5 seconds
                Task {
                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                    await MainActor.run {
                        coordinator.closeModal()
                    }
                }
            } else {
                hapticManager.notification(type: .error)
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
        ImportPostsFromCloudView()
            .modelContainer(container)
            .environmentObject(vm)
            .environmentObject(AppCoordinator())
    }
}
