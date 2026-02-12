//
//  BackgroundRefreshService.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 11.02.2026.
//

import BackgroundTasks
import Foundation

final class BackgroundRefreshService {
    
    static let shared = BackgroundRefreshService()
    
    static let taskIdentifier = "PELSH.StartToSwiftUI.backgroundRefresh"
    
    private let notificationService = LocalNotificationService.shared
    private let postsNetworkService: NetworkServiceProtocol
    private let noticesNetworkService: NetworkServiceProtocol
    
    // Keys for storing last known dates in UserDefaults
    private let lastPostsDateKey = "bg_lastKnownPostsDate"
    private let lastNoticesDateKey = "bg_lastKnownNoticesDate"
    
    private init() {
        self.postsNetworkService = NetworkService(urlString: Constants.cloudPostsURL)
        self.noticesNetworkService = NetworkService(urlString: Constants.cloudNoticesURL)
    }
    
    /*
     One source of truth is the AppSyncState in SwiftData: forKey "appFirstLaunchDate".
     UserDefaults is only a cache for the background service, updated every time the application is launched.
     */
    private var appFirstLaunchDate: Date {
        UserDefaults.standard.object(forKey: "appFirstLaunchDate") as? Date ?? Date()
    }
    
    // MARK: - Register Background Task
    /// Call this in App init, BEFORE application finishes launching
    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.taskIdentifier,
            using: nil
        ) { [weak self] task in
            guard let bgTask = task as? BGAppRefreshTask else { return }
            self?.handleBackgroundRefresh(task: bgTask)
        }
        log("🔄 Background refresh task registered", level: .info)
    }
    
    // MARK: - Schedule Next Background Refresh
    /// Call this when app goes to background
    func scheduleBackgroundRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: Self.taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60) // Minimum 1 hour
        
        do {
            try BGTaskScheduler.shared.submit(request)
            log("🔄 Background refresh scheduled", level: .info)
        } catch {
            log("❌ Failed to schedule background refresh: \(error.localizedDescription)", level: .error)
        }
    }
    
    // MARK: - Handle Background Task
    private func handleBackgroundRefresh(task: BGAppRefreshTask) {
        // Schedule the next refresh
        scheduleBackgroundRefresh()
        
        let checkTask = Task {
            await checkForUpdates()
        }
        
        // If system needs to terminate — cancel
        task.expirationHandler = {
            checkTask.cancel()
        }
        
        Task {
            _ = await checkTask.result
            task.setTaskCompleted(success: true)
        }
    }
    
    // MARK: - Check for Updates
    private func checkForUpdates() async {
        await checkPostsUpdates()
        await checkNoticesUpdates()
    }
    
    private func checkPostsUpdates() async {
        do {
            let cloudPosts: [CodablePost] = try await postsNetworkService.fetchDataFromURLAsync()
            
            // Filter: only cloudNew posts newer than app first launch
            let relevantPosts = cloudPosts.filter { post in
                post.origin == .cloudNew && post.date > appFirstLaunchDate
            }
            
            let lastKnownDate = UserDefaults.standard.object(forKey: lastPostsDateKey) as? Date
            
            if let lastKnownDate {
                // Count posts newer than last check
                let newPosts = relevantPosts.filter { $0.date > lastKnownDate }
                
                if !newPosts.isEmpty {
                    notificationService.sendNotification(
                        title: "New Study Materials",
                        body: "\(newPosts.count) new material\(newPosts.count == 1 ? "" : "s") available",
                        identifier: "posts_update"
                    )
                }
            }
            // else: first check — just save the date, no notification
            
            // Save the latest date from cloud
            if let latestDate = relevantPosts.map({ $0.date }).max() {
                UserDefaults.standard.set(latestDate, forKey: lastPostsDateKey)
            }
            
            log("🔄 Background posts check: \(relevantPosts.count) relevant posts, last date: \(String(describing: lastKnownDate))", level: .info)
            
        } catch {
            log("❌ Background posts check failed: \(error.localizedDescription)", level: .error)
        }
    }
    
    private func checkNoticesUpdates() async {
        do {
            let cloudNotices: [CodableNotice] = try await noticesNetworkService.fetchDataFromURLAsync()
            
            // Filter: only notices newer than app first launch
            let relevantNotices = cloudNotices.filter { $0.noticeDate > appFirstLaunchDate }
            
            let lastKnownDate = UserDefaults.standard.object(forKey: lastNoticesDateKey) as? Date
            
            if let lastKnownDate {
                // Count notices newer than last check
                let newNotices = relevantNotices.filter { $0.noticeDate > lastKnownDate }
                
                if !newNotices.isEmpty {
                    notificationService.sendNotification(
                        title: "New Notification",
                        body: "\(newNotices.count) new notice\(newNotices.count == 1 ? "" : "s")",
                        identifier: "notices_update"
                    )
                }
            }
            // else: first check — just save the date, no notification
            
            // Save the latest date from cloud
            if let latestDate = relevantNotices.map({ $0.noticeDate }).max() {
                UserDefaults.standard.set(latestDate, forKey: lastNoticesDateKey)
            }
            
            log("🔄 Background notices check: \(relevantNotices.count) relevant notices, last date: \(String(describing: lastKnownDate))", level: .info)
            
        } catch {
            log("❌ Background notices check failed: \(error.localizedDescription)", level: .error)
        }
    }
    
    // MARK: - Manual Check (for testing)
    func checkForUpdatesManually() async {
        await checkForUpdates()
    }
}
