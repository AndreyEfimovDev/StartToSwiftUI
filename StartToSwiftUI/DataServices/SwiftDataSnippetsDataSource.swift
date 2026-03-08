//
//  SwiftDataSnippetsDataSource.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.03.2026.
//

import Foundation
import SwiftData

final class SwiftDataSnippetsDataSource: SnippetsDataSourceProtocol {
    let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchSnippets() throws -> [CodeSnippet] {
        try modelContext.fetch(FetchDescriptor<CodeSnippet>())
    }
    func insert(_ snippet: CodeSnippet) { modelContext.insert(snippet) }
    func delete(_ snippet: CodeSnippet) { modelContext.delete(snippet) }
    func save() throws { try modelContext.save() }
}
