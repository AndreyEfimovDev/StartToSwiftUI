//
//  EraseAllPostsView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 09.09.2025.
//

import SwiftUI
import SwiftData

struct EraseAllPostsView: View {
    
    // MARK: - Dependencies
    
    @EnvironmentObject private var vm: PostsViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    
    private let hapticManager = HapticService.shared
    
    // MARK: - State
    
    @State private var isDeleted = false
    @State private var isInProgress = false
    @State private var erasedCount = 0
    
    // MARK: - Body
    
    var body: some View {
        FormCoordinatorToolbar(
            title: "Erase all materials",
            showHomeButton: true
        ) {
            VStack {
                descriptionText
                    .textFormater()
                eraseButton
                    .padding(.top, 30)
                    .padding(.horizontal, 50)
                

//                CapsuleButtonView(
//                    primaryTitle: "ERASE",
//                    secondaryTitle: "\(postCount) Materials Erased!",
//                    textColorPrimary: Color.mycolor.myButtonTextRed,
//                    buttonColorPrimary: Color.mycolor.myButtonBGRed,
//                    buttonColorSecondary: Color.mycolor.myButtonBGGreen,
//                    isToChange: isDeleted) {
//                        isInProgress = true
//                        vm.eraseAllPosts{
//                            isDeleted = true
//                            isInProgress = false
//                            // Reset the status of the first import of curated links to materials
//                            // To allow directly import curated links to materials again
//                            let appStateManager = AppSyncStateManager(modelContext: modelContext)
//                            appStateManager.setCuratedPostsLoadStatusOn()
//                            
//                            DispatchQueue.main.asyncAfter(deadline: vm.dispatchTime) {
//                                coordinator.closeModal()
//                            }
//                        }
//                    }
//                    .padding(.top, 30)
//                    .padding(.horizontal, 50)
//                    .onChange(of: vm.allPosts.count, { oldValue, _ in
//                        postCount = oldValue
//                    })
//                    .disabled(isDeleted)
                
                Spacer()
                
                if isInProgress {
                    CustomProgressView(isNoText: true)
                }
            }
            .padding(.horizontal, 30)
            .padding(.top, 30)
            .onAppear {
                hapticManager.notification(type: .warning)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var eraseButton: some View {
        CapsuleButtonView(
            primaryTitle: "ERASE",
            secondaryTitle: "\(erasedCount) Materials Erased!",
            textColorPrimary: Color.mycolor.myButtonTextRed,
            buttonColorPrimary: Color.mycolor.myButtonBGRed,
            buttonColorSecondary: Color.mycolor.myButtonBGGreen,
            isToChange: isDeleted
        ) {
            performErase()
        }
        .onChange(of: vm.allPosts.count) { oldValue, _ in
            erasedCount = oldValue
        }
        .disabled(isDeleted)
    }

    private var descriptionText: some View {
        VStack(spacing: 0) {
            Text("""
            **You are about
            to delete all the materials.**
            
            What you can do after:
            
            """
            )
            .font(.subheadline)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)

            Text("""
            - download the curated collection, 
            - create own materials, or
            - restore backup.
            
            """
            )
            .font(.subheadline)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.leading)
            
            Text("""
            It is recommended
            to backup мaterials before
            deleting them.
            """)
            .foregroundStyle(Color.mycolor.myRed)
            .bold()
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
        }
        .font(.subheadline)
    }
    
    // MARK: - Actions
    
    private func performErase() {
        isInProgress = true
        
        vm.eraseAllPosts {
            isDeleted = true
            isInProgress = false
            
            // Reset curated posts status to allow re-import
            vm.resetCuratedPostsStatus()
            
            DispatchQueue.main.asyncAfter(deadline: vm.dispatchTime) {
                coordinator.closeModal()
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
        EraseAllPostsView()
            .modelContainer(container)
            .environmentObject(vm)
            .environmentObject(AppCoordinator())
    }
}
