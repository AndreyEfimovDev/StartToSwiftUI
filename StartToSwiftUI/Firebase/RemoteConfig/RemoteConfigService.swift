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
    /// Подтягивает актуальные значения с сервера и активирует их. До
    /// активации (и при ошибке сети) `string(forKey:default:)` отдаёт
    /// значения, активированные ранее — они сохраняются на диске между
    /// запусками, — а если их нет (первый запуск), значение по умолчанию,
    /// переданное вызывающей стороной.
    ///
    /// - Returns: `true`, если с сервера получены и активированы свежие
    ///   данные — значит, стоит перечитать значения. `false`, если сработал
    ///   троттлинг (использованы ранее скачанные данные) или произошла ошибка.
    ///   `true` не гарантирует, что значения реально отличаются от прежних.
    func activate() async -> Bool
    func string(forKey key: RemoteConfigKey, default defaultValue: String) -> String
}

final class RemoteConfigService: RemoteConfigServiceProtocol {
    private let remoteConfig = RemoteConfig.remoteConfig()

    init() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 3600
        remoteConfig.configSettings = settings
    }

    func activate() async -> Bool {
        do {
            // В пределах minimumFetchInterval SDK в сеть не ходит и отдаёт
            // .successUsingPreFetchedData — новых данных нет, перечитывать нечего.
            let status = try await remoteConfig.fetchAndActivate()
            return status == .successFetchedFromRemote
        } catch {
            log("RemoteConfigService: \(error.localizedDescription)", level: .error)
            return false
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
