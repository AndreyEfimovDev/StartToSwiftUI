//
//  MockPostsDataSource.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.01.2026.
//

import Foundation

// MARK: - Mock Implementation
final class MockPostsDataSource: PostsDataSourceProtocol {
    
    private var posts: [Post]
    
    init(posts: [Post] = DevData.postsForCloud) {
        self.posts = posts

        
//        let calendar = Calendar.current
//        let now = Date()
//        
//        // Настройки временного диапазона
//        let monthsBack = 6
//        let daysInRange = monthsBack * 30 // ~6 месяцев
//        
//        // Распределение статусов
//        let statusDistribution: [StudyProgress: Double] = [
//            .fresh: 0.15,      // 15% постов - свежие
//            .started: 0.25,    // 25% постов - начаты
//            .studied: 0.40,    // 40% постов - изучены
//            .practiced: 0.20   // 20% постов - практикованы
//        ]
//        
//        // Обновляем даташтампы у переданных постов
//        var updatedPosts: [Post] = []
//        
//        for (_, var post) in posts.enumerated() {
//            // 1. Случайная дата поста в пределах 6 месяцев
//            let randomDaysAgo = Int.random(in: 0...daysInRange)
//            let postDate = calendar.date(byAdding: .day, value: -randomDaysAgo, to: now)!
//            
//            post.postDate = postDate
//            post.date = postDate
//            
//            // 2. Всегда есть дата добавления
//            post.addedDateStamp = calendar.date(
//                byAdding: .hour,
//                value: -Int.random(in: 1...24),
//                to: postDate
//            )!
//            
//            // 3. Определяем целевой статус
//            let randomValue = Double.random(in: 0...1)
//            var cumulativeProbability = 0.0
//            var targetProgress: StudyProgress = .fresh
//            
//            for (progress, probability) in statusDistribution {
//                cumulativeProbability += probability
//                if randomValue <= cumulativeProbability {
//                    targetProgress = progress
//                    break
//                }
//            }
//            
//            // 4. Устанавливаем даташтампы
//            switch targetProgress {
//            case .fresh:
//                post.startedDateStamp = nil
//                post.studiedDateStamp = nil
//                post.practicedDateStamp = nil
//                
//            case .started:
//                let daysToStart = Int.random(in: 1...30)
//                post.startedDateStamp = calendar.date(
//                    byAdding: .day,
//                    value: daysToStart,
//                    to: post.addedDateStamp ?? .now
//                )!
//                post.studiedDateStamp = nil
//                post.practicedDateStamp = nil
//                
//            case .studied:
//                let daysToStart = Int.random(in: 1...14)
//                post.startedDateStamp = calendar.date(
//                    byAdding: .day,
//                    value: daysToStart,
//                    to: post.addedDateStamp ?? .now
//                )!
//                
//                let daysToStudy = Int.random(in: 3...60)
//                post.studiedDateStamp = calendar.date(
//                    byAdding: .day,
//                    value: daysToStudy,
//                    to: post.startedDateStamp ?? .now
//                )!
//                post.practicedDateStamp = nil
//                
//            case .practiced:
//                let daysToStart = Int.random(in: 1...7)
//                post.startedDateStamp = calendar.date(
//                    byAdding: .day,
//                    value: daysToStart,
//                    to: post.addedDateStamp ?? .now
//                )!
//                
//                let daysToStudy = Int.random(in: 2...30)
//                post.studiedDateStamp = calendar.date(
//                    byAdding: .day,
//                    value: daysToStudy,
//                    to: post.startedDateStamp!
//                )!
//                
//                let daysToPractice = Int.random(in: 1...90)
//                post.practicedDateStamp = calendar.date(
//                    byAdding: .day,
//                    value: daysToPractice,
//                    to: post.studiedDateStamp!
//                )!
//            }
//            
//            // 5. Валидируем даташтампы (используем локальную функцию вместо метода экземпляра)
//            func validateTimestamps(for post: inout Post) {
//                // Проверяем startedDateStamp
//                if let started = post.startedDateStamp {
//                    if started > now {
//                        post.startedDateStamp = calendar.date(byAdding: .day, value: -1, to: now)
//                    }
//                    if started <= post.addedDateStamp  ?? .now {
//                        post.startedDateStamp = calendar.date(byAdding: .day, value: 1, to: post.addedDateStamp ?? .now)
//                    }
//                }
//                
//                // Проверяем studiedDateStamp
//                if let studied = post.studiedDateStamp {
//                    if studied > now {
//                        post.studiedDateStamp = calendar.date(byAdding: .day, value: -1, to: now)
//                    }
//                    if let started = post.startedDateStamp, studied <= started {
//                        post.studiedDateStamp = calendar.date(byAdding: .day, value: 1, to: started)
//                    }
//                }
//                
//                // Проверяем practicedDateStamp
//                if let practiced = post.practicedDateStamp {
//                    if practiced > now {
//                        post.practicedDateStamp = calendar.date(byAdding: .day, value: -1, to: now)
//                    }
//                    if let studied = post.studiedDateStamp, practiced <= studied {
//                        post.practicedDateStamp = calendar.date(byAdding: .day, value: 1, to: studied)
//                    }
//                }
//            }
//            
//            // Вызываем локальную функцию валидации
//            validateTimestamps(for: &post)
//            
//            // 6. Устанавливаем прогресс
//            post.progress = targetProgress
//            
//            updatedPosts.append(post)
//        }
//        
//        // Инициализируем stored property
//        self.posts = updatedPosts.sorted { $0.postDate ?? .now > $1.postDate ?? .now }
    }
    
    
    func fetchPosts() -> [Post] {
        return posts
    }
    
    func insert(_ post: Post) {
        posts.append(post)
    }
    
    func delete(_ post: Post) {
        posts.removeAll { $0.id == post.id }
    }
    
    func save() {
        // Mock - ничего не делаем
    }
}

