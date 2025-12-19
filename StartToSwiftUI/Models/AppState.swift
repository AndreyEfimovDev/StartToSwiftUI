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
    var hasLoadedStaticPosts: Bool = false
    var isUserNotNotifiedBySound: Bool = true // Используем только при запуске приложения для звукового оповещения- если есть новые уведомления, то ставим флаг в true
    var appFirstLaunchDate: Date?
    var lastCloudSyncDate: Date?
    
    init(
        id: String = "app_state_singleton",
        hasLoadedStaticPosts: Bool = false,
        isUserNotNotifiedBySound: Bool = true,
        appFirstLaunchDate: Date? = nil,
        lastCloudSyncDate: Date? = nil
    ) {
        self.id = id
        self.hasLoadedStaticPosts = hasLoadedStaticPosts
        self.isUserNotNotifiedBySound = isUserNotNotifiedBySound
        self.appFirstLaunchDate = appFirstLaunchDate
        self.lastCloudSyncDate = lastCloudSyncDate
    }
}
