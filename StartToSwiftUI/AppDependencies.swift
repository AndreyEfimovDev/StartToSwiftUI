//
//  AppDependencies.swift
//  StartToSwiftUI
//
import Foundation
import SwiftData

/// Полный манифест того, что собирает composition root
/// (`StartToSwiftUIApp.init()`) — один раз, за один вызов.
///
/// `services` вынесен в отдельный `AppServiceDependencies`, а не расплющен
/// сюда же плоским списком — по той же причине, что `MainViewDependencies`
/// у `AppDependencies` не расплющен: это связанная группа, используемая
/// сразу тремя ViewModel'ями (Posts/Notices/Snippets), а не всем подряд.
struct AppDependencies {
    let appStateManager: AppSyncStateManager
    let services: AppServiceDependencies

    static func make(modelContext: ModelContext) -> AppDependencies {
        AppDependencies(
            appStateManager: AppSyncStateManager(modelContext: modelContext),
            services: .make()
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
