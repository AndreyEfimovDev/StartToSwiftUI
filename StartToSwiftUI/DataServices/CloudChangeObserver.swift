//
//  CloudChangeObserver.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.09.2026.
//

import Foundation
import Combine
import CoreData

/// Источник событий "хранилище SwiftData изменилось" — только то, что нужно
/// ViewModel'ям для перезагрузки данных.
protocol CloudChangeObserving {
    /// Событие после серии изменений хранилища (с debounce), на главном потоке.
    var changes: AnyPublisher<Void, Never> { get }
}

/// Единственная в приложении подписка на `NSPersistentStoreRemoteChange`.
///
/// Создаётся один раз в composition root (`AppDependencies`) и передаётся
/// во все ViewModel'и — раньше каждая VM держала свою копию подписки,
/// и копии разошлись в поведении.
final class CloudChangeObserver: CloudChangeObserving {

    let changes: AnyPublisher<Void, Never>

    /// - Parameters:
    ///   - notificationCenter: Откуда приходят уведомления хранилища (в тестах — свой).
    ///   - debounceInterval: Пауза, после которой серия уведомлений схлопывается
    ///     в одно событие: импорт из iCloud приходит пачкой уведомлений подряд.
    init(
        notificationCenter: NotificationCenter = .default,
        debounceInterval: DispatchQueue.SchedulerTimeType.Stride = .seconds(2)
    ) {
        changes = notificationCenter
            .publisher(for: .NSPersistentStoreRemoteChange)
            .debounce(for: debounceInterval, scheduler: DispatchQueue.main)
            .map { _ in () }
            // Одна общая цепочка debounce на всех подписчиков, а не своя у каждой VM.
            .share()
            .eraseToAnyPublisher()
    }
}
