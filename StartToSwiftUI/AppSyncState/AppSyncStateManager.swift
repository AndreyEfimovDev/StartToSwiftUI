//
//  AppState.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 19.12.2025.
//

import Foundation
import SwiftData

@MainActor
class AppSyncStateManager: AppSyncStateManagerProtocol {
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Maintenance Methods
    /// Force clearing all duplicate AppState (for maintenance)
    func cleanupDuplicateAppStates() {
        log("🧹 Starting duplicate cleaning AppState...", level: .debug)

        do {
            // Забираем все AppSyncState и фильтруем по id уже в Swift, а не
            // через #Predicate — фетч с предикатом падает с EXC_BAD_INSTRUCTION
            // внутри самого SwiftData на этой связке SDK/Simulator, независимо
            // от того, сравниваем со строковым литералом или с переменной
            // (проверено эмпирически). Строк здесь всегда единицы, лишней
            // нагрузки от фетча без предиката нет.
            let allStates = try modelContext.fetch(FetchDescriptor<AppSyncState>())
            let results = allStates.filter { $0.id == "app_state_singleton" }

            if results.count > 1 {
                log("Found \(results.count) duplicates, clearing...", level: .info)

                _ = mergeDuplicateAppStates(results)
                log("Cleaning completed", level: .info)
            } else {
                log("No duplicates found (\(results.count) AppState)", level: .info)
            }
        } catch {
            log("Error clearing duplicates: \(error)", level: .error)
        }
    }

    /// Get or create AppState with atomic validation and deduplication
    func getOrCreateAppState() -> AppSyncState {
        do {
            // 1. Search for all AppStates with our singleton ID — без #Predicate,
            // см. комментарий в cleanupDuplicateAppStates().
            let results = try modelContext.fetch(FetchDescriptor<AppSyncState>())
                .filter { $0.id == "app_state_singleton" }

            // 2. If several are found, merge them into one
            if results.count > 1 {
                log("Detected \(results.count) AppState, merging duplicates...", level: .warning)
                return mergeDuplicateAppStates(results)
            }
            
            // 3. If one is found, return it
            if let existingState = results.first {
                
                // TODO: Remove after v?.? — migration for users with distantPast date in Firestore
                // Date.distantPast caused 'Timestamp seconds out of range' crash in Firestore
                if let date = existingState.lastPostsFBUpdateDate, date < Date(timeIntervalSince1970: 0) {
                    existingState.lastPostsFBUpdateDate = Date(timeIntervalSince1970: 0)
                    saveContext()
                    log("🔥 Migration: lastPostsFBUpdateDate fixed from distantPast", level: .info)
                }

                return existingState
            }
            
            // 4. Create a new one ONLY if the database is COMPLETELY EMPTY
            // 🔥 Final check before creation
            // (in case another device created AppState at that time)
            let finalCheck = try modelContext.fetch(FetchDescriptor<AppSyncState>())
                .filter { $0.id == "app_state_singleton" }
            if let existingState = finalCheck.first {
                log("AppState was created by another device, use it", level: .info)
                return existingState
            }
            
            log("📦 Create a new AppState", level: .info)
            let newState = AppSyncState(
                id: "app_state_singleton",
                appFirstLaunchDate: Date()
            )
            modelContext.insert(newState)
            
            saveContext()

            return newState
            
        } catch {
            log("Error getting AppState: \(error)", level: .error)
            // Временный объект БЕЗ вставки в контекст: геттеры получат nil,
            // изменения в нём просто не сохранятся. Вставка создала бы пустой
            // дубль состояния, который записало бы следующее любое сохранение.
            // При следующем вызове чтение из базы повторится.
            return AppSyncState()
        }
    }
    
