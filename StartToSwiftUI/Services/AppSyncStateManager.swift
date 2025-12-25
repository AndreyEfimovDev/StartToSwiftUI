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
final class AppSyncState {
    var id: String = "app_state_singleton" // Всегда один экземпляр
    var isTermsOfUseAccepted: Bool = false
    
    // Флаг необходимости загрузки статических постов, устанавливается пользователем в Preferences: true - загружать
    var shouldLoadStaticPosts: Bool = true
    // Флаг факта загрузки статических постов: true - уже загружались
    var hasLoadedStaticPosts: Bool = false
    
    // Ставим флаг в true чтобы одноразово известить звуком пользователя о новых уведомлениях в случае их появления
    var isUserNotNotifiedBySound: Bool = true
    // Дата последней уведомления
    var latestNoticeDate: Date?

    // Флаг наличия новых авторских материалов:
    var isNewCuratedPostsAvailable: Bool = false // Для певрого запуска false, обновится в checkCloudCuratedPostsForUpdates()
    var latestDateOfCuaratedPostsLoaded: Date? // Обновляем в importPostsFromCloud() и используем в CheckForPostsUpdateView()
    
    // For internal purposes:
    // - cleanupDuplicateAppStates()
    // - getOrCreateAppState()
    // - mergeDuplicateAppStates()
    var lastCloudSyncDate: Date?
    var appFirstLaunchDate: Date?
    
    init(
        id: String = "app_state_singleton",
        isTermsOfUseAccepted: Bool = false,
        
        shouldLoadStaticPosts: Bool = true,
        hasLoadedStaticPosts: Bool = false,
        
        lastNoticeDate: Date? = nil,
        isUserNotNotifiedBySound: Bool = true,
        
        isNewCuratedPostsAvailable: Bool = true,
        latestDateOfCuaratedPostsLoaded: Date? = nil,

        lastCloudSyncDate: Date? = nil,
        appFirstLaunchDate: Date? = nil
        
    ) {
        self.id = id
        self.isTermsOfUseAccepted = isTermsOfUseAccepted
        
        self.shouldLoadStaticPosts = shouldLoadStaticPosts
        self.hasLoadedStaticPosts = hasLoadedStaticPosts
        
        self.isUserNotNotifiedBySound = isUserNotNotifiedBySound
        self.latestNoticeDate = lastNoticeDate

        self.isNewCuratedPostsAvailable = isNewCuratedPostsAvailable
        self.latestDateOfCuaratedPostsLoaded = latestDateOfCuaratedPostsLoaded
        
        self.lastCloudSyncDate = lastCloudSyncDate
        self.appFirstLaunchDate = appFirstLaunchDate
        
    }
}


