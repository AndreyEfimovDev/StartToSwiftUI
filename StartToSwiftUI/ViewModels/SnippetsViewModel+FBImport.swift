//
//  SnippetsViewModel+FBImport.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.03.2026.
//

import Foundation

// MARK: - Firebase Import & Update Check
extension SnippetsViewModel {

    /// Fetches only snippets newer than lastDateSnippetsLoaded (incremental sync).
    /// Returns true on success (even if no new snippets), false on network error.
    func importSnippetsFromFirebase() async -> Bool {
        clearError()
        let sourceName = isSwiftData ? "SwiftData" : "(Mock)"

        let fbResponse = await fbSnippetsManager.fetchFBSnippets(after: lastDateSnippetsLoaded)
        log("🔥 lastDateSnippetsLoaded: \(String(describing: lastDateSnippetsLoaded))", level: .info)
        log("☁️ Received \(fbResponse.count) snippets from \(sourceName)", level: .info)

        let newSnippets = filterUniqueSnippets(from: fbResponse)

        guard !newSnippets.isEmpty else {
            hapticManager.impact(style: .light)
            log("ℹ️ No new snippets from \(sourceName)", level: .info)

            // Migration: restore lastDate from local if never set
            // TODO: Remove after v?.? — one-time fix
            if let appStateManager {
                let lastDate = appStateManager.getLastDateOfSnippetsLoaded()
                if lastDate == nil || (lastDate ?? Date()) <= Date(timeIntervalSince1970: 1) {
                    if let latestDate = allSnippets.max(by: { $0.date < $1.date })?.date {
                        appStateManager.setLastDateOfSnippetsLoaded(latestDate.addingTimeInterval(1))
                        log("🔥 lastSnippetsFBUpdateDate restored from local: \(latestDate)", level: .info)
                    }
                }
            }
            return true
        }

        for fbSnippet in newSnippets {
            dataSource.insert(SnippetMigrationHelper.convertFromFirebase(fbSnippet))
        }
        saveContextAndReload()

        if let appStateManager,
           let latestDate = newSnippets.max(by: { $0.date < $1.date })?.date {
            appStateManager.setLastDateOfSnippetsLoaded(latestDate.addingTimeInterval(1))
            log("🔥 lastSnippetsFBUpdateDate updated: \(latestDate)", level: .info)
        }

        hapticManager.notification(type: .success)
        log("✅ Added \(newSnippets.count) new snippets from \(sourceName)", level: .info)
        return true
    }

    /// Returns true if Firestore has snippets newer than lastDateSnippetsLoaded.
    func checkFBSnippetsForUpdates() async -> Bool {
        clearError()
        guard let appStateManager else { return false }
        guard let lastDate = appStateManager.getLastDateOfSnippetsLoaded() else {
            return true // never loaded → updates available
        }
        let newSnippets = await fbSnippetsManager.fetchFBSnippets(after: lastDate)
        let hasUpdates = !newSnippets.isEmpty
        log("🔍 checkFBSnippetsForUpdates: \(hasUpdates ? "Updates available" : "No updates")", level: .debug)
        return hasUpdates
    }
}
