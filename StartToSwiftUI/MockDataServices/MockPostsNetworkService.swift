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
    
    // Создаем реальный NetworkService, но переопределяем его поведение
    private let realService = NetworkService(baseURL: Constants.cloudNoticesURL)
    
    func fetchDataFromURLAsync<T: Codable>() async throws -> T {
        fetchCallCount += 1
        
        // Проверяем тип T
        if T.self == [CodablePost].self {
            return mockPosts as! T
        }

        // Если другой тип, выбрасываем ошибку
        throw NSError(
            domain: "MockError",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Unsupported type \(T.self)"]
        )
        
        // Или делегируем реальному сервису
        // return try await realService.fetchDataFromURLAsync()
    }
}
