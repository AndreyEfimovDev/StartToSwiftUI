//
//  PostsViewModel+FBCloudImport.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 21.02.2026.
//

import Foundation

// MARK: - Firebase Import & Update Check
extension PostsViewModel {
    
    /// Firebase import of study materials
    func importPostsFromFirebase() async -> Bool {
        // Параллельный вызов пойдёт в Firebase с той же датой "after", что и
        // уже выполняющийся (она ещё не сдвинулась) — он гарантированно не
        // найдёт ничего сверх того, что найдёт уже идущий запрос, поэтому
        // просто пропускаем его.
        guard !isImportingPosts else { return false }
        isImportingPosts = true
        defer { isImportingPosts = false }

        crashManager.addLog("importPostsFromFirebase: started, posts count: \(allPosts.count)")
        let trace = performanceManager.startTrace(name: "import_posts_firebase")
        
        clearError()
        
        let sourceName = isSwiftData ? "SwiftData" : "(Mock)"
        
        guard let appStateManager else { return false }
        let importAfterDate = appStateManager.getLastDateOfPostsLoaded()
        let result = await fbPostsManager.fetchFBPosts(after: importAfterDate)
        log("🔥 lastDatePostsLoaded \(String(describing: lastDatePostsLoaded))", level: .info)
        
        switch result {
        case .failure(.networkUnavailable):
            handleError(nil, message: "No internet connection. Please check your network and try again.")
            performanceManager.stopTrace(trace)
            return false

        case .failure(.unknown(let error)):
            handleError(error, message: "Failed to load posts from Firebase")
            performanceManager.stopTrace(trace)
            return false

        case .success(let fbResponse):
            let fbResponseChecked = filterUniquePosts(from: fbResponse)
            guard !fbResponseChecked.isEmpty else {
                hapticManager.impact(style: .light)
                performanceManager.stopTrace(trace)
                log("ℹ️ No new posts from \(sourceName)", level: .info)

                // All received posts already exist locally — advance date past them
                // to prevent the same posts from being found on the next check
                if let latestDate = fbResponse.max(by: { $0.date < $1.date })?.date {
                    appStateManager.setLastDateOfPostsLoaded(latestDate.addingTimeInterval(1))
                    log("🔥 lastDateOfPostsLoaded advanced past known duplicates: \(latestDate)", level: .info)
                }

                // Migration: If the date has not yet been set, we take it from local posts
                // One-time fix for users who had lastPostsFBUpdateDate = nil before saveContext() was added
                let lastDate = appStateManager.getLastDateOfPostsLoaded()
                if lastDate == nil || (lastDate ?? Date()) <= Date(timeIntervalSince1970: 1) {
                    let cloudPosts = allPosts.filter { $0.origin == .cloud || $0.origin == .cloudNew }
                    if let latestDate = cloudPosts.max(by: { $0.date < $1.date })?.date {
                        appStateManager.setLastDateOfPostsLoaded(latestDate.addingTimeInterval(1))
                        log("🔥 lastPostsFBUpdateDate restored from local posts: \(latestDate)", level: .info)
                    }
                }
                return true
            }
            
            analyticsManager.logEvent(name: "import_posts", params: ["count": fbResponseChecked.count])
            
            // Adding new posts
            for firebasePost in fbResponseChecked {
                dataSource.insert(PostMigrationHelper.convertFromFirebase(firebasePost))
            }
            saveContextAndReload()
            
            // Update last date of posts loaded from Firebase
            //
            // Дата сознательно считается только по успешно декодированным
            // постам, а не по всем документам ответа: битый документ (нет
            // обязательного поля — обычно его прочитали недозаполненным в
            // консоли Firestore) не сдвигает дату и перечитывается при каждом
            // импорте, пока его не исправят, — после исправления он догрузится
            // сам. Если сдвигать дату и за битые, исправленный документ клиент
            // уже никогда не получит (без ручного подъёма его `date`). Цена —
            // пара лишних чтений и повтор ошибки в логе, это приемлемо.
            // То же правило действует в ветке "нет новых постов" выше.
            if let latestDate = fbResponseChecked.max(by: { $0.date < $1.date })?.date {
                appStateManager.setLastDateOfPostsLoaded(latestDate.addingTimeInterval(1))
                log("🔥 lastPostsFBUpdateDate updated in appStateManager \(latestDate)", level: .info)
            }
            
            hapticManager.notification(type: .success)
            
            crashManager.addLog("importPostsFromFirebase: finished, import count: \(fbResponseChecked.count)")
            crashManager.addLog("importPostsFromFirebase: finished, updated posts count: \(allPosts.count)")
            log("✅ Added \(fbResponseChecked.count) new posts from \(sourceName)", level: .info)
            performanceManager.setValue(
                trace,
                value: "\(fbResponseChecked.count)/\(fbResponse.count)",
                forAttribute: "posts_new_of_received"
            )
            performanceManager.stopTrace(trace)
            return true
        }
    }
    
    /// Check for updates to available posts in the cloud
    func checkFBPostsForUpdates() async -> Bool {
        guard !isCheckingPostsForUpdates else { return false }
        isCheckingPostsForUpdates = true
        defer { isCheckingPostsForUpdates = false }

        clearError()
        guard let appStateManager else { return false }
        guard let lastLoadedDate = appStateManager.getLastDateOfPostsLoaded() else {
            return true // дата не установлена — считаем что обновления есть
        }
        log("🔍 checkFBPostsForUpdates date: \(String(describing: lastLoadedDate))", level: .info)
        
        let result = await fbPostsManager.fetchFBPosts(after: lastLoadedDate)
        
        switch result {
        case .success(let newPosts):
            return !newPosts.isEmpty
        case .failure(.networkUnavailable):
            handleError(nil, message: "No internet connection. Please check your network and try again.")
            return false
        case .failure(.unknown(let error)):
            handleError(error, message: "Failed to check for updates")
            return false
        }
    }
    
    // MARK: - Migration
    func migrateHiddenToDeleted(removeDuplicates: Bool = true) {
        let hiddenPosts = allPosts.filter { $0.status == .hidden }
        guard !hiddenPosts.isEmpty else { return }

        hiddenPosts.forEach { $0.status = .deleted }
        saveContextAndReload(removeDuplicates: removeDuplicates)
        
        log("🔄 Migrated \(hiddenPosts.count) posts: hidden → deleted", level: .info)
    }
    
}
