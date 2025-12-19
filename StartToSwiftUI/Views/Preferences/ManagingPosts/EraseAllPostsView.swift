//
//  EraseAllPostsView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 09.09.2025.
//

import SwiftUI
import SwiftData

struct EraseAllPostsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: PostsViewModel
    
    private let hapticManager = HapticService.shared
    
    @State private var isDeleted: Bool = false
    @State private var isShowingShareBackupSheet: Bool = false
    @State private var isInProgress = false
    
    @State private var postCount: Int = 0
    
    var body: some View {
        VStack {
            textSection
                .textFormater()
            
            CapsuleButtonView(
                primaryTitle: "ERASE",
                secondaryTitle: "\(postCount) Materials Deleted!",
                textColorPrimary: Color.mycolor.myButtonTextRed,
                buttonColorPrimary: Color.mycolor.myButtonBGRed,
                buttonColorSecondary: Color.mycolor.myButtonBGGreen,
                isToChange: isDeleted) {
                    isInProgress = true
                    vm.eraseAllPosts{
                        isDeleted = true
                        isInProgress = false
                        vm.isFirstImportPostsCompleted = false
                        DispatchQueue.main.asyncAfter(deadline: vm.dispatchTime) {
                            dismiss()
                        }
                    }
                }
                .padding(.top, 30)
                .padding(.horizontal, 50)
                .onChange(of: vm.allPosts.count, { oldValue, _ in
                    postCount = oldValue
                })
                .disabled(isDeleted)
            
            Spacer()
            
            if isInProgress {
                CustomProgressView()
            }
        }
        .padding(.horizontal, 30)
        .padding(.top, 30)
        .onAppear {
            hapticManager.notification(type: .warning)
        }
        .navigationTitle("Delete all materials")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButtonView() { dismiss() }
            }
        }
    }
    
    // MARK: Subviews

    private var textSection: some View {
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
    
}

#Preview {
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    
    let vm = PostsViewModel(modelContext: context)

    NavigationStack{
        EraseAllPostsView()
            .environmentObject(vm)
    }
}
