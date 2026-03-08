//
//  SwiftDataPostsDataSource.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.01.2026.
//

import Foundation
import SwiftData

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
