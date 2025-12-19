//
//  AppState.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 19.12.2025.
//

import Foundation
import SwiftData

// MARK: - AppState Model для синхронизации флагов через iCloud

@Model
final class AppState {
    var id: String = "app_state_singleton" // Всегда один экземпляр
    var hasLoadedStaticPosts: Bool = false
    var isUserNotNotifiedBySound: Bool = true // Используем только при запуске приложения для звукового оповещения- если есть новые уведомления, то ставим флаг в true
    var appFirstLaunchDate: Date?
    var lastCloudSyncDate: Date?
    
    init(
        id: String = "app_state_singleton",
        hasLoadedStaticPosts: Bool = false,
        isUserNotNotifiedBySound: Bool = true,
        appFirstLaunchDate: Date? = nil,
        lastCloudSyncDate: Date? = nil
    ) {
        self.id = id
        self.hasLoadedStaticPosts = hasLoadedStaticPosts
        self.isUserNotNotifiedBySound = isUserNotNotifiedBySound
        self.appFirstLaunchDate = appFirstLaunchDate
        self.lastCloudSyncDate = lastCloudSyncDate
    }
}


@MainActor
class AppStateManager {
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /// Получить или создать AppState
    func getOrCreateAppState() -> AppState {
        // Пытаемся найти существующий AppState
        let descriptor = FetchDescriptor<AppState>(
            predicate: #Predicate { $0.id == "app_state_singleton" }
        )
        
        do {
            let results = try modelContext.fetch(descriptor)
            
            if let existingState = results.first {
                print("✅ AppState найден в базе")
                return existingState
            }
            
            // Создаём новый, если не найден
            print("📦 Создаём новый AppState")
            let newState = AppState(
                appFirstLaunchDate: Date()
            )
            modelContext.insert(newState)
            try modelContext.save()
            
            return newState
            
        } catch {
            print("❌ Ошибка при получении AppState: \(error)")
            // Возвращаем новый в случае ошибки
            let newState = AppState()
            modelContext.insert(newState)
            return newState
        }
    }
    
    /// Проверить, загружены ли статические посты
    func hasLoadedStaticPosts() -> Bool {
        let appState = getOrCreateAppState()
        print("🔍 hasLoadedStaticPosts: \(appState.hasLoadedStaticPosts)")
        return appState.hasLoadedStaticPosts
    }
    
    /// Отметить, что статические посты загружены
    func markStaticPostsAsLoaded() {
        let appState = getOrCreateAppState()
        appState.hasLoadedStaticPosts = true
        
        do {
            try modelContext.save()
            print("✅ Статические посты отмечены как загруженные")
        } catch {
            print("❌ Ошибка сохранения AppState: \(error)")
        }
    }
    
    /// Проверить флаг оповещения пользователя о новых уведомлениях
    func getUserNotifiedBySoundStatus() -> Bool {
        let appState = getOrCreateAppState()
        return appState.isUserNotNotifiedBySound
    }
    
    /// Включаем флаг оповещения, чтобы уведомить пользователя о новых уведомлениях
    func markUserNotNotifiedBySound() {
        let appState = getOrCreateAppState()
        appState.isUserNotNotifiedBySound = true
        
        do {
            try modelContext.save()
            print("✅ Статические уведомления отмечены как загруженные")
        } catch {
            print("❌ Ошибка сохранения AppState: \(error)")
        }
    }
    
    /// Выключаем флаг оповещения пользователя о новых уведомлениях, уже уведомлен
    func markUserNotifiedBySound() {
        let appState = getOrCreateAppState()
        appState.isUserNotNotifiedBySound = false
        
        do {
            try modelContext.save()
            print("✅ Статические уведомления отмечены как загруженные")
        } catch {
            print("❌ Ошибка сохранения AppState: \(error)")
        }
    }

}

