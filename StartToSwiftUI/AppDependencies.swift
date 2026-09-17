//
//  AppDependencies.swift
//  StartToSwiftUI
//
import Foundation
import SwiftData

/// Полный манифест того, что собирает composition root
/// (`StartToSwiftUIApp.init()`) — один раз, за один вызов. ViewModel'и
/// хранятся здесь же (не как `@StateObject` во `View`), чтобы гарантия
/// "один инстанс на весь процесс" не зависела от того, сколько раз/сцен
/// SwiftUI пересоздаст `StartView` — а строилась ровно один раз, здесь.
///
/// `services` вынесен в отдельный `AppServiceDependencies`, а не расплющен
/// сюда же плоским списком — по той же причине, что `MainViewDependencies`
/// у `AppDependencies` не расплющен: это связанная группа, используемая
/// сразу тремя ViewModel'ями (Posts/Notices/Snippets), а не всем подряд.
struct AppDependencies {
    let appStateManager: AppSyncStateManager
    let services: AppServiceDependencies
    let postsViewModel: PostsViewModel
    let noticesViewModel: NoticesViewModel
    let snippetsViewModel: SnippetsViewModel
    let coordinator: AppCoordinator

    static func make(modelContext: ModelContext) -> AppDependencies {
        let stateManager = AppSyncStateManager(modelContext: modelContext)
        let services = AppServiceDependencies.make()

        // Initialisation of AppState — once at startup.
        // Ensure AppState exists (creates with appFirstLaunchDate if first launch).
        // Search for AppSyncState in SwiftData - it guarantees the existence of the AppState:
        // - The first launch will not find it, it will create a new one with appFirstLaunchDate = Date() and save it to the database.
        // - Restart — it will find an existing one and return it.
        _ = stateManager.getOrCreateAppState()

        return AppDependencies(
            appStateManager: stateManager,
            services: services,
            postsViewModel: PostsViewModel(
                modelContext: modelContext,
                appStateManager: stateManager,
                fbPostsManager: FBPostsManager(),
                services: services
            ),
            noticesViewModel: NoticesViewModel(
                modelContext: modelContext,
                appStateManager: stateManager,
                fbNoticesManager: FBNoticesManager(),
                services: services
            ),
            snippetsViewModel: SnippetsViewModel(
                appStateManager: stateManager,
                services: services
            ),
            coordinator: AppCoordinator()
        )
    }
}

/// Группа бывших синглтонов (ErrorManager, JSONFileManager, FBCrashManager,
/// FBPerformanceManager, FBAnalyticsManager) — раньше каждый был `static let
/// shared`, теперь строятся один раз в StartToSwiftUIApp.init() и
/// передаются вниз через init. Сгруппированы в один тип, чтобы ViewModel'и
/// принимали один параметр вместо пяти, и чтобы решение "какой дефолт
/// использовать, если явно не передали" принималось в одном месте, а не в
/// пяти разных сигнатурах.
///
/// `HapticManager` сюда не входит — решили оставить его синглтоном.
/// `AppSyncStateManager` сюда не входит — он никогда не был синглтоном и
/// по своей природе другой (держит ModelContext, а не stateless-утилита).
struct AppServiceDependencies {
    let errorManager: ErrorManager
    let fileManager: JSONFileManager
    let crashManager: FBCrashManager
    let performanceManager: FBPerformanceManager
    let analyticsManager: FBAnalyticsManager

    static func make() -> AppServiceDependencies {
        AppServiceDependencies(
            errorManager: ErrorManager(),
            fileManager: JSONFileManager(),
            crashManager: FBCrashManager(),
            performanceManager: FBPerformanceManager(),
            analyticsManager: FBAnalyticsManager()
        )
    }
}
