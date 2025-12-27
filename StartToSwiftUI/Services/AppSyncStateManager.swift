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
    var id: String = "app_state_singleton" // Always one copy
//    var isTermsOfUseAccepted: Bool = false
    
    // Flag for the need to load static posts, set by the user in Preferences: true - load
    var shouldLoadStaticPosts: Bool = true
    // Flag indicating load static posts status: true - already loaded
    var hasLoadedStaticPosts: Bool = false
    
    // Set the flag to true to notify the user with a sound once about new notices if they appear
    var isUserNotNotifiedBySound: Bool = true
    // Date of last notices
    var latestNoticeDate: Date?

    // Flag indicating the presence of new curated materials
    var isNewCuratedPostsAvailable: Bool = false // For the first launch, false, it will be updated in checkCloudCuratedPostsForUpdates()
    var latestDateOfCuaratedPostsLoaded: Date? // Update in importPostsFromCloud() and use in CheckForPostsUpdateView()
    
    // For internal purposes:
    // - cleanupDuplicateAppStates()
    // - getOrCreateAppState()
    // - mergeDuplicateAppStates()
    var lastCloudSyncDate: Date?
    var appFirstLaunchDate: Date?
    
    init(
        id: String = "app_state_singleton",
//        isTermsOfUseAccepted: Bool = false,
        
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
//        self.isTermsOfUseAccepted = isTermsOfUseAccepted
        
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
        var mergedHasLoadedStatic = false
        var mergedIsUserNotNotified = true
        var earliestDate: Date?
        var latestSyncDate: Date?
        
        for state in sortedStates {
            // OR logic for hasLoadedStaticPosts
            if state.hasLoadedStaticPosts {
                mergedHasLoadedStatic = true
            }
            
            // AND logic for isUserNotNotifiedBySound (if at least one is already notified, we take false)
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
        primaryState.hasLoadedStaticPosts = mergedHasLoadedStatic
        primaryState.isUserNotNotifiedBySound = mergedIsUserNotNotified
        primaryState.appFirstLaunchDate = earliestDate
        primaryState.lastCloudSyncDate = latestSyncDate
        
        log("  ✅ Combined data:", level: .info)
        log("     hasLoadedStaticPosts: \(mergedHasLoadedStatic)", level: .info)
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
    
    // MARK: - Method for isTermsOfUseAccepted
    
//    func getTermsOfUseAcceptedStatus() -> Bool {
//        let appState = getOrCreateAppState()
//        return appState.isTermsOfUseAccepted
//    }
//
//    func setTermsOfUseAccepted(_ accepted: Bool) {
//        let appState = getOrCreateAppState()
//        appState.isTermsOfUseAccepted = accepted
//        
//        saveContext()
//    }
//        
//    // Accept Terms of Use
//    func acceptTermsOfUse() {
//        setTermsOfUseAccepted(true)
//    }
        
    // MARK: - Methods for Static posts
    /// Check if static posts were loaded
    func getStaticPostsLoadToggleStatus() -> Bool {
        let appState = getOrCreateAppState()
        let result = appState.shouldLoadStaticPosts
        return result
    }
    
    /// Enable loading of static posts, set by the user in Preferences: true - load
    func setShouldLoadStaticPostsOn() {
        let appState = getOrCreateAppState()
        appState.shouldLoadStaticPosts = true
        
        saveContext()
    }
        
    /// Enable loading of static posts, set by the user in Preferences: false - do not load
    func setShouldLoadStaticPostsOff() {
        let appState = getOrCreateAppState()
        appState.shouldLoadStaticPosts = false
        
        saveContext()
    }
    
    /// Check if static posts are loaded
    func checkIfStaticPostsHasLoaded() -> Bool {
        let appState = getOrCreateAppState()
        let result = appState.hasLoadedStaticPosts
        return result
    }
    
    /// Mark static posts loaded
    func markStaticPostsAsLoaded() {
        let appState = getOrCreateAppState()
        appState.hasLoadedStaticPosts = true
        
        saveContext()
    }
    
    /// Mark static posts as not loaded
    func markStaticPostsAsNotLoaded() {
        let appState = getOrCreateAppState()
        appState.hasLoadedStaticPosts = false
        
        saveContext()
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
        
    /// Reset the flag for the presence of new materials with author links in the cloud
    func setCuratedPostsLoadStatusOff() {
        let appState = getOrCreateAppState()
        appState.isNewCuratedPostsAvailable = false

        saveContext()
    }
    
    /// Update the latest date of downloaded materials and author links from the cloud
    func setLastDateOfCuaratedPostsLoaded(_ date: Date) {
        let appState = getOrCreateAppState()
        appState.latestDateOfCuaratedPostsLoaded = date
    }

    /// Get the latest date of downloaded materials and author links from the cloud
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
