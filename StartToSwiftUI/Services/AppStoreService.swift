//
//  AppStoreService.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 06.03.2026.
//

import Foundation
import SwiftUI

protocol AppStoreServiceProtocol {
    /// Проверяет, есть ли в App Store версия новее установленной.
    ///
    /// - Returns: `true` / `false` — есть ли обновление; `nil` — проверить не
    ///   удалось (нет сети, ошибка ответа, версия не найдена в ответе).
    func isUpdateAvailable() async -> Bool?
}

final class AppStoreService: AppStoreServiceProtocol {

    init() {}

    // MARK: - iTunes Response Models
    private struct ITunesResponse: Decodable {
        let results: [ITunesResult]
    }
    
    private struct ITunesResult: Decodable {
        let version: String
    }
    
    // MARK: - Public Methods

    /// Проверяет, есть ли в App Store версия новее установленной.
    ///
    /// - Returns: `true` / `false` — есть ли обновление; `nil` — проверить не
    ///   удалось (нет сети, ошибка ответа, версия не найдена в ответе).
    ///   Отличать `nil` от `false` важно: иначе без сети пользователь увидел
    ///   бы "The App is up to date".
    func isUpdateAvailable() async -> Bool? {
        guard let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(Constants.bundleID)") else {
            return nil
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let json = try JSONDecoder().decode(ITunesResponse.self, from: data)

            guard let appStoreVersion = json.results.first?.version else {
                log("⚠️ AppStoreService: No version found in response", level: .info)
                return nil
            }

            let currentVersion = Bundle.main.version
            let hasUpdate = Self.isNewerVersion(appStoreVersion, than: currentVersion)

            log("🔍 AppStoreService: App Store \(appStoreVersion), Current \(currentVersion), hasUpdate: \(hasUpdate)", level: .info)
            return hasUpdate

        } catch {
            log("❌ AppStoreService: \(error.localizedDescription)", level: .error)
            return nil
        }
    }

    /// Сравнивает две строки версий по-семантически (компонент за компонентом
    /// как числа), а не лексикографически — обычное сравнение String ломается
    /// на многозначных компонентах ("10.0" < "9.0" посимвольно).
    static func isNewerVersion(_ version: String, than otherVersion: String) -> Bool {
        version.compare(otherVersion, options: .numeric) == .orderedDescending
    }
}

// MARK: - Environment
// AppStoreService нужен только AboutApp — глубоко вложенному экрану без
// естественного родителя рядом (в отличие от остальных сервисов из
// AppServiceDependencies, которые есть у Posts/Notices/SnippetsViewModel,
// у AboutApp нет доступа ни к одной ViewModel). Поэтому — Environment, а
// не пиггибэк через уже существующую ViewModel. Дефолт ниже — мок для
// #Preview (без запросов в сеть), в реальном приложении всегда явно задан
// через .environment(\.appStoreService, ...) в StartView.
extension EnvironmentValues {
    @Entry var appStoreService: AppStoreServiceProtocol = MockAppStoreService()
}
