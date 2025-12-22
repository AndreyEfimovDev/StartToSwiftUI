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
    var shouldLoadStaticPosts: Bool = true // Флаг необходимости загрузки статических постов, устанавливается пользователем в Preferences: true - загружать
    var hasLoadedStaticPosts: Bool = false // Флаг факта загрузки статических постов: true - уже загружались
    var isUserNotNotifiedBySound: Bool = true // Используем только при запуске приложения для одноразового звукового оповещения, ставим флаг в true чтобы известить звуком пользователя о новом сообщении в случае их появления
    var appFirstLaunchDate: Date?
    var lastCloudSyncDate: Date?
    
    init(
        id: String = "app_state_singleton",
        shouldLoadStaticPosts: Bool = true,
        hasLoadedStaticPosts: Bool = false,
        isUserNotNotifiedBySound: Bool = true,
        appFirstLaunchDate: Date? = nil,
        lastCloudSyncDate: Date? = nil
    ) {
        self.id = id
        self.shouldLoadStaticPosts = shouldLoadStaticPosts
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
    
    /// Получить или создать AppState с атомарной проверкой и дедупликацией
    func getOrCreateAppState() -> AppState {
        // 1. Ищем все AppState с нашим singleton ID
        let descriptor = FetchDescriptor<AppState>(
            predicate: #Predicate { $0.id == "app_state_singleton" }
        )
        
        do {
            let results = try modelContext.fetch(descriptor)
            
            // 2. Если найдено несколько - объединяем в один
            if results.count > 1 {
                print("⚠️ Обнаружено \(results.count) AppState, объединяем дубликаты...")
                return mergeDuplicateAppStates(results)
            }
            
            // 3. Если найден один - возвращаем его
            if let existingState = results.first {
                // ✅ Тихо возвращаем, без лишних принтов
                return existingState
            }
            
            // 4. Создаём новый ТОЛЬКО если базы ПОЛНОСТЬЮ ПУСТАЯ
            // 🔥 ВАЖНО: Делаем финальную проверку перед созданием
            // (на случай, если другое устройство создало AppState в это время)
            let finalCheck = try modelContext.fetch(descriptor)
            if let existingState = finalCheck.first {
                print("✅ AppState создан другим устройством, используем его")
                return existingState
            }
            
            print("📦 Создаём новый AppState")
            let newState = AppState(
                id: "app_state_singleton",
                appFirstLaunchDate: Date()
            )
            modelContext.insert(newState)
            try modelContext.save()
            
            return newState
            
        } catch {
            print("❌ Ошибка при получении AppState: \(error)")
            let newState = AppState()
            modelContext.insert(newState)
            return newState
        }
    }
    
    /// Объединяет дубликаты AppState, сохраняя самые актуальные данные
    private func mergeDuplicateAppStates(_ states: [AppState]) -> AppState {
        print("🔄 Объединяем \(states.count) AppState...")
        
        // Сортируем по дате создания (самый старый = оригинальный)
        let sortedStates = states.sorted {
            ($0.appFirstLaunchDate ?? .distantPast) < ($1.appFirstLaunchDate ?? .distantPast)
        }
        
        guard let primaryState = sortedStates.first else {
            return AppState()
        }
        
        print("  📌 Основной AppState: \(primaryState.id)")
        
        // Объединяем флаги: если хотя бы один true - берём true
        var mergedHasLoadedStatic = false
        var mergedIsUserNotNotified = true
        var earliestDate: Date?
        var latestSyncDate: Date?
        
        for state in sortedStates {
            // Логика OR для hasLoadedStaticPosts
            if state.hasLoadedStaticPosts {
                mergedHasLoadedStatic = true
            }
            
            // Логика AND для isUserNotNotifiedBySound (если хотя бы один уже уведомлён - берём false)
            if !state.isUserNotNotifiedBySound {
                mergedIsUserNotNotified = false
            }
            
            // Самая ранняя дата запуска
            if let date = state.appFirstLaunchDate {
                if earliestDate == nil || date < earliestDate! {
                    earliestDate = date
                }
            }
            
            // Самая поздняя синхронизация
            if let date = state.lastCloudSyncDate {
                if latestSyncDate == nil || date > latestSyncDate! {
                    latestSyncDate = date
                }
            }
        }
        
        // Обновляем основной объект объединёнными данными
        primaryState.hasLoadedStaticPosts = mergedHasLoadedStatic
        primaryState.isUserNotNotifiedBySound = mergedIsUserNotNotified
        primaryState.appFirstLaunchDate = earliestDate
        primaryState.lastCloudSyncDate = latestSyncDate
        
        print("  ✅ Объединённые данные:")
        print("     hasLoadedStaticPosts: \(mergedHasLoadedStatic)")
        print("     isUserNotNotifiedBySound: \(mergedIsUserNotNotified)")
        
        // Удаляем дубликаты
        for duplicateState in sortedStates.dropFirst() {
            modelContext.delete(duplicateState)
            print("  ✗ Удалён дубликат AppState")
        }
        
        // Сохраняем изменения
        do {
            try modelContext.save()
            print("✅ AppState объединён и сохранён")
        } catch {
            print("❌ Ошибка сохранения AppState: \(error)")
        }
        
        return primaryState
    }
    
    // MARK: - Public Methods
    
    /// Проверить, загружались ли статические посты
    func getStaticPostsLoadToggleStatus() -> Bool {
        let appState = getOrCreateAppState()
        let result = appState.shouldLoadStaticPosts
        print("🔍 shouldLoadStaticPosts: \(result)")
        return result
    }
    
    /// Включить загрузку статических постов, устанавливается пользователем в Preferences: true - загружать
    func setShouldLoadStaticPostsOn() {
        let appState = getOrCreateAppState()
        appState.shouldLoadStaticPosts = true
        
        do {
            try modelContext.save()
            print("✅ Флаг hasLoadedStaticPosts установлен в true")
        } catch {
            print("❌ Ошибка сохранения AppState: \(error)")
        }
    }
    
    
    /// Включить загрузку статических постов, устанавливается пользователем в Preferences: true - загружать
    func setShouldLoadStaticPostsOff() {
        let appState = getOrCreateAppState()
        appState.shouldLoadStaticPosts = false
        
        do {
            try modelContext.save()
            print("✅ Флаг hasLoadedStaticPosts установлен в true")
        } catch {
            print("❌ Ошибка сохранения AppState: \(error)")
        }
    }



    
    /// Проверить, загружены ли статические посты
    func checkIfStaticPostsHasLoaded() -> Bool {
        let appState = getOrCreateAppState()
        let result = appState.hasLoadedStaticPosts
        print("🔍 hasLoadedStaticPosts: \(result)")
        return result
    }
    
    /// Отметить, что статические посты загружены
    func markStaticPostsAsLoaded() {
        let appState = getOrCreateAppState()
        appState.hasLoadedStaticPosts = true
        
        do {
            try modelContext.save()
            print("✅ Флаг hasLoadedStaticPosts установлен в true")
        } catch {
            print("❌ Ошибка сохранения AppState: \(error)")
        }
    }
    
    /// Отметить, что статические посты как не загруженные
    func markStaticPostsAsNotLoaded() {
        let appState = getOrCreateAppState()
        appState.hasLoadedStaticPosts = false
        
        do {
            try modelContext.save()
            print("✅ Флаг hasLoadedStaticPosts установлен в false (сброшен)")
        } catch {
            print("❌ Ошибка сохранения AppState: \(error)")
        }
    }

    
    /// Проверить, нужно ли уведомить пользователя звуком
    func getUserNotifiedBySoundStatus() -> Bool {
        let appState = getOrCreateAppState()
        let result = appState.isUserNotNotifiedBySound
        print("🔍 isUserNotNotifiedBySound: \(result)")
        return result
    }
    
    /// Включить флаг "нужно уведомить пользователя"
    func markUserNotNotifiedBySound() {
        let appState = getOrCreateAppState()
        appState.isUserNotNotifiedBySound = true
        
        do {
            try modelContext.save()
            print("✅ Флаг isUserNotNotifiedBySound установлен в true (нужно уведомить)")
        } catch {
            print("❌ Ошибка сохранения AppState: \(error)")
        }
    }
    
    /// Отметить, что пользователь уже уведомлён
    func markUserNotifiedBySound() {
        let appState = getOrCreateAppState()
        appState.isUserNotNotifiedBySound = false
        
        do {
            try modelContext.save()
            print("✅ Флаг isUserNotNotifiedBySound установлен в false (уже уведомлён)")
        } catch {
            print("❌ Ошибка сохранения AppState: \(error)")
        }
    }
    
    /// Обновить дату последней синхронизации
    func updateLastCloudSyncDate() {
        let appState = getOrCreateAppState()
        appState.lastCloudSyncDate = Date()
        
        do {
            try modelContext.save()
            print("✅ Дата последней синхронизации обновлена")
        } catch {
            print("❌ Ошибка сохранения AppState: \(error)")
        }
    }
    
    // MARK: - Maintenance
    
    /// Принудительная очистка всех дубликатов AppState (для обслуживания)
    func cleanupDuplicateAppStates() {
        print("🧹 Запуск очистки дубликатов AppState...")
        
        let descriptor = FetchDescriptor<AppState>(
            predicate: #Predicate { $0.id == "app_state_singleton" }
        )
        
        do {
            let results = try modelContext.fetch(descriptor)
            
            if results.count > 1 {
                print("⚠️ Найдено \(results.count) дубликатов, очищаем...")
                _ = mergeDuplicateAppStates(results)
                print("✅ Очистка завершена")
            } else {
                print("✅ Дубликатов не обнаружено (\(results.count) AppState)")
            }
        } catch {
            print("❌ Ошибка при очистке дубликатов: \(error)")
        }
    }
}