@MainActor
class AppSyncStateManager {
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Maintenance Methods
    /// Принудительная очистка всех дубликатов AppState (для обслуживания)
    func cleanupDuplicateAppStates() {
        print("🧹 Запуск очистки дубликатов AppState...")
        let descriptor = FetchDescriptor<AppSyncState>(
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

    /// Получить или создать AppState с атомарной проверкой и дедупликацией
    func getOrCreateAppState() -> AppSyncState {
        // 1. Ищем все AppState с нашим singleton ID
        let descriptor = FetchDescriptor<AppSyncState>(
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
            let newState = AppSyncState(
                id: "app_state_singleton",
                appFirstLaunchDate: Date()
            )
            modelContext.insert(newState)
            try modelContext.save()
            
            return newState
            
        } catch {
            print("❌ Ошибка при получении AppState: \(error)")
            let newState = AppSyncState()
            modelContext.insert(newState)
            return newState
        }
    }
    
    /// Объединяет дубликаты AppState, сохраняя самые актуальные данные
    private func mergeDuplicateAppStates(_ states: [AppSyncState]) -> AppSyncState {
        print("🔄 Объединяем \(states.count) AppState...")
        
        // Сортируем по дате создания (самый старый = оригинальный)
        let sortedStates = states.sorted {
            ($0.appFirstLaunchDate ?? .distantPast) < ($1.appFirstLaunchDate ?? .distantPast)
        }
        
        guard let primaryState = sortedStates.first else {
            return AppSyncState()
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
//            print("✅ AppState объединён и сохранён")
        } catch {
            print("❌ Ошибка сохранения AppState: \(error)")
        }
        
        return primaryState
    }
    
    // MARK: - Method for isTermsOfUseAccepted
    
    func getTermsOfUseAcceptedStatus() -> Bool {
        let appState = getOrCreateAppState()
        return appState.isTermsOfUseAccepted
    }

    func setTermsOfUseAccepted(_ accepted: Bool) {
        let appState = getOrCreateAppState()
        appState.isTermsOfUseAccepted = accepted
        
        do {
            try modelContext.save()
//            print("✅ Флаг hasLoadedStaticPosts установлен в true")
        } catch {
            print("❌ Ошибка сохранения AppState: \(error)")
        }
    }
        
    // Принять условия использования
    func acceptTermsOfUse() {
        setTermsOfUseAccepted(true)
    }
    
    // Сбросить принятие условий (на случай если нужно сбросить)
    func resetTermsOfUseAccepted() {
        setTermsOfUseAccepted(false)
    }

        
    // MARK: - Methods for Static posts
    /// Проверить, загружались ли статические посты
    func getStaticPostsLoadToggleStatus() -> Bool {
        let appState = getOrCreateAppState()
        let result = appState.shouldLoadStaticPosts
//        print("🔍 shouldLoadStaticPosts: \(result)")
        return result
    }
    
    /// Включить загрузку статических постов, устанавливается пользователем в Preferences: true - загружать
    func setShouldLoadStaticPostsOn() {
        let appState = getOrCreateAppState()
        appState.shouldLoadStaticPosts = true
        
        do {
            try modelContext.save()
//            print("✅ Флаг hasLoadedStaticPosts установлен в true")
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
//            print("✅ Флаг hasLoadedStaticPosts установлен в true")
        } catch {
            print("❌ Ошибка сохранения AppState: \(error)")
        }
    }
    
    /// Проверить, загружены ли статические посты
    func checkIfStaticPostsHasLoaded() -> Bool {
        let appState = getOrCreateAppState()
        let result = appState.hasLoadedStaticPosts
//        print("🔍 hasLoadedStaticPosts: \(result)")
        return result
    }
    
    /// Отметить, что статические посты загружены
    func markStaticPostsAsLoaded() {
        let appState = getOrCreateAppState()
        appState.hasLoadedStaticPosts = true
        
        do {
            try modelContext.save()
//            print("✅ Флаг hasLoadedStaticPosts установлен в true")
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
//            print("✅ Флаг hasLoadedStaticPosts установлен в false (сброшен)")
        } catch {
            print("❌ Ошибка сохранения AppState: \(error)")
        }
    }

    // MARK: - Methods for Notices
    /// Проверить, нужно ли уведомить пользователя звуком
    func getUserNotifiedBySoundStatus() -> Bool {
        let appState = getOrCreateAppState()
        let result = appState.isUserNotNotifiedBySound
//        print("🔍 isUserNotNotifiedBySound: \(result)")
        return result
    }
    
    /// Включить флаг "нужно уведомить пользователя"
    func markUserNotNotifiedBySound() {
        let appState = getOrCreateAppState()
        appState.isUserNotNotifiedBySound = true
        
        do {
            try modelContext.save()
//            print("✅ Флаг isUserNotNotifiedBySound установлен в true (нужно уведомить)")
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
 /* */          print("✅ Флаг isUserNotNotifiedBySound установлен в false (уже уведомлён)")
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
//            print("✅ Дата последней синхронизации обновлена")
        } catch {
            print("❌ Ошибка сохранения AppState: \(error)")
        }
    }
    
    func getLastNoticeDate() -> Date? {
        let appState = getOrCreateAppState()
        return appState.latestNoticeDate
        
    }

    
    func updateLatestNoticeDate(_ date: Date) {
        let appState = getOrCreateAppState()
        appState.latestNoticeDate = date
        
        do {
            try modelContext.save()
//            print("✅ Дата последней синхронизации обновлена")
        } catch {
            print("❌ Ошибка сохранения AppState: \(error)")
        }
    }

    // MARK: - Methods for Cloud import of curated posts status
    /// Статус isNewCuratedPostsAvailable устанавливается в false, после:
    /// - после  импорта новых материалы авторских ссылок из облаке самим пользователем
    /// Статус isFirstImportCuratedPostsCompleted устанавливается в true:
    /// - иначальное значение для первой загрузки приложения
    /// - при проверке и обнаружении новых материалов авторских ссылок в облаке (включено в init()  PostsViewModel)
    /// - при удалении всех локальных материалов - функция "Erase all materials"

    /// Получить статус наличия новых материалы авторских ссылок в облаке
    func getAvailableNewCuratedPostsStatus() -> Bool {
        let appState = getOrCreateAppState()
        return appState.isNewCuratedPostsAvailable
    }
    
    /// Установить флаг наличия новых материалы авторских ссылок в облаке
    func setCuratedPostsLoadStatusOn() {
        let appState = getOrCreateAppState()
        appState.shouldLoadStaticPosts = true
        
        do {
            try modelContext.save()
//            print("✅ Флаг hasLoadedStaticPosts установлен в true")
        } catch {
            print("❌ Ошибка сохранения AppState: \(error)")
        }
    }
        
    /// Сбросить флаг  наличия новых материалы авторских ссылок в облаке
    func setCuratedPostsLoadStatusOff() {
        let appState = getOrCreateAppState()
        appState.shouldLoadStaticPosts = false
        
        do {
            try modelContext.save()
//            print("✅ Флаг hasLoadedStaticPosts установлен в true")
        } catch {
            print("❌ Ошибка сохранения AppState: \(error)")
        }
    }
    
    /// Обновить старшую дату загруженных материалы авторских ссылок из облака
    func setLastDateOfCuaratedPostsLoaded(_ date: Date) {
        let appState = getOrCreateAppState()
        appState.latestDateOfCuaratedPostsLoaded = date
    }

    /// Получить старшую дату загруженных материалы авторских ссылок из облака
    func getLastDateOfCuaratedPostsLoaded() -> Date? {
        let appState = getOrCreateAppState()
        return appState.latestDateOfCuaratedPostsLoaded
    }
    
}
