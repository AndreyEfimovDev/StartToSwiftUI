//
//  ErrorManager.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 13.03.2026.
//

import Foundation

/// Ошибка в том виде, в каком её видит пользователь.
struct DisplayableError: Equatable {
    let title: String
    let message: String
}

@MainActor
final class ErrorManager: ObservableObject {

    /// Ошибка, показанная пользователю сейчас; `nil` — алерта нет.
    @Published private(set) var current: DisplayableError?

    /// Ошибки, пришедшие, пока уже показывается алерт с предыдущей. Без
    /// очереди второй почти одновременный handle() (например, PostsViewModel
    /// и NoticesViewModel упали с ошибкой сети параллельно) молча перезаписал
    /// бы текст первого раньше, чем пользователь успел его увидеть.
    private var queue: [DisplayableError] = []

    /// Показывает ошибку пользователю (или ставит в очередь, если алерт уже на экране).
    ///
    /// - Parameters:
    ///   - error: Исходная ошибка. Если есть — `message` становится заголовком
    ///     (контекст: что не удалось), а текстом — понятное описание ошибки.
    ///   - message: Контекст операции или, без `error`, сам текст для пользователя.
    func handle(_ error: Error? = nil, message: String) {
        let displayable: DisplayableError
        if let error {
            log("\(message): \(error.localizedDescription)", level: .error)
            displayable = DisplayableError(title: message, message: Self.userMessage(for: error))
        } else {
            log("\(message)", level: .error)
            displayable = DisplayableError(title: "Error", message: message)
        }
        enqueue(displayable)
    }

    /// Закрывает текущий алерт — как если бы его закрыл пользователь — и
    /// показывает следующую ошибку из очереди, если она есть.
    ///
    /// Не для "сброса ошибок перед операцией": так закрывался бы алерт,
    /// который пользователь ещё не прочитал. Операции сообщают свой
    /// результат сами, а не через состояние `current`.
    func dismissCurrent() {
        current = queue.isEmpty ? nil : queue.removeFirst()
    }

    // MARK: - User-facing text

    /// Понятный пользователю текст ошибки.
    ///
    /// Известные причины получают текст с подсказкой, что делать; остальные —
    /// системное описание ошибки.
    ///
    /// - Parameter error: Исходная ошибка.
    /// - Returns: Текст для алерта.
    nonisolated static func userMessage(for error: Error) -> String {
        if isOutOfSpace(error) {
            return "Not enough storage on the device. Free up some space and try again."
        }
        return error.localizedDescription
    }

    /// Нехватка места на устройстве — в самой ошибке или во вложенной
    /// (`NSUnderlyingErrorKey`): SwiftData может завернуть исходную ошибку
    /// SQLite или файловой системы в свою.
    private nonisolated static func isOutOfSpace(_ error: Error) -> Bool {
        let nsError = error as NSError
        // Cocoa: запись файла не удалась — закончилось место.
        if nsError.domain == NSCocoaErrorDomain && nsError.code == NSFileWriteOutOfSpaceError {
            return true
        }
        // SQLite: SQLITE_FULL (13) — база не может вырасти, диск заполнен.
        if nsError.domain == "NSSQLiteErrorDomain" && nsError.code == 13 {
            return true
        }
        if let underlying = nsError.userInfo[NSUnderlyingErrorKey] as? Error {
            return isOutOfSpace(underlying)
        }
        return false
    }

    // MARK: - Queue

    /// Ставит ошибку в очередь на показ, дедуплицируя по заголовку и тексту:
    /// если такая же ошибка уже показывается или уже ждёт в очереди —
    /// не добавляем повторно.
    private func enqueue(_ error: DisplayableError) {
        guard current != error, !queue.contains(error) else { return }

        if current == nil {
            current = error
        } else {
            queue.append(error)
        }
    }
}
