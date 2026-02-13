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
    private let noticesNetworkService: NetworkServiceProtocol
    
    private init() {
        self.noticesNetworkService = NetworkService(urlString: Constants.cloudNoticesURL)
    }
    
    // MARK: - Dates from SwiftData (cached in UserDefaults by StartToSwiftUIApp)
    
    /// Date of the last notice loaded into the app (from AppSyncState.latestNoticeDate)
    private var lastNoticeDate: Date {
        UserDefaults.standard.object(forKey: "lastNoticeDate") as? Date ?? Date.distantPast
    }
    
    /// Date of the first app launch (from AppSyncState.appFirstLaunchDate)
    private var appFirstLaunchDate: Date {
        UserDefaults.standard.object(forKey: "appFirstLaunchDate") as? Date ?? Date()
    }
    
    /// Filter date: max of lastNoticeDate and appFirstLaunchDate
    /// Same logic as in NoticeViewModel.importNoticesFromCloud()
    private var filterDate: Date {
        max(lastNoticeDate, appFirstLaunchDate)
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
            await checkForNewNotices()
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
    
    // MARK: - Check for New Notices
    /// Uses the same filtering logic as NoticeViewModel.importNoticesFromCloud():
    /// filterDate = max(lastNoticeDate, appFirstLaunchDate)
    /// Only notices newer than filterDate are considered new
    private func checkForNewNotices() async {
        do {
            let cloudNotices: [CodableNotice] = try await noticesNetworkService.fetchDataFromURLAsync()
            
            // Filter: only notices newer than filterDate
            let newNotices = cloudNotices.filter { $0.noticeDate > filterDate }
            
            if !newNotices.isEmpty {
                notificationService.sendNotification(
                    title: "StartToSwiftUI",
                    body: "\(newNotices.count) new notice\(newNotices.count == 1 ? "" : "s")",
                    identifier: "notices_update"
                )
            }
            
            log("🔄 Background notices check: \(newNotices.count) new (filter date: \(filterDate))", level: .info)
            
        } catch {
            log("❌ Background notices check failed: \(error.localizedDescription)", level: .error)
        }
    }
    
    // MARK: - Manual Check (for testing)
    func checkForNewNoticesManually() async {
        await checkForNewNotices()
    }
}
