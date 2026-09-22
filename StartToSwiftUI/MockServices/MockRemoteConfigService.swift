//
//  MockRemoteConfigService.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.09.2026.
//

import Foundation

/// Мок для #Preview и тестов — не обращается к Firebase, всегда
/// возвращает переданное значение по умолчанию.
final class MockRemoteConfigService: RemoteConfigServiceProtocol {
    func activate() async {}

    func string(forKey key: RemoteConfigKey, default defaultValue: String) -> String {
        defaultValue
    }
}
