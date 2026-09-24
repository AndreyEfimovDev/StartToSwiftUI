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
    
    private let hapticManager = HapticManager.shared
    
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
            .autoDismiss(when: isDeleted) {
                coordinator.closeModal()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var eraseButton: some View {
        CapsuleButtonView(
            primaryTitle: "ERASE",
            secondaryTitle: "\(erasedCount) Content Erased!",
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
            You are about
            to erase all the study content.
            
            """
            )
            Text("""
            It is recommended
            to backup content before
            deleting it.
            """)
            .foregroundStyle(Color.mycolor.myButtonTextRed)
        }
    }
    
    // MARK: - Actions
    
    private func performErase() {
        isInProgress = true
        // Дату синка сбрасывает сам eraseAllPosts() — только после успешного удаления.
        let isErased = vm.eraseAllPosts()
        isInProgress = false

        if isErased {
            isDeleted = true
        } else {
            // Успех не показываем и экран не закрываем; текст ошибки — в
            // глобальном алерте ErrorManager.
            hapticManager.notification(type: .error)
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppSyncState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    
    let vm = PostsViewModel(modelContext: context, fbPostsManager: FBPostsManager(), services: .make())

    NavigationStack{
        EraseAllPostsView()
            .modelContainer(container)
            .environmentObject(vm)
            .environmentObject(AppCoordinator())
    }
}
