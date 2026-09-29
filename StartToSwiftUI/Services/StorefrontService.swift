//
//  StorefrontService.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 29.09.2026.
//

import SwiftUI
import StoreKit

/// Витрина App Store пользователя — только то, что нужно, чтобы решить,
/// показывать ли функции, разрешённые правилами не во всех странах.
protocol StorefrontProviding {
    /// Код страны витрины App Store (ISO 3166-1 alpha-3, например "USA");
    /// `nil`, если витрину узнать не удалось (нет сети, нет аккаунта).
    func currentCountryCode() async -> String?
}

/// Витрина из StoreKit: страна App Store-аккаунта пользователя, а не регион устройства.
final class StorefrontService: StorefrontProviding {
    func currentCountryCode() async -> String? {
        await Storefront.current?.countryCode
    }
}

/// Мок для #Preview — отдаёт заданную витрину без обращения к StoreKit.
final class MockStorefrontService: StorefrontProviding {
    private let countryCode: String?

    /// - Parameter countryCode: Витрина, которую вернёт сервис.
    init(countryCode: String? = "USA") {
        self.countryCode = countryCode
    }

    func currentCountryCode() async -> String? {
        countryCode
    }
}

// MARK: - Support the Developer availability

/// Где можно показывать "Support the Developer".
///
/// Экран ведёт на внешние страницы оплаты (CloudTips, Buy Me a Coffee).
/// App Review Guideline 3.1.1(a) разрешает такие ссылки без In-App Purchase
/// только в витрине США; в остальных витринах экран скрыт.
enum SupportAvailability {

    /// Витрины, где внешние ссылки на оплату разрешены правилами.
    static let allowedStorefronts: Set<String> = ["USA"]

    /// - Parameter countryCode: Код витрины App Store.
    /// - Returns: `true`, если экран можно показывать; при неизвестной витрине —
    ///   `false` (лучше не показать, чем показать там, где нельзя).
    static func isAllowed(countryCode: String?) -> Bool {
        guard let countryCode else { return false }
        return allowedStorefronts.contains(countryCode)
    }
}

// MARK: - Environment
// Дефолт — мок для #Preview; в приложении реальный сервис задаётся через
// .environment(\.storefrontService, ...) в StartView.
extension EnvironmentValues {
    @Entry var storefrontService: StorefrontProviding = MockStorefrontService()
}
