//
//  NetworkService.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.10.2025.
//

import Foundation

// MARK: - Protocol
protocol NetworkServiceProtocol {
    func fetchDataFromURLAsync<T: Codable>() async throws -> T
}

// MARK: - Real Implementation
final class NetworkService: ObservableObject {
    
    let baseURL: String
    
    init(baseURL: String) {
        self.baseURL = baseURL
    }
    
    func fetchDataFromURLAsync<T: Codable>() async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            fetchDataFromURL { (result: Result<T, Error>) in
                continuation.resume(with: result)
            }
        }
    }
    
    func fetchDataFromURL<T: Codable>(
        decoder: JSONDecoder = .appDecoder, //ISO8601 (string) encoding strategy
        completion: @escaping (Result<T, Error>) -> Void
    ) {
               
        guard let url = URL(string: baseURL) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.invalidResponse))
                }
                return
            }
            
            guard let jsonData = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData))
                }
                return
            }
            
            do {
                let decodedData = try JSONDecoder.appDecoder.decode(T.self, from: jsonData)
                DispatchQueue.main.async {
                    completion(.success(decodedData))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}

extension NetworkService: NetworkServiceProtocol {}

extension NetworkService {
    // Переопределяем метод только для тестов
    func mock_fetchDataFromURLAsync<T: Codable>(_ mockData: T) async throws -> T {
        return mockData
    }
}

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
        
        // Симулируем задержку сети
        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        // Симулируем ошибку
        if shouldFail {
            throw NetworkError.invalidResponse
        }
        
        // Возвращаем mock данные
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
    
    /// Mock для успешной загрузки постов
    static func mockPosts(_ posts: [CodablePost] = PreviewData.sampleCodablePosts) -> MockNetworkService {
        MockNetworkService(mockData: posts)
    }
    
    /// Mock для успешной загрузки уведомлений
    static func mockNotices(_ notices: [CodableNotice] = PreviewData.sampleCodableNotices) -> MockNetworkService {
        MockNetworkService(mockData: notices)
    }
    
    /// Mock для симуляции ошибки сети
    static func mockError() -> MockNetworkService {
        MockNetworkService(mockData: [], shouldFail: true)
    }
    
    /// Mock с задержкой (для тестирования loading states)
    static func mockWithDelay(_ data: Any, delay: TimeInterval = 2.0) -> MockNetworkService {
        MockNetworkService(mockData: data, delay: delay)
    }
}


class MockPostsNetworkService {
    var mockPosts: [CodablePost] = []
    var fetchCallCount = 0
    
    // Создаем реальный NetworkService, но переопределяем его поведение
//    private let realService = NetworkService(baseURL: "https://mock.com")
    
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

class MockNoticesNetworkService {
    var mockNotices: [CodableNotice] = []
    var fetchCallCount = 0
        
    func fetchDataFromURLAsync<T: Codable>() async throws -> T {
        fetchCallCount += 1
        
        // Проверяем тип T
        if T.self == [CodableNotice].self {
            return mockNotices as! T
        }
        
        // Если  другой тип, выбрасываем ошибку
        throw NSError(
            domain: "MockError",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Unsupported type \(T.self)"]
        )
    }
}
