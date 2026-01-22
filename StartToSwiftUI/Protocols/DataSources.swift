//
//  DataSources.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 21.01.2026.
//

import Foundation
import SwiftData

// MARK: - Data Source Protocols
@MainActor
protocol PostsDataSourceProtocol {
    func fetchPosts() throws -> [Post]
    func insert(_ post: Post)
    func delete(_ post: Post)
    func save() throws
}
@MainActor
protocol NoticesDataSourceProtocol {
    func fetchNotices() throws -> [Notice]
    func insert(_ notice: Notice)
    func delete(_ notice: Notice)
    func save() throws
}



// MARK: - SwiftData Implementation

final class SwiftDataPostsDataSource: PostsDataSourceProtocol {
    let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchPosts() throws -> [Post] {
        let descriptor = FetchDescriptor<Post>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func insert(_ post: Post) {
        modelContext.insert(post)
    }
    
    func delete(_ post: Post) {
        modelContext.delete(post)
    }
    
    func save() throws {
        try modelContext.save()
    }
}

final class SwiftDataNoticesDataSource: NoticesDataSourceProtocol {
    let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchNotices() throws -> [Notice] {
        let descriptor = FetchDescriptor<Notice>(
            sortBy: [SortDescriptor(\.noticeDate, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func insert(_ notice: Notice) {
        modelContext.insert(notice)
    }
    
    func delete(_ notice: Notice) {
        modelContext.delete(notice)
    }
    
    func save() throws {
        try modelContext.save()
    }
}


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

final class MockNoticesDataSource: NoticesDataSourceProtocol {
    private var notices: [Notice]
    
    init(notices: [Notice] = PreviewData.sampleNotices) {
        self.notices = notices
        print("🔧 MockNoticesDataSource initialised with \(notices.count) notices")
    }
    
    func fetchNotices() -> [Notice] {
        print("📥 Mock: fetchNotices() called, returning \(notices.count) notices")
        return notices
    }
    
    func insert(_ notice: Notice) {
        guard !notices.contains(where: { $0.id == notice.id }) else {
            print("⚠️ Mock: Notice with ID \(notice.id) already exists, skipping")
            return
        }
        notices.append(notice)
        print("✅ Mock: Inserted notice '\(notice.title)' (id: \(notice.id)), total: \(notices.count)")
    }
    
    func delete(_ notice: Notice) {
        let beforeCount = notices.count
        notices.removeAll { $0.id == notice.id }
        print("🗑️ Mock: Deleted notice '\(notice.title)', count: \(beforeCount) → \(notices.count)")
    }
    
    func save() {
        // Mock - ничего не делаем
        print("💾 Mock: save() called, \(notices.count) notices in memory")
    }
}
