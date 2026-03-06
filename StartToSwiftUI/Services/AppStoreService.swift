//
//  AppStoreService.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 06.03.2026.
//

import Foundation

final class AppStoreService {
    
    static let shared = AppStoreService()
    private init() {}
    
    // MARK: - iTunes Response Models
    private struct ITunesResponse: Decodable {
        let results: [ITunesResult]
    }
    
    private struct ITunesResult: Decodable {
        let version: String
    }
    
    // MARK: - Public Methods
    
    /// Returns true if a newer version is available on the App Store
    func isUpdateAvailable() async -> Bool {
        guard let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(Constants.bundleID)") else {
            return false
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let json = try JSONDecoder().decode(ITunesResponse.self, from: data)
            
            guard let appStoreVersion = json.results.first?.version else {
                log("⚠️ AppStoreService: No version found in response", level: .info)
                return false
            }
            
            let currentVersion = Bundle.main.version
            let hasUpdate = appStoreVersion > currentVersion
            
            log("🔍 AppStoreService: App Store \(appStoreVersion), Current \(currentVersion), hasUpdate: \(hasUpdate)", level: .info)
            return hasUpdate
            
        } catch {
            log("❌ AppStoreService: \(error.localizedDescription)", level: .error)
            return false
        }
    }
}
