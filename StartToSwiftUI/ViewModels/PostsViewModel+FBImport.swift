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
            // Всё новое из облака забрано (или нового не оказалось) — кнопка
            // "Check for materials update" больше не нужна.
            hasPostsUpdate = false
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
    
    /// Принудительная проверка новых постов в облаке — по действию
    /// пользователя (модалка "Check for materials update").
    ///
    /// Ошибки показываются глобальным алертом. Результат записывается в
    /// `hasPostsUpdate` и возвращается вызывающей стороне.
    ///
    /// - Returns: `true`, если есть новые посты; `false` — если их нет, при
    ///   ошибке или если проверка уже выполняется.
    func checkFBPostsForUpdates() async -> Bool {
        guard !isCheckingPostsForUpdates else { return false }
        isCheckingPostsForUpdates = true
        defer { isCheckingPostsForUpdates = false }

        clearError()
        guard let result = await fetchPostsUpdateStatus() else { return false }

        switch result {
        case .success(let hasNewPosts):
            hasPostsUpdate = hasNewPosts
            return hasNewPosts
        case .failure(.networkUnavailable):
            handleError(nil, message: "No internet connection. Please check your network and try again.")
            return false
        case .failure(.unknown(let error)):
            handleError(error, message: "Failed to check for updates")
            return false
        }
    }

    /// Фоновая проверка новых постов — при запуске приложения и
    /// pull-to-refresh. Обновляет `hasPostsUpdate`.
    ///
    /// Намеренно тихая: не вызывает `clearError()`/`handleError()`. Рядом
    /// выполняется импорт notices с тем же `ErrorManager` — `clearError()`
    /// закрыл бы его алерт раньше, чем пользователь его увидит, а о проблемах
    /// с сетью тот импорт и так сообщает. При сбое флаг не меняется.
    func refreshPostsUpdateStatus() async {
        guard !isCheckingPostsForUpdates else { return }
        isCheckingPostsForUpdates = true
        defer { isCheckingPostsForUpdates = false }

        guard let result = await fetchPostsUpdateStatus() else { return }

        switch result {
        case .success(let hasNewPosts):
            hasPostsUpdate = hasNewPosts
        case .failure(let error):
            log("⚠️ Background posts update check failed: \(error)", level: .warning)
        }
    }

    /// Общая часть принудительной и фоновой проверки: запрос в Firestore
    /// относительно даты последней загрузки постов.
    ///
    /// - Returns: результат запроса; `.success(true)` без запроса, если дата
    ///   ещё не установлена; `nil`, если проверить нельзя (нет `appStateManager`).
    private func fetchPostsUpdateStatus() async -> Result<Bool, FBFetchError>? {
        guard let appStateManager else { return nil }
        guard let lastLoadedDate = appStateManager.getLastDateOfPostsLoaded() else {
            return .success(true) // дата не установлена — считаем что обновления есть
        }
        log("🔍 checkFBPostsForUpdates date: \(String(describing: lastLoadedDate))", level: .info)
        return await fbPostsManager.hasFBPosts(after: lastLoadedDate)
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
