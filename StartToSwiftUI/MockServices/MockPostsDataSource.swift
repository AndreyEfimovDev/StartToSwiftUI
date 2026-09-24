//
//  MockPostsDataSource.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.01.2026.
//

import Foundation
//#if DEBUG
// MARK: - Mock Implementation
final class MockPostsDataSource: PostsDataSourceProtocol {
    
    private var posts: [Post]
    /// true — save() бросает ошибку (для тестов сценария "сохранение не удалось").
    var shouldThrowOnSave = false
    
    init(posts: [Post] = PreviewData.samplePosts) {
        self.posts = posts
    }
    
    
    func fetchPosts() throws -> [Post] {
        return posts
    }
    
    func insert(_ post: Post) {
        posts.append(post)
    }
    
    // Удаляем конкретный объект, а не все с тем же id — как SwiftData.
    // Иначе при очистке дублей вместе с копиями пропала бы и оставляемая.
    func delete(_ post: Post) {
        posts.removeAll { $0 === post }
    }

    func deleteAll() throws {
        posts.removeAll()
    }
    
    func save() throws {
        if shouldThrowOnSave {
            throw MockSaveError.saveFailed
        }
    }

    enum MockSaveError: Error {
        case saveFailed
    }
}
//#endif
