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
    
    private let hapticManager = HapticManager.shared
    
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
            .task {
                try? await Task.sleep(for: .seconds(vm.dispatchFor))
                await checkForUpdates()
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
                    ProgressView()
                }
            }
            if let lastDate = vm.lastDatePostsLoaded {
                HStack {
                    Text("Last update from:")
                    Spacer()
                    Text(lastDate.formatted(date: .numeric, time: .omitted))
                }
            }
            
        }
        .foregroundStyle(Color.mycolor.myAccent)
    }
        
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
               The collection **will be appended** to all current materilas in the app, excluding duplicates based on titles.
               """)
        .multilineTextAlignment(.center)
    }
    
    private var updateButton: some View {
        CapsuleButtonView(
            primaryTitle: "Update now",
            secondaryTitle: "Imported \(importedCount) posts",
            isToChange: isImported
        ) {
            isInProgress = true
            Task {
                await performImport()
                statusText = "No updates available"
            }
        }
        .onChange(of: vm.allPosts.count) { oldValue, newValue in
            importedCount = newValue - oldValue
        }
        .disabled(isImported)
    }
    
    // MARK: - Actions
    
    /// Check if updates for curated study materials are available
    private func checkForUpdates() async {
        let hasUpdates = await vm.checkFBPostsForUpdates()
        isInProgress = false
        
        if hasUpdates {
            statusText = "Updates available!"
            statusColor = Color.mycolor.myRed
            isUpdateAvailable = true
        } else {
            statusText = "No updates available"
            statusColor = Color.mycolor.myGreen
            isUpdated = true
            Task {
                try? await Task.sleep(for: .seconds(vm.dispatchFor))
                await MainActor.run {
                    coordinator.closeModal()
                }
            }
        }
    }
    
    /// Perform import new curated content from Firestore
    private func performImport() async {
        let success = await vm.importPostsFromFirebase()

        isInProgress = false
        
        if success {
            isImported = true
            hapticManager.notification(type: .success)
            Task {
                try? await Task.sleep(for: .seconds(vm.dispatchFor))
                await MainActor.run {
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
