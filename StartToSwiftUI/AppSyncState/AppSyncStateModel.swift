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
    var lastNoticesFBUpdateDate: Date?
    var lastPostsFBUpdateDate: Date?
    
    var lastCloudSyncDateToMergeDuplicate: Date?
    var appFirstLaunchDate: Date?
    
    // CloudKit does not support [String] directly in SwiftData
    // It is stored as a String separated by commas.
    //
    // ВАЖНО: разбор строится на предположении, что ни один ID сниппета
    // (CodeSnippet.id, см. Models/Snippets/CodeSnippet.swift) никогда не
    // содержит запятую — иначе round-trip тихо расколет один ID на
    // несколько при следующем чтении. Сейчас ID — захардкоженные слаги
    // вида "A006"/"B001" (см. SnippetsRepository.swift), так что это
    // безопасно, но при добавлении новых ID это ограничение нужно
    // соблюдать явно, компилятор/рантайм его не проверяют.
    var snippetFavoriteIDsRaw: String = ""
    var snippetFavoriteIDs: [String] {
        get { snippetFavoriteIDsRaw.isEmpty ? [] : snippetFavoriteIDsRaw.components(separatedBy: ",") }
        set { snippetFavoriteIDsRaw = newValue.joined(separator: ",") }
    }

    // For internal purposes:
    // - cleanupDuplicateAppStates()
    // - getOrCreateAppState()
    // - mergeDuplicateAppStates()
    
    init(
        id: String = "app_state_singleton",
        
        lastNoticesFBUpdateDate: Date? = nil,
        lastPostsFBUpdateDate: Date? = nil,

        lastCloudSyncDateToMergeDuplicate: Date? = nil,
        appFirstLaunchDate: Date? = nil
        
    ) {
        self.id = id
        
        self.lastNoticesFBUpdateDate = lastNoticesFBUpdateDate
        self.lastPostsFBUpdateDate = lastPostsFBUpdateDate
        
        self.lastCloudSyncDateToMergeDuplicate = lastCloudSyncDateToMergeDuplicate
        self.appFirstLaunchDate = appFirstLaunchDate
        
    }
}

