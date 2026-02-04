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
        Text("""
            The collection of SwiftUI tutorials and articles to make it easy for complete beginners to get started.
            """
        )
        .font(.subheadline)
    }
    
    private var buttonsSection: some View {
        Group {
            CapsuleButtonView(
                primaryTitle: "Download",
                secondaryTitle: "\(importedCount) New Materials Added",
                isToChange: isLoaded
            ) {
                performImport()
            }
            .disabled(isLoaded || isInProgress)
            .padding(.top, 30)
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
#warning("Clean this func from loadDevData() before deployment to App Store")

        // Download local DevData (for internal use)
        // Uncomment this part when you need to load DevData
//        await loadDevData()
       
        // Download from the cloud (main stream)
        // Comment out this part when using DevData
        await loadFromCloudService()
        
    }

#warning("Delete this func from loadDevData() before deployment to App Store")

    /// Loading DevData (for internal use, to generate JSON file for cloud)
     private func loadDevData() async {
         let addedCount = await vm.loadDevData()
         
         await MainActor.run {
             importedCount = addedCount
             isInProgress = false
             isLoaded = true
             hapticManager.notification(type: .success)
         }
         
         try? await Task.sleep(nanoseconds: 1_500_000_000)
         
         await MainActor.run {
             coordinator.closeModal()
         }
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
