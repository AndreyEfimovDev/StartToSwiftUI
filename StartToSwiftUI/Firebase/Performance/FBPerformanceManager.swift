//
//  FBPerformanceManager.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.02.2026.
//

import SwiftUI
import FirebasePerformance

/// Хэндл на конкретный запущенный трейс. Вызывающий код хранит его в локальной
/// переменной и передаёт обратно в `setValue`/`stopTrace` — благодаря этому
/// два трейса с одинаковым `name`, запущенные параллельно (например, при
/// повторном/конкурентном вызове одной и той же операции), никогда не
/// перепутаются и не потеряют друг друга, в отличие от хранения по имени
/// в общем словаре.
struct PerformanceTrace {
    // Optional — Performance.startTrace(name:) может вернуть nil (например,
    // если Performance Monitoring ещё не готов); в этом случае setValue/
    // stopTrace просто ничего не делают, как и в прежней реализации.
    fileprivate let trace: Trace?
}

final class FBPerformanceManager {

    static let shared = FBPerformanceManager()
    private init() { }

    func startTrace(name: String) -> PerformanceTrace {
        PerformanceTrace(trace: Performance.startTrace(name: name))
    }

    func setValue(_ handle: PerformanceTrace, value: String, forAttribute attribute: String) {
        handle.trace?.setValue(value, forAttribute: attribute)
    }

    func stopTrace(_ handle: PerformanceTrace) {
        handle.trace?.stop()
    }
}

