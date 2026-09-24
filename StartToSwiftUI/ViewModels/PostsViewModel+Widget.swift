//
//  PostsViewModel+Widget.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 11.02.2026.
//

import WidgetKit

// MARK: - Widget Data Update
extension PostsViewModel {
    
    /// Updates widget with current study progress data.
    ///
    /// Вызывается из `loadPostsFromSwiftData()` после каждой перезагрузки
    /// постов. Если счётчики не изменились с прошлой записи, виджет не
    /// трогается: перезагрузки без изменений прогресса (повторный синк,
    /// refresh, уведомление CloudKit о собственном сохранении) не должны
    /// впустую перезаписывать данные и перезапускать таймлайн виджета.
    func updateWidgetData() {
        let posts = allPosts.filter { !$0.draft }
        
        let added = posts.filter { $0.addedDateStamp != nil }.count
        let started = posts.filter { $0.startedDateStamp != nil }.count
        let studied = posts.filter { $0.studiedDateStamp != nil }.count
        let practiced = posts.filter { $0.practicedDateStamp != nil }.count

        let counts = [added, started, studied, practiced]
        guard counts != lastWidgetCounts else { return }
        lastWidgetCounts = counts
        
        let data = StudyProgressData(
            freshCount: added,
            startedCount: started,
            studiedCount: studied,
            practicedCount: practiced,
            lastUpdated: Date()
        )

        WidgetDataManager.shared.saveProgressData(data)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
