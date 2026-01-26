//
//  ProgressStats.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 13.01.2026.
//

import Foundation

// MARK: - Statistics
struct ProgressStats {
    let added: Int
    let started: Int
    let studied: Int
    let practiced: Int
    let completionRate: Double
    
    init(posts: [Post], period: TimePeriod) {
        let now = Date()
        let startDate = Calendar.current.date(byAdding: .month, value: -period.months, to: now) ?? now
        // Added = all posts with addedDateStamp in the period
        added = posts.filter {
            guard let date = $0.addedDateStamp else { return false }
            return /*$0.progress == .fresh && */date >= startDate
        }.count
        // Started = all posts with startedDateStamp in the period
        started = posts.filter {
            guard let date = $0.startedDateStamp else { return false }
            return /*$0.progress == .started && */date >= startDate
        }.count
        // Studied = all posts with studiedDateStamp in the period
        studied = posts.filter {
            guard let date = $0.studiedDateStamp else { return false }
            return /*$0.progress == .studied && */date >= startDate
        }.count
        // Practiced = all posts with practicedDateStamp in the period
        practiced = posts.filter {
            guard let date = $0.practicedDateStamp else { return false }
            return /*$0.progress == .practiced && */date >= startDate
        }.count
        
        let totalPostsInPeriod = started + studied + practiced
        completionRate = added > 0 ? Double(totalPostsInPeriod) / Double(added) * 100 : 0
    }
}
