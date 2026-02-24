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

    var lastPostsFBUpdateDate: Date?
    
    // For internal purposes:
    // - cleanupDuplicateAppStates()
    // - getOrCreateAppState()
    // - mergeDuplicateAppStates()
    
    var lastCloudSyncDateToMergeDuplicate: Date?
    var appFirstLaunchDate: Date?
    
    init(
        id: String = "app_state_singleton",
        
        lastNoticeDate: Date? = nil,
        isUserNotNotifiedBySound: Bool = true,
        
        lastPostsFBUpdateDate: Date? = nil,

        lastCloudSyncDate: Date? = nil,
        appFirstLaunchDate: Date? = nil
        
    ) {
        self.id = id
        
        self.isUserNotNotifiedBySound = isUserNotNotifiedBySound
        self.latestNoticeDate = lastNoticeDate

        self.lastPostsFBUpdateDate = lastPostsFBUpdateDate
        
        self.lastCloudSyncDateToMergeDuplicate = lastCloudSyncDate
        self.appFirstLaunchDate = appFirstLaunchDate
        
    }
}

