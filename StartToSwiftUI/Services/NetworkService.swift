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

extension NetworkService: NetworkServiceProtocol {}


// MARK: - NetworkService
final class NetworkService: ObservableObject {
    
    let urlString: String
    
    init(urlString: String) {
        self.urlString = urlString
    }
    
    func fetchDataFromURLAsync<T: Codable>() async throws -> T {
        
        guard
            let url = URL(string: urlString)
        else {
            throw NetworkError.invalidURL
        }
        
        do {
            let (jsonData, response) = try await URLSession.shared.data(from: url)
            
            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode >= 200 && httpResponse.statusCode < 300
            else {
                throw NetworkError.invalidResponseStatus
            }
            
            do {
                let decodedData = try JSONDecoder.appDecoder.decode(T.self, from: jsonData)
                return decodedData
            } catch {
                throw NetworkError.decodingError(error.localizedDescription)
            }
        } catch {
            throw NetworkError.dataTaskError(error.localizedDescription)
        }
    }
}

