//
//  RemoteConfigService.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.09.2026.
//

import FirebaseRemoteConfig
import SwiftUI

/// Ключи значений, которые можно менять удалённо без релиза приложения
/// (например ссылки на внешние сервисы для доната).
enum RemoteConfigKey: String {
    case russianSupportURL = "support_russian_url"
    case foreignSupportURL = "support_foreign_url"
}

protocol RemoteConfigServiceProtocol {
    /// Подтягивает актуальные значения с сервера. До первого успешного
    /// вызова (и при любой ошибке сети) `string(forKey:default:)` отдаёт
    /// значение по умолчанию, переданное вызывающей стороной.
    func activate() async
    func string(forKey key: RemoteConfigKey, default defaultValue: String) -> String
}

final class RemoteConfigService: RemoteConfigServiceProtocol {
    private let remoteConfig = RemoteConfig.remoteConfig()

    init() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 3600
        remoteConfig.configSettings = settings
    }

    func activate() async {
        do {
            _ = try await remoteConfig.fetchAndActivate()
        } catch {
            log("RemoteConfigService: \(error.localizedDescription)", level: .error)
        }
    }

    func string(forKey key: RemoteConfigKey, default defaultValue: String) -> String {
        let value = remoteConfig[key.rawValue].stringValue
        return value.isEmpty ? defaultValue : value
    }
}

// MARK: - Environment
// Дефолт — мок, а не реальный сервис: RemoteConfig.remoteConfig() требует
// сконфигурированного FirebaseApp, которого в изолированном #Preview может
// не быть. Реальный инстанс всегда явно задан через
// .environment(\.remoteConfigService, ...) в StartView.
extension EnvironmentValues {
    @Entry var remoteConfigService: RemoteConfigServiceProtocol = MockRemoteConfigService()
}
