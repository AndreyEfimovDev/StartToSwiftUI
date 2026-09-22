//
//  SupportOption.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.09.2026.
//

import Foundation

/// Один способ поддержать разработчика донатом — открывает внешнюю
/// платёжную страницу в Safari, платёж внутри приложения не обрабатывается.
struct SupportOption: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let urlString: String
}

extension SupportOption {
    // Ссылки берутся из Firebase Remote Config (с локальным fallback-значением
    // на случай оффлайна/первого запуска) — это даёт возможность сменить
    // платёжный сервис без релиза приложения.
    // TODO: заменить плейсхолдер-ссылку/fallback для иностранной карты на
    // реальную после выбора сервиса (см. обсуждение фичи "Buy Me a Coffee").
    static func all(remoteConfig: RemoteConfigServiceProtocol) -> [SupportOption] {
        [
            SupportOption(
                id: "ru",
                title: "RU card / SBP",
                subtitle: "CloudTips",
                icon: "creditcard",
                urlString: remoteConfig.string(
                    forKey: .russianURL,
                    default: Secrets.cloudTipsURL
                )
            ),
            SupportOption(
                id: "foreign",
                title: "Foreign card",
                subtitle: "Coming soon",
                icon: "globe",
                urlString: remoteConfig.string(
                    forKey: .foreignSupportURL,
                    default: "https://example.com/support-foreign-placeholder"
                )
            )
        ]
    }
}
