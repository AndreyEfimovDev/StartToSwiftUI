//
//  NetworkService.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.10.2025.
//

import Foundation

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
// MARK: - Protocol
protocol NetworkServiceProtocol {
    func fetchDataFromURLAsync<T: Codable>() async throws -> T
}


extension NetworkService: NetworkServiceProtocol {}

//extension NetworkService {
//    // Переопределяем метод только для тестов
//    func mock_fetchDataFromURLAsync<T: Codable>(_ mockData: T) async throws -> T {
//        return mockData
//    }
//}

