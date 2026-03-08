//
//  ImportSnippetsFromCloudView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.03.2026.
//
//  Place in Views/Snippets/ManagingSnippets/
//
//  NOTE: Unlike ImportPostsFromCloudView (modal), this view is pushed
//  on the main NavigationStack → uses coordinator.pop() not closeModal().

import SwiftUI

struct ImportSnippetsFromCloudView: View {

    // MARK: - Dependencies
    @EnvironmentObject private var vm: SnippetsViewModel
    @EnvironmentObject private var coordinator: AppCoordinator

    private let hapticManager = HapticManager.shared

    // MARK: - State
    @State private var isInProgress = false
    @State private var isLoaded = false
    @State private var importedCount = 0
    @State private var initialCount = 0

    // MARK: - Body
    var body: some View {
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
        .navigationTitle("Download Code Snippets")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar { toolbar }
        .onAppear {
            vm.loadSnippetsFromSwiftData()
        }
    }

    // MARK: - Subviews

    private var descriptionText: some View {
        Text("""
            A curated collection of practical SwiftUI code snippets with live visual previews.
            Each snippet shows you the code in action — not just text.
            """)
        .font(.subheadline)
    }

    private var buttonsSection: some View {
        CapsuleButtonView(
            primaryTitle: "Download",
            secondaryTitle: "\(importedCount) New Snippets Added",
            isToChange: isLoaded
        ) {
            performImport()
        }
        .disabled(isLoaded || isInProgress)
        .padding(.top, 30)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            BackButtonView { coordinator.pop() }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                coordinator.popToRoot()
            } label: {
                Image(systemName: "house")
                    .foregroundStyle(Color.mycolor.myAccent)
            }
        }
    }

    // MARK: - Actions

    private func performImport() {
        isInProgress = true
        initialCount = vm.allSnippets.count
        Task { await runImport() }
    }

    private func runImport() async {
        let success = await vm.importSnippetsFromFirebase()
        isInProgress = false

        if success {
            isLoaded = true
            importedCount = vm.allSnippets.count - initialCount
            hapticManager.notification(type: .success)

            Task {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                await MainActor.run { coordinator.pop() }
            }
        } else {
            hapticManager.notification(type: .error)
        }
    }
}

// MARK: - Preview

#Preview {
    let vm = SnippetsViewModel(
        dataSource: MockSnippetsDataSource(),
        fbSnippetsManager: MockFBSnippetsManager()
    )
    NavigationStack {
        ImportSnippetsFromCloudView()
            .environmentObject(vm)
            .environmentObject(AppCoordinator())
    }
}
