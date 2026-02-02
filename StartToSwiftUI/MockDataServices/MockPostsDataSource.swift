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
    
    init(posts: [Post] = PreviewData.samplePosts) {
        self.posts = posts
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

