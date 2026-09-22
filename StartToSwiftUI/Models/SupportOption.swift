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
    // TODO: заменить плейсхолдер-ссылки на реальные после выбора сервисов
    // (RU: CloudTips/ЮMoney; иностранная карта: Freedom Pay/Altyn Wallet или
    // аналог — см. обсуждение фичи "Buy Me a Coffee").
    static let all: [SupportOption] = [
        SupportOption(
            id: "ru",
            title: "RU card / SBP",
            subtitle: "CloudTips",
            icon: "creditcard",
            urlString: "https://example.com/support-ru-placeholder"
        ),
        SupportOption(
            id: "foreign",
            title: "Foreign card",
            subtitle: "Freedom Pay",
            icon: "globe",
            urlString: "https://example.com/support-foreign-placeholder"
        )
    ]
}
