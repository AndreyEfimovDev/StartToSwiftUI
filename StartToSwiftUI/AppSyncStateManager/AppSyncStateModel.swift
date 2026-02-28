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
        lastPostsFBUpdateDate: Date? = nil,

        lastCloudSyncDateToMergeDuplicate: Date? = nil,
        appFirstLaunchDate: Date? = nil
        
    ) {
        self.id = id
        
        self.latestNoticeDate = lastNoticeDate
        self.lastPostsFBUpdateDate = lastPostsFBUpdateDate
        
        self.lastCloudSyncDateToMergeDuplicate = lastCloudSyncDateToMergeDuplicate
        self.appFirstLaunchDate = appFirstLaunchDate
        
    }
}

