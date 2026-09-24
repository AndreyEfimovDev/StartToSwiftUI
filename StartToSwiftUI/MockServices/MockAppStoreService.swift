//
//  MockAppStoreService.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 24.09.2026.
//

import Foundation

/// Мок для #Preview — не ходит в iTunes, отдаёт заданный ответ после
/// короткой паузы, чтобы в превью был виден индикатор проверки.
final class MockAppStoreService: AppStoreServiceProtocol {
    private let result: Bool?

    /// - Parameter result: что вернёт проверка: `true` — есть обновление,
    ///   `false` — актуальная версия, `nil` — проверить не удалось.
    init(result: Bool? = false) {
        self.result = result
    }

    func isUpdateAvailable() async -> Bool? {
        try? await Task.sleep(for: .seconds(1))
        return result
    }
}
