//
//  DocumentPickerView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.10.2025.
//

import SwiftUI
import SwiftData

struct RestoreBackupView: View {
    
    @EnvironmentObject private var vm: PostsViewModel
    @EnvironmentObject private var coordinator: NavigationCoordinator

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
                                coordinator.popToRoot()
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
                coordinator.pop()
            }
        } message: {
            Text(vm.errorMessage ?? "Unknown error")
        }
        .navigationTitle("Restore backup")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButtonView() {
                    coordinator.pop()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    coordinator.popToRoot()
                } label: {
                    Image(systemName: "house")
                        .foregroundStyle(Color.mycolor.myAccent)
                }
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
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppSyncState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    
    let vm = PostsViewModel(modelContext: context)
    
    NavigationStack{
        RestoreBackupView()
            .environmentObject(vm)
            .environmentObject(NavigationCoordinator())
    }
}
