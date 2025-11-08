//
//  NetworkService.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.10.2025.
//

import Foundation

class NetworkService: ObservableObject {
    
    func fetchPostsFromURL<T: Codable>(
        from urlString: String,
        decoder: JSONDecoder = .appDecoder, // we use the data decoding strategy - ISO8601 (string)
        completion: @escaping (Result<T, Error>) -> Void
    ) {
               
        guard let url = URL(string: urlString) else {
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
    
//    func fetchCloudPosts<T: Codable>(
//        from urlString: String,
//        decoder: JSONDecoder = .appDecoder, // we use the data decoding strategy - ISO8601 (string)
//        completion: @escaping (Result<T, Error>) -> Void
//    ) {
//        guard let url = URL(string: urlString) else {
//            completion(.failure(NetworkError.invalidURL))
//            return
//        }
//        
//        let task = URLSession.shared.dataTask(with: url) { data, response, error in
//            if let error = error {
//                DispatchQueue.main.async {
//                    completion(.failure(error))
//                }
//                return
//            }
//            
//            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
//                DispatchQueue.main.async {
//                    completion(.failure(NetworkError.invalidResponse))
//                }
//                return
//            }
//            
//            guard let jsonData = data else {
//                DispatchQueue.main.async {
//                    completion(.failure(NetworkError.noData))
//                }
//                return
//            }
//            
//            do {
//                let decodedData = try decoder.decode(T.self, from: jsonData)
//                DispatchQueue.main.async {
//                    completion(.success(decodedData))
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    completion(.failure(error))
//                }
//            }
//        }
//        
//        task.resume()
//    }

    
    enum NetworkError: LocalizedError {
        case invalidURL
        case invalidResponse
        case noData
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .invalidResponse:
                return "Invalid server response"
            case .noData:
                return "No data received"
            }
        }
    }
}

