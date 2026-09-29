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
                title: "Buy Me a Coffee",
                subtitle: "Card payment",
                icon: "creditcard",
                urlString: remoteConfig.string(
                    forKey: .foreignSupportURL,
                    default: Secrets.buyMeACoffeeURL
                )
            )
            // Скрыто, пока экран показывается только в витрине App Store США
            // (см. SupportAvailability): российская карта там не нужна. Ключ
            // Remote Config и Secrets.cloudTipsURL оставлены, чтобы вернуть.
//            SupportOption(
//                id: "ru",
//                title: "RU card / SBP",
//                subtitle: "CloudTips",
//                icon: "creditcard",
//                urlString: remoteConfig.string(
//                    forKey: .russianSupportURL,
//                    default: Secrets.cloudTipsURL
//                )
//            )
        ]
    }
}
