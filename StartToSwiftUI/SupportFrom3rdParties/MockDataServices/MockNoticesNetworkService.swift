//
//  MockNoticesNetworkService.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.01.2026.
//

import Foundation


class MockNoticesNetworkService {
    var mockNotices: [CodableNotice] = []
    var fetchCallCount = 0
        
    func fetchDataFromURLAsync<T: Codable>() async throws -> T {
        fetchCallCount += 1
        
        // Checking the T type
        if T.self == [CodableNotice].self {
            return mockNotices as! T
        }
        
        // If it's another type, throw an error.
        throw NSError(
            domain: "MockError",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Unsupported type \(T.self)"]
        )
    }
}
