//
//  ContentViewWrapper.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 17.12.2025.
//

import SwiftUI
import SwiftData

struct ContentViewWrapper: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var coordinator: NavigationCoordinator
    
    var body: some View {
        ContentViewWithViewModels(modelContext: modelContext)
            .environmentObject(coordinator)
    }
}

struct ContentViewWithViewModels: View {
    
    @Environment(\.modelContext) private var modelContext
    @StateObject private var vm: PostsViewModel
    @StateObject private var noticevm: NoticeViewModel
    @EnvironmentObject private var coordinator: NavigationCoordinator

    
    @State private var showLaunchView: Bool = true
    @State private var isLoadingData = true // Показывает ProgressView во время загрузки данных
    
    init(modelContext: ModelContext) {
            _vm = StateObject(wrappedValue: PostsViewModel(modelContext: modelContext))
            _noticevm = StateObject(wrappedValue: NoticeViewModel(modelContext: modelContext))
        }

    var body: some View {
        ZStack {
            if showLaunchView {
                LaunchView() {
                    showLaunchView = false
                }
                .transition(.move(edge: .leading))
            } else if isLoadingData {
                // Пока идет загрузка в .task
                ProgressView("...loading data...")
                    .controlSize(.large)
            } else {
                // Загрузка завершена - показываем основной контент
                mainContent
            }
            
        }
        .preferredColorScheme(vm.selectedTheme.colorScheme)
        .task {
            // Очистка дубликатов AppState из прошлых запусков (Xcode)
            let appStateManager = AppSyncStateManager(modelContext: modelContext)
            appStateManager.cleanupDuplicateAppStates()
            
            // Загружаем посты
            vm.loadPostsFromSwiftData()
            
            // Если нужно, загружаем статические посты при первом запуске
            await vm.loadStaticPostsIfNeeded()
            
            // Импортируем уведомления (включает задержку и удаление дубликатов)
            await noticevm.importNoticesFromCloud()
            
            isLoadingData = false
        }
    }
    
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
}


#Preview("Simple Test") {
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppSyncState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    NavigationStack {
        ContentViewWrapper()
            .environment(\.modelContext, container.mainContext)
            .modelContainer(container)
            .environmentObject(NavigationCoordinator())
    }
}
