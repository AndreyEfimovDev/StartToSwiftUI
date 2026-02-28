//
//  AppState.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 19.12.2025.
//

import Foundation
import SwiftData

@MainActor
class AppSyncStateManager {
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Maintenance Methods
    /// Force clearing all duplicate AppState (for maintenance)
    func cleanupDuplicateAppStates() {
        log("✅ 🧹 Starting duplicate cleaning AppState...", level: .debug)

        let descriptor = FetchDescriptor<AppSyncState>(
            predicate: #Predicate { $0.id == "app_state_singleton" }
        )
        
        do {
            let results = try modelContext.fetch(descriptor)
            
            if results.count > 1 {
                log("⚠️ Found \(results.count) duplicates, clearing...", level: .info)

                _ = mergeDuplicateAppStates(results)
                log("✅ Cleaning completed", level: .info)
            } else {
                log("✅ No duplicates found (\(results.count) AppState)", level: .info)
            }
        } catch {
            log("❌ Error clearing duplicates: \(error)", level: .error)
        }
    }

    /// Get or create AppState with atomic validation and deduplication
    func getOrCreateAppState() -> AppSyncState {
        // 1. Search for all AppStates with our singleton ID
        let descriptor = FetchDescriptor<AppSyncState>(
            predicate: #Predicate { $0.id == "app_state_singleton" }
        )
        
        do {
            let results = try modelContext.fetch(descriptor)
            
            // 2. If several are found, merge them into one
            if results.count > 1 {
                log("⚠️ Detected \(results.count) AppState, merging duplicates...", level: .info)
                return mergeDuplicateAppStates(results)
            }
            
            // 3. If one is found, return it
            if let existingState = results.first {
                
                // TODO: Remove after v?.? — migration for users with distantPast date in Firestore
                // Date.distantPast caused 'Timestamp seconds out of range' crash in Firestore
//                if let date = existingState.lastPostsFBUpdateDate, date < Date(timeIntervalSince1970: 0) {
//                    existingState.lastPostsFBUpdateDate = Date(timeIntervalSince1970: 0)
//                    saveContext()
//                    log("🔥 Migration: lastPostsFBUpdateDate fixed from distantPast", level: .info)
//                }

                return existingState
            }
            
            // 4. Create a new one ONLY if the database is COMPLETELY EMPTY
            // 🔥 Final check before creation
            // (in case another device created AppState at that time)
            let finalCheck = try modelContext.fetch(descriptor)
            if let existingState = finalCheck.first {
                log("✅ AppState was created by another device, use it", level: .info)
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
            log("❌ Error getting AppState: \(error)", level: .error)
            let newState = AppSyncState()
            modelContext.insert(newState)
            return newState
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
        
        // Merge the flags: if at least one is true, we take true
        var earliestDate: Date?
        var latestSyncDate: Date?
        
        for state in sortedStates {
            
            
            // Earliest launch date
            if let date = state.appFirstLaunchDate {
                if earliestDate == nil || date < earliestDate! {
                    earliestDate = date
                }
            }
            
            // Latest synchronization
            if let date = state.lastCloudSyncDateToMergeDuplicate {
                if latestSyncDate == nil || date > latestSyncDate! {
                    latestSyncDate = date
                }
            }
        }
        
        // Updating the main object with the merged data
        primaryState.appFirstLaunchDate = earliestDate
        primaryState.lastCloudSyncDateToMergeDuplicate = latestSyncDate
        
        log("  ✅ Combined data:", level: .info)
        
        // Remove duplicates
        for duplicateState in sortedStates.dropFirst() {
            modelContext.delete(duplicateState)
            log("  ✗ Duplicate AppState removed", level: .info)
        }
        
        // Remove duplicates
        saveContext()
        
        return primaryState
    }
    
    // MARK: - Methods for Notices
    
    func getLastNoticeDate() -> Date? {
        let appState = getOrCreateAppState()
        return appState.latestNoticeDate
        
    }
    
    func updateLatestNoticeDate(_ date: Date) {
        let appState = getOrCreateAppState()
        appState.latestNoticeDate = date
        saveContext()
    }

    // MARK: - Managing lastPostsFBUpdateDate
    
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
    
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            log("❌ Error saving AppState: \(error)", level: .error)
        }
    }
    
    func getAppFirstLaunchDate() -> Date? {
        let appState = getOrCreateAppState()
        return appState.appFirstLaunchDate
    }

}
