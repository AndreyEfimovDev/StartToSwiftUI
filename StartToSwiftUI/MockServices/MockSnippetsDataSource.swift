//
//  MockFBSnippetsService.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.03.2026.
//

import Foundation

// MARK: - Mock SwiftData Source

final class MockSnippetsDataSource: SnippetsDataSourceProtocol {
    var snippets: [CodeSnippet]

    init(snippets: [CodeSnippet] = []) {
        self.snippets = snippets
    }

    func fetchSnippets() throws -> [CodeSnippet] { snippets }
    func insert(_ snippet: CodeSnippet) { snippets.append(snippet) }
    func delete(_ snippet: CodeSnippet) { snippets.removeAll { $0.id == snippet.id } }
    func save() throws {}
}







