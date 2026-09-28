//
//  NetworkMonitor.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 28.09.2026.
//

import Foundation
import Network

/// Есть ли у устройства сетевое подключение — только то, что нужно
/// менеджерам запросов, чтобы не ждать таймаута без сети.
protocol NetworkMonitoring {
    var isConnected: Bool { get }
}

/// Следит за сетевым подключением через `NWPathMonitor`.
///
/// Создаётся один раз в composition root (`AppDependencies`).
/// `isConnected == true` не гарантирует доступ в интернет (например, Wi-Fi
/// без выхода в сеть) — это лишь быстрый отказ, когда сети нет совсем.
final class NetworkMonitor: NetworkMonitoring {

    /// До первого ответа монитора считаем, что сеть есть: лучше попробовать
    /// запрос, чем зря отказать.
    private(set) var isConnected = true

    private let monitor = NWPathMonitor()

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        // Обновления на главной очереди: isConnected читается с главного
        // потока, так что синхронизация не нужна.
        monitor.start(queue: .main)
    }

    deinit {
        monitor.cancel()
    }
}