    /// Merge AppState duplicates while preserving the most up-to-date data
    private func mergeDuplicateAppStates(_ states: [AppSyncState]) -> AppSyncState {
        log("🔄 Merge \(states.count) AppState...", level: .info)
        
        // Sort by creation date (oldest = original)
        let sortedStates = states.sorted {
            ($0.appFirstLaunchDate ?? .distantPast) < ($1.appFirstLaunchDate ?? .distantPast)
        }
        
        guard let primaryState = sortedStates.first else {
            return AppSyncState()
        }
        log("  📌 Main AppState: \(primaryState.id)", level: .info)
        
        
        // Merge the flags: if at least one is true, to take true
        /// Earliest launch date
        let earliestDate = sortedStates
            .compactMap { $0.appFirstLaunchDate }
            .min()
        
        /// Latest synchronization/
        let latestSyncDate = sortedStates
            .compactMap { $0.lastCloudSyncDateToMergeDuplicate }
            .max()

        // Updating the main object with the merged data
        primaryState.appFirstLaunchDate = earliestDate
        primaryState.lastCloudSyncDateToMergeDuplicate = latestSyncDate
        
        let latestPostsDate = sortedStates
            .compactMap { $0.lastPostsFBUpdateDate }
            .max()
        primaryState.lastPostsFBUpdateDate = latestPostsDate

        let latestNoticeDate = sortedStates
            .compactMap { $0.lastNoticesFBUpdateDate }
            .max()
        primaryState.lastNoticesFBUpdateDate = latestNoticeDate


        // Merge snippet favorites — union of all duplicates
        let mergedFavorites = sortedStates
            .flatMap { $0.snippetFavoriteIDs }
        let uniqueFavorites = Array(Set(mergedFavorites)) // remove duplicates
        primaryState.snippetFavoriteIDs = uniqueFavorites // collect all id from unique favorites
        
        log("  Combined data:", level: .info)
        
        // Remove duplicates
        for duplicateState in sortedStates.dropFirst() {
            modelContext.delete(duplicateState)
            log("  ✗ Duplicate AppState removed", level: .info)
        }
        
        // Remove duplicates
        saveContext()
        
        return primaryState
    }
    
    
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            log("Error saving AppState: \(error)", level: .error)
        }
    }
}

// MARK: - Methods for Posts
extension AppSyncStateManager {
    
    /// Update the latest date of downloaded materials from the cloud
    func setLastDateOfPostsLoaded(_ date: Date) {
        let appState = getOrCreateAppState()
        appState.lastPostsFBUpdateDate = date
        saveContext()
    }

    func resetLastDateOfPostsLoaded() {
        let appState = getOrCreateAppState()
        appState.lastPostsFBUpdateDate = Date(timeIntervalSince1970: 0)
        saveContext()
    }

    /// Get the latest date of downloaded materials from the cloud
    func getLastDateOfPostsLoaded() -> Date? {
        let appState = getOrCreateAppState()
        return appState.lastPostsFBUpdateDate
    }

}


// MARK: - Methods for Notices
extension AppSyncStateManager {
    
    func getLastNoticeDate() -> Date? {
        let appState = getOrCreateAppState()
        return appState.lastNoticesFBUpdateDate
    }
    
    func updateLatestNoticeDate(_ date: Date) {
        let appState = getOrCreateAppState()
        appState.lastNoticesFBUpdateDate = date
        saveContext()
    }
    
    // for tests purpose
    func resetLatestNoticeDate() {
        let appState = getOrCreateAppState()
        appState.lastNoticesFBUpdateDate = nil
        saveContext()
    }

    /// Возвращает дату первого запуска приложения, общую для всех устройств пользователя.
    ///
    /// Дата хранится в `AppSyncState`, который синхронизируется через CloudKit
    /// вместе с notices. Если второе устройство до прихода синка создало своё
    /// состояние с датой «сейчас», слияние дублей оставит самую раннюю дату.
    ///
    /// - Returns: Дата первого запуска или `nil`, если состояние не удалось прочитать из базы.
    func getAppFirstLaunchDate() -> Date? {
        let appState = getOrCreateAppState()
        return appState.appFirstLaunchDate
    }
}


// MARK: - Methods for Snippet Favorites
extension AppSyncStateManager: SnippetFavoritesStoreProtocol {
    
    func getSnippetFavoriteIDs() -> Set<String> {
        let appState = getOrCreateAppState()
        return Set(appState.snippetFavoriteIDs)
    }
    
    func toggleSnippetFavorite(_ id: String) {
        let appState = getOrCreateAppState()
        if appState.snippetFavoriteIDs.contains(id) {
            appState.snippetFavoriteIDs.removeAll { $0 == id }
        } else {
            appState.snippetFavoriteIDs.append(id)
        }
        saveContext()
    }
}
