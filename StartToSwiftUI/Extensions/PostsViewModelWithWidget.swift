////
////  PostsViewModel.swift
////  StartToSwiftUI
////
////  Created by Andrey Efimov on 26.01.2026.
////
//
//import Foundation
//import WidgetKit
//
//// MARK: - Widget Data Update
//
//extension PostsViewModel {
//    
//    /// Updates widget with current study progress data
//    /// Call this method when posts are added, deleted, or progress changes
//    func updateWidgetData() {
//        let nonDraftPosts = allPosts.filter { !$0.draft }
//        
//        let data = StudyProgressData(
//            totalCount: nonDraftPosts.count,
//            freshCount: nonDraftPosts.filter { $0.progress == .fresh }.count,
//            startedCount: nonDraftPosts.filter { $0.progress == .started }.count,
//            studiedCount: nonDraftPosts.filter { $0.progress == .studied }.count,
//            practicedCount: nonDraftPosts.filter { $0.progress == .practiced }.count,
//            lastUpdated: Date()
//        )
//        
//        WidgetDataManager.shared.saveProgressData(data)
//        
//        // Request widget refresh
//        WidgetCenter.shared.reloadAllTimelines()
//    }
//}
