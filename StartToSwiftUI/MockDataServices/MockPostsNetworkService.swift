//
//  MockPostsNetworkService.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.01.2026.
//

import Foundation

class MockPostsNetworkService {
    var mockPosts: [CodablePost] = []
    var fetchCallCount = 0
    
    // Create a real NetworkService, but override its behavior
    private let realService = NetworkService(baseURL: Constants.cloudNoticesURL)
    
    func fetchDataFromURLAsync<T: Codable>() async throws -> T {
        fetchCallCount += 1
        
        // Checking the T type
        if T.self == [CodablePost].self {
            return mockPosts as! T
        }

        // If it is another type, throw an error.
        throw NSError(
            domain: "MockError",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Unsupported type \(T.self)"]
        )
        
        // Or delegate to a real service
        // return try await realService.fetchDataFromURLAsync()
    }
}
