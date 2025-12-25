//
//  ContentViewWrapper.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 17.12.2025.
//

import SwiftUI
import SwiftData

struct StartView: View {
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var coordinator: NavigationCoordinator
    
    @StateObject private var vm: PostsViewModel
    @StateObject private var noticevm: NoticeViewModel
    
    @State private var showLaunchView: Bool = true
    @State private var isLoadingData = true
    
    // MARK: - Init
    init(modelContext: ModelContext) {
        _vm = StateObject(wrappedValue: PostsViewModel(modelContext: modelContext))
        _noticevm = StateObject(wrappedValue: NoticeViewModel(modelContext: modelContext))
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            if showLaunchView {
                LaunchView() {
                    showLaunchView = false
                }
                .transition(.move(edge: .leading))
            } else if isLoadingData {
                ProgressView("...loading data...")
                    .controlSize(.large)
            } else {
                mainContent
            }
        }
        .preferredColorScheme(vm.selectedTheme.colorScheme)
        .task {
            await loadInitialData()
        }
    }
    
    // MARK: - Subviews
    @ViewBuilder
    private var mainContent: some View {
        if UIDevice.isiPad {
            // iPad - NavigationSplitView
            SidebarView()
                .environmentObject(vm)
                .environmentObject(noticevm)
                .environmentObject(coordinator)
        } else {
            // iPhone - NavigationStack (portrait only)
            HomeView(selectedCategory: vm.selectedCategory)
                .environmentObject(vm)
                .environmentObject(noticevm)
                .environmentObject(coordinator)
        }
    }
    
    // MARK: - Data Loading
    private func loadInitialData() async {
        // Очистка дубликатов AppState из прошлых запусков (Xcode)
        let appStateManager = AppSyncStateManager(modelContext: modelContext)
        appStateManager.cleanupDuplicateAppStates()
        
        vm.loadPostsFromSwiftData()
        
        // Если нужно, загружаем статические посты при первом запуске
        await vm.loadStaticPostsIfNeeded()
        
        // Импортируем уведомления (включает удаление дубликатов)
        await noticevm.importNoticesFromCloud()
        
        isLoadingData = false
    }
}

#Preview("Simple Test") {
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppSyncState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let context = container.mainContext

    NavigationStack {
        StartView(modelContext: context)
            .modelContainer(container)
            .environmentObject(NavigationCoordinator())
    }
}
