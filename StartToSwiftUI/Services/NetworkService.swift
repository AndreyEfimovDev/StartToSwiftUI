//
//  NetworkService.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.10.2025.
//

import Foundation

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

// MARK: - Protocol
protocol NetworkServiceProtocol {
    func fetchDataFromURLAsync<T: Codable>() async throws -> T
}

extension NetworkService: NetworkServiceProtocol {}

// MARK: - Network Errors
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponseStatus
    case dataTaskError(String)
    case corruptData
    case decodingError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("The endpoint URL is invalid", comment: "")
        case .invalidResponseStatus:
            return NSLocalizedString("The APIO failed to issue a valid response.", comment: "")
        case .dataTaskError(let string):
            return string
        case .corruptData:
            return NSLocalizedString("The data provided appears to be corrupt", comment: "")
        case .decodingError(let string):
            return string
        }
    }
}


