//
//  FBAnalyticsManager.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.02.2026.
//

import SwiftUI
import FirebaseAnalytics

final class FBAnalyticsManager {
    static let shared = FBAnalyticsManager()

    private init() { }
    
    func logEvent(name: String, params: [String:Any]? = nil) {
        Analytics.logEvent(name, parameters: params)
    }
    
    func logScreen(name: String) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: name
        ])
    }
}

