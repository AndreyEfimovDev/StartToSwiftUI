//
//  AppSyncStateModel.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 21.02.2026.
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
    var isNewCuratedPostsAvailable: Bool = false // For the first launch, false, it will be updated in checkCloudPostsForUpdates()
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

