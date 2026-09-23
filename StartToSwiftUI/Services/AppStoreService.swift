//
//  AppStoreService.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 06.03.2026.
//

import Foundation
import SwiftUI

final class AppStoreService {

    init() {}

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
            // Обычное сравнение String ломается на многозначных компонентах
            // версии ("10.0" < "9.0" лексикографически) — .numeric сравнивает
            // цифровые последовательности как числа, а не посимвольно.
            let hasUpdate = appStoreVersion.compare(currentVersion, options: .numeric) == .orderedDescending
            
            log("🔍 AppStoreService: App Store \(appStoreVersion), Current \(currentVersion), hasUpdate: \(hasUpdate)", level: .info)
            return hasUpdate
            
        } catch {
            log("❌ AppStoreService: \(error.localizedDescription)", level: .error)
            return false
        }
    }
}

// MARK: - Environment
// AppStoreService нужен только AboutApp — глубоко вложенному экрану без
// естественного родителя рядом (в отличие от остальных сервисов из
// AppServiceDependencies, которые есть у Posts/Notices/SnippetsViewModel,
// у AboutApp нет доступа ни к одной ViewModel). Поэтому — Environment, а
// не пиггибэк через уже существующую ViewModel. Дефолт ниже — только для
// #Preview, в реальном приложении всегда явно задан через
// .environment(\.appStoreService, ...) в StartView.
extension EnvironmentValues {
    @Entry var appStoreService = AppStoreService()
}
