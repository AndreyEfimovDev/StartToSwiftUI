//
//  CheckForPostsUpdateView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 27.10.2025.
//

import SwiftUI
import SwiftData

struct CheckForPostsUpdateView: View {
    
    // MARK: - Dependencies
    
    @EnvironmentObject private var vm: PostsViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    
    private let hapticManager = HapticService.shared
    
    // MARK: - State
    
    @State private var statusText = "Checking for update..."
    @State private var statusColor = Color.mycolor.myAccent
    @State private var isInProgress = true
    @State private var isUpdateAvailable = false
    @State private var isUpdated = false
    @State private var isImported = false
    @State private var importedCount = 0
    
    // MARK: - Body
    
    var body: some View {
        FormCoordinatorToolbar(
            title: "Check for posts update",
            showHomeButton: true
        ) {
            VStack {
                Form {
                    statusSection
                    actionSection
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: vm.dispatchTime + 1) {
                    checkForUpdates()
                }
            }
            .alert("Import Error", isPresented: $vm.showErrorMessageAlert) {
                Button("OK", role: .cancel) {
                    coordinator.pop()
                }
            } message: {
                Text(vm.errorMessage ?? "Unknown error")
            }
        }
    }
    
    // MARK: Subviews
    
    private var statusSection: some View {
        Section {
            HStack {
                Text(statusText)
                    .foregroundStyle(statusColor)
                Spacer()
                if isInProgress {
                    CustomProgressView(scale: 1, isNoText: true)
                }
            }
            if let lastDate = vm.lastCuratedPostsLoadedDate {
                HStack {
                    Text("Last update from:")
                    Spacer()
                    Text(lastDate.formatted(date: .numeric, time: .omitted))
                }
            }
            
        }
        .foregroundStyle(Color.mycolor.myAccent)
    }
    
//    private var actionSection: some View {
//        Group {
//            textSection
//                .textFormater()
//                .padding(.horizontal, 30)
//            
//            if !isPostsUpdated && !isInProgress {
//                CapsuleButtonView(
//                    primaryTitle: "Update now",
//                    secondaryTitle: "Imported \(postCount) posts",
//                    isToChange: isImported) {
//                        Task {
//                            isInProgress = true
//                            await vm.importPostsFromCloud() {
//                                isInProgress = false
//                                isImported = true
//                                hapticManager.notification(type: .success)
//                                DispatchQueue.main.asyncAfter(deadline: vm.dispatchTime) {
//                                    coordinator.closeModal()
//                                }
//                            }
//                        }
//                    }
//                    .onChange(of: vm.allPosts.count) { oldValue, newValue in
//                        postCount = newValue - oldValue
//                    }
//                    .padding(.horizontal, 30)
//                    .padding(30)
//                    .disabled(isImported)
//            }
//        }
//        .listRowBackground(Color.clear)
//    }

//    private var textSection: some View {
//        Text("""
//            The curated collection of links to SwiftUI tutorials and articles has been compiled from open sources by the developer for the purpose of learning the SwiftUI functionality.
//                       
//            The collection **will be appended** to all current posts in the App, excluding duplicates based on the post title.
//            """)
//        .multilineTextAlignment(.center)
//
//    }
    
    @ViewBuilder
    private var actionSection: some View {
        Group {
            descriptionText
                .textFormater()
                .padding(.horizontal, 30)
            
            if !isUpdated && !isInProgress {
                updateButton
                    .padding(.horizontal, 30)
                    .padding(30)
            }
        }
        .listRowBackground(Color.clear)
    }
    
    private var descriptionText: some View {
        Text("""
               The curated collection of links to SwiftUI tutorials and articles has been compiled from open sources by the developer for the purpose of learning the SwiftUI functionality.
                          
               The collection **will be appended** to all current posts in the App, excluding duplicates based on the post title.
               """)
        .multilineTextAlignment(.center)
    }
    
    private var updateButton: some View {
        CapsuleButtonView(
            primaryTitle: "Update now",
            secondaryTitle: "Imported \(importedCount) posts",
            isToChange: isImported
        ) {
            performImport()
        }
        .onChange(of: vm.allPosts.count) { oldValue, newValue in
            importedCount = newValue - oldValue
        }
        .disabled(isImported)
    }
    
    // MARK: - Actions
    
    /// Check if updates for curated links to study materials are available
    private func checkForUpdates() {
        Task {
            let hasUpdates = await vm.checkCloudCuratedPostsForUpdates()
            
            if hasUpdates {
                statusText = "Updates available!"
                statusColor = Color.mycolor.myRed
                isUpdateAvailable = true
                
            } else {
                statusColor = Color.mycolor.myGreen
                isUpdated = true
            }
            
            isInProgress = false
        }
    }
    
    private func performImport() {
        Task {
            isInProgress = true
            await vm.importPostsFromCloud {
                isInProgress = false
                isImported = true
                hapticManager.notification(type: .success)
                
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
        CheckForPostsUpdateView()
            .modelContainer(container)
            .environmentObject(vm)
            .environmentObject(AppCoordinator())
    }
}
