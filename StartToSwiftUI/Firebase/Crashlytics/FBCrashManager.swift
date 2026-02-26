//
//  FBCrashManager.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.02.2026.
//

import Foundation
import FirebaseCrashlytics

final class FBCrashManager {
    
    static let shared = FBCrashManager()
    private init() { }
        
    func addLog(_ message: String) {
        Crashlytics.crashlytics().log(message)
    }
    
    func sendNonFatal(_ error: Error) {
        Crashlytics.crashlytics().record(error: error)
    }
    
    func setUserContext(_ postsCount: Int, _ hasCloudPosts: Bool) {
        Crashlytics.crashlytics().setCustomValue(postsCount, forKey: "posts_count")
        Crashlytics.crashlytics().setCustomValue(hasCloudPosts, forKey: "has_cloud_posts")
    }
}
