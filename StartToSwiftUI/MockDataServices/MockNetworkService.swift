//
//  MockNetworkService.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.01.2026.
//

import Foundation


// MARK: - Mock Network Services

final class MockNetworkService: NetworkServiceProtocol {
    
    private let mockData: Any
    private let shouldFail: Bool
    private let delay: TimeInterval
    
    var fetchCallCount = 0
    
    init(mockData: Any, shouldFail: Bool = false, delay: TimeInterval = 0) {
        self.mockData = mockData
        self.shouldFail = shouldFail
        self.delay = delay
    }
    
    func fetchDataFromURLAsync<T: Codable>() async throws -> T {
        fetchCallCount += 1
        
        // Simulating network delay
        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        // Simulating an error
        if shouldFail {
            throw APIError.invalidResponseStatus
        }
        
        // Returning mock data
        guard let result = mockData as? T else {
            throw NSError(
                domain: "MockNetworkService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Type mismatch: expected \(T.self), got \(type(of: mockData))"]
            )
        }
        
        return result
    }
}

// MARK: - Convenience Mock Factories

extension MockNetworkService {
    
    /// Mock for successful post loading
    static func mockPosts(_ posts: [CodablePost] = PreviewData.sampleCodablePosts) -> MockNetworkService {
        MockNetworkService(mockData: posts)
    }
    
    /// Mock for successful loading of notices
    static func mockNotices(_ notices: [CodableNotice] = PreviewData.sampleCodableNotices) -> MockNetworkService {
        MockNetworkService(mockData: notices)
    }
    
    /// Mock to simulate network errors
    static func mockError() -> MockNetworkService {
        MockNetworkService(mockData: [], shouldFail: true)
    }
    
    /// Mock with delay for testing loading states
    static func mockWithDelay(_ data: Any, delay: TimeInterval = 2.0) -> MockNetworkService {
        MockNetworkService(mockData: data, delay: delay)
    }
}
