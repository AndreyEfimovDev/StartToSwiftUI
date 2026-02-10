//
//  AppState.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 19.12.2025.
//

import Foundation
import SwiftData

// MARK: - AppState Model for flag synchronisation via iCloud

@Model
final class AppSyncState {
    var id: String = "app_state_singleton" // Always one copy
    
    // Set the flag to true to notify the user with a sound once about new notices if they appear
    var isUserNotNotifiedBySound: Bool = true
    // Date of last notices
    var latestNoticeDate: Date?

    // Flag indicating the presence of new curated materials
    var isNewCuratedPostsAvailable: Bool = false // For the first launch, false, it will be updated in checkCloudCuratedPostsForUpdates()
    var latestDateOfCuaratedPostsLoaded: Date? // Updated in importPostsFromCloud() and use in CheckForPostsUpdateView()
    
    // For internal purposes:
    // - cleanupDuplicateAppStates()
    // - getOrCreateAppState()
    // - mergeDuplicateAppStates()
    
    var lastCloudSyncDate: Date?
    var appFirstLaunchDate: Date?
    
    init(
        id: String = "app_state_singleton",
        
        lastNoticeDate: Date? = nil,
        isUserNotNotifiedBySound: Bool = true,
        
        isNewCuratedPostsAvailable: Bool = true,
        latestDateOfCuaratedPostsLoaded: Date? = nil,

        lastCloudSyncDate: Date? = nil,
        appFirstLaunchDate: Date? = nil
        
    ) {
        self.id = id
        
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
        var mergedIsUserNotNotified = true
        var earliestDate: Date?
        var latestSyncDate: Date?
        
        for state in sortedStates {
            
            // AND logic for isUserNotNotifiedBySound (if at least one is already notified, take false)
            if !state.isUserNotNotifiedBySound {
                mergedIsUserNotNotified = false
            }
            
            // Earliest launch date
            if let date = state.appFirstLaunchDate {
                if earliestDate == nil || date < earliestDate! {
                    earliestDate = date
                }
            }
            
            // Latest synchronization
            if let date = state.lastCloudSyncDate {
                if latestSyncDate == nil || date > latestSyncDate! {
                    latestSyncDate = date
                }
            }
        }
        
        // Updating the main object with the merged data
        primaryState.isUserNotNotifiedBySound = mergedIsUserNotNotified
        primaryState.appFirstLaunchDate = earliestDate
        primaryState.lastCloudSyncDate = latestSyncDate
        
        log("  ✅ Combined data:", level: .info)
        log("     isUserNotNotifiedBySound: \(mergedIsUserNotNotified)", level: .info)
        
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
    /// Check whether the user should be notified with a sound
    func getUserNotifiedBySoundStatus() -> Bool {
        let appState = getOrCreateAppState()
        let result = appState.isUserNotNotifiedBySound
        return result
    }
    
    /// Enable the "Need to notify user" flag.
    func markUserNotNotifiedBySound() {
        let appState = getOrCreateAppState()
        appState.isUserNotNotifiedBySound = true
        
        saveContext()
    }
    
    /// Mark the user as already notified
    func markUserNotifiedBySound() {
        let appState = getOrCreateAppState()
        appState.isUserNotNotifiedBySound = false
        
        saveContext()
    }
    
    /// Update last sync date
    func updateLastCloudSyncDate() {
        let appState = getOrCreateAppState()
        appState.lastCloudSyncDate = Date()
        saveContext()
    }
    
    func getLastNoticeDate() -> Date? {
        let appState = getOrCreateAppState()
        return appState.latestNoticeDate
        
    }
    
    func updateLatestNoticeDate(_ date: Date) {
        let appState = getOrCreateAppState()
        appState.latestNoticeDate = date
        
        saveContext()
    }

    // MARK: - Methods for Cloud import of curated posts status
    /// The isNewCuratedPostsAvailable status is set to false after:
    /// - after the user imports new curated post materials from the cloud
    /// The isFirstImportCuratedPostsCompleted status is set to true:
    /// - initial value for the first app load
    /// - when checking and detecting new curated post materials in the cloud (included in PostsViewModel init())
    /// - when deleting all study materials - the "Erase all materials" function
    ///
    /// Get the status of new materials and author references in the cloud
    func getAvailableNewCuratedPostsStatus() -> Bool {
        let appState = getOrCreateAppState()
        return appState.isNewCuratedPostsAvailable
    }
    
    /// Set the status of new materials and author references in the cloud
    func setCuratedPostsLoadStatusOn() {
        let appState = getOrCreateAppState()
        appState.isNewCuratedPostsAvailable = true
        
        saveContext()
    }
        
    /// Reset the flag for the presence of new materials in the cloud
    func setCuratedPostsLoadStatusOff() {
        let appState = getOrCreateAppState()
        appState.isNewCuratedPostsAvailable = false

        saveContext()
    }
    
    /// Update the latest date of downloaded materials from the cloud
    func setLastDateOfCuaratedPostsLoaded(_ date: Date) {
        let appState = getOrCreateAppState()
        appState.latestDateOfCuaratedPostsLoaded = date
    }

    /// Get the latest date of downloaded materials from the cloud
    func getLastDateOfCuaratedPostsLoaded() -> Date? {
        let appState = getOrCreateAppState()
        return appState.latestDateOfCuaratedPostsLoaded
    }
    
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            log("❌ Error saving AppState: \(error)", level: .error)
        }
    }
    
}
