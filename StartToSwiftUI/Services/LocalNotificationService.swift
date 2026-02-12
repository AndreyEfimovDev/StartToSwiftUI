//
//  LocalNotificationService.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 11.02.2026.
//

import UserNotifications

final class LocalNotificationService {
    
    static let shared = LocalNotificationService()
    
    private init() {}
    
    // MARK: - Request Permission
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error {
                log("❌ Notification permission error: \(error.localizedDescription)", level: .error)
            } else {
                log("🔔 Notification permission granted: \(granted)", level: .info)
            }
        }
    }
    
    // MARK: - Check Permission Status
    func checkPermissionStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            completion(settings.authorizationStatus == .authorized)
        }
    }
    
    // MARK: - Send Local Notification
    func sendNotification(title: String, body: String, identifier: String = UUID().uuidString) {
        checkPermissionStatus { [weak self] isAuthorized in
            guard isAuthorized else {
                log("🔔 Notifications not authorized, skipping", level: .info)
                return
            }
            self?.deliverNotification(title: title, body: body, identifier: identifier)
        }
    }
    
    private func deliverNotification(title: String, body: String, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        // Deliver immediately (1 second delay required by API)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                log("❌ Failed to send notification: \(error.localizedDescription)", level: .error)
            } else {
                log("🔔 Notification sent: \(title)", level: .info)
            }
        }
    }
    
    // MARK: - Remove All Pending Notifications
    func removeAllPending() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
