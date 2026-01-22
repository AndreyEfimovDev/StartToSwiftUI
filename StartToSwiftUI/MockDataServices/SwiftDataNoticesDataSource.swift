//
//  SwiftDataNoticesDataSource.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.01.2026.
//

import Foundation
import SwiftData

// MARK: - SwiftData Implementation

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
