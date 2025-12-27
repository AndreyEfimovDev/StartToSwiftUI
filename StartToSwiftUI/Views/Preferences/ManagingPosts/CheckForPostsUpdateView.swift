//
//  CheckForPostsUpdateView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 27.10.2025.
//

import SwiftUI
import SwiftData

struct CheckForPostsUpdateView: View {
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var vm: PostsViewModel
    @EnvironmentObject private var coordinator: Coordinator
    
    private let hapticManager = HapticService.shared
    
    @State private var followingText: String = "Checking for update..."
    @State private var followingTextColor: Color = Color.mycolor.myAccent
    
    @State private var isInProgress: Bool = true
    @State private var isPostsUpdateAvailable: Bool = false
    @State private var isPostsUpdated: Bool = false
    @State private var isImported: Bool = false
    @State private var postCount: Int = 0
    
    var body: some View {
        ViewWrapperWithCustomNavToolbar(
            title: "Check for posts update",
            showHomeButton: true
        ) {
            VStack {
                Form {
                    section_1
                    section_2
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
    
    private var section_1: some View {
        Section {
            let appStateManager = AppSyncStateManager(modelContext: modelContext)
            if let lastDateUpdated = appStateManager.getLastDateOfCuaratedPostsLoaded() {
                HStack {
                    Text(followingText)
                        .foregroundStyle(followingTextColor)
                    Spacer()
                    if isInProgress {
                        CustomProgressView(scale: 1, isNoText: true)
                    }
                }
                HStack {
                    Text("Last update from:")
                    Spacer()
                    Text(lastDateUpdated.formatted(date: .numeric, time: .omitted))
                }
            }
        }
        .foregroundStyle(Color.mycolor.myAccent)
    }
    
    private var section_2: some View {
        Group {
            textSection
                .textFormater()
                .padding(.horizontal, 30)
            
            if !isPostsUpdated && !isInProgress {
                CapsuleButtonView(
                    primaryTitle: "Update now",
                    secondaryTitle: "Imported \(postCount) posts",
                    isToChange: isImported) {
                        Task {
                            isInProgress = true
                            await vm.importPostsFromCloud() {
                                isInProgress = false
                                isImported = true
                                hapticManager.notification(type: .success)
                                DispatchQueue.main.asyncAfter(deadline: vm.dispatchTime) {
                                    coordinator.closeModal()
                                }
                            }
                        }
                    }
                    .onChange(of: vm.allPosts.count) { oldValue, newValue in
                        postCount = newValue - oldValue
                    }
                    .padding(.horizontal, 30)
                    .padding(30)
                    .disabled(isImported)
            }
        }
        .listRowBackground(Color.clear)
    }

    private var textSection: some View {
        Text("""
            The curated collection of links to SwiftUI tutorials and articles has been compiled from open sources by the developer for the purpose of learning the SwiftUI functionality.
                       
            The collection **will be appended** to all current posts in the App, excluding duplicates based on the post title.
            """)
        .multilineTextAlignment(.center)

    }
    
    // MARK: Functions
    
    private func checkForUpdates() {
        Task {
            let hasUpdates = await vm.checkCloudCuratedPostsForUpdates()
            switch hasUpdates {
            case true:
                followingText = "Updates available!"
                followingTextColor = Color.mycolor.myRed
                isPostsUpdateAvailable = true
                isInProgress = false

            case false:
                followingText = "No update available"
                followingTextColor = Color.mycolor.myGreen
                isPostsUpdateAvailable = false
                isPostsUpdated = true
                isInProgress = false
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
            .environmentObject(Coordinator())
    }
}
