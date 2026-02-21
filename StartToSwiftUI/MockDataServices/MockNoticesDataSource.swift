//
//  MockNoticesDataSource.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.01.2026.
//

import Foundation

// MARK: - Mock Implementation

final class MockNoticesDataSource: NoticesDataSourceProtocol {
    
    private var notices: [Notice]
    
    init(notices: [Notice] = PreviewData.sampleNotices) {
        self.notices = notices
        log("🔧 MockNoticesDataSource initialised with \(notices.count) notices", level: .info)
    }
    
    func fetchNotices() -> [Notice] {
        log("📥 Mock: fetchNotices() called, returning \(notices.count) notices", level: .info)
        return notices
    }
    
    func insert(_ notice: Notice) {
        guard !notices.contains(where: { $0.id == notice.id }) else {
            log("⚠️ Mock: Notice with ID \(notice.id) already exists, skipping", level: .warning)
            return
        }
        notices.append(notice)
        log("✅ Mock: Inserted notice '\(notice.title)' (id: \(notice.id)), total: \(notices.count)", level: .info)
    }
    
    func delete(_ notice: Notice) {
        let beforeCount = notices.count
        notices.removeAll { $0.id == notice.id }
        log("🗑️ Mock: Deleted notice '\(notice.title)', count: \(beforeCount) → \(notices.count)", level: .info)
    }
    
    func save() {
        // Mock - nothing to do
        log("💾 Mock: save() called, \(notices.count) notices in memory", level: .info)
    }
}

final class MockFBNoticesManager: FBNoticesManagerProtocol {
    var mockNotices: [FBNoticeModel] = []
    func getAllNotices(after: Date) async -> [FBNoticeModel] { mockNotices }
}

