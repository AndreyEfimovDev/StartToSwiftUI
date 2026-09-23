//
//  SupportOption.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.09.2026.
//

import Foundation

/// Один способ поддержать разработчика — открывает внешнюю
/// страницу в Safari, внутри приложения не обрабатывать.
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
    // сервис без релиза приложения.
    static func all(remoteConfig: RemoteConfigServiceProtocol) -> [SupportOption] {
        [
            SupportOption(
                id: "foreign",
                title: "Foreign card",
                subtitle: "Buy Me a Coffee",
                icon: "globe",
                urlString: remoteConfig.string(
                    forKey: .foreignSupportURL,
                    default: Secrets.buyMeACoffeeURL
                )
            ),
            SupportOption(
                id: "ru",
                title: "RU card / SBP",
                subtitle: "CloudTips",
                icon: "creditcard",
                urlString: remoteConfig.string(
                    forKey: .russianSupportURL,
                    default: Secrets.cloudTipsURL
                )
            )
        ]
    }
}
