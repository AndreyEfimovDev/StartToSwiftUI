//
//  DataSources.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 21.01.2026.
//

import Foundation

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
