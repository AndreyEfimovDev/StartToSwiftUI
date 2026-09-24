//
//  DebugConfig.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 24.09.2026.
//

import Foundation

/// Выбор между реальными внешними сервисами и локальными заменами.
///
/// Под флагом: Firestore (чтение постов и notices — иначе моки на
/// `PreviewData`), CloudKit-синхронизация SwiftData и регистрация пушей/FCM.
/// Analytics и Crashlytics флаг не затрагивает — в DEBUG они выключены
/// всегда, чтобы тестовые данные не попадали в прод-статистику.
///
/// Для проверки debug-сборки на реальных данных: поменять `false` → `true`,
/// пересобрать и переустановить приложение (значение вшивается при сборке,
/// поэтому работает и при запуске с домашнего экрана без Xcode). Даже с
/// `true` debug-сборка ходит в Development-окружение CloudKit, а не в
/// Production.
///
/// Release всегда использует реальные сервисы — случайно закоммиченный
/// `true` на него не влияет.
enum DebugConfig {
    #if DEBUG
    static let useRealServices = false
    #else
    static let useRealServices = true
    #endif
}
