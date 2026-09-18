//
//  ErrorManager.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 13.03.2026.
//

import Foundation

@MainActor
final class ErrorManager: ObservableObject {

    /// Одна ошибка, ожидающая показа в очереди — текст уже посчитан
    /// (error?.localizedDescription ?? message), тем же способом, что раньше
    /// шёл прямо в errorMessage.
    private struct QueuedError {
        let text: String
    }

    @Published var errorMessage: String?
    @Published var showAlert: Bool = false {
        didSet {
            // showAlert может стать false двумя путями: SwiftUI сама
            // выставляет его через двусторонний биндинг isPresented в
            // StartView, когда пользователь закрывает алерт, либо это делает
            // clear(). В обоих случаях, если в очереди есть следующая
            // ошибка — показываем её.
            guard oldValue, !showAlert else { return }
            showNext()
        }
    }

    /// Ошибки, пришедшие, пока уже показывается алерт с предыдущей. Без
    /// очереди второй почти одновременный handle() (например, PostsViewModel
    /// и NoticesViewModel упали с ошибкой сети параллельно) молча перезаписал
    /// бы текст первого раньше, чем пользователь успел его увидеть.
    private var queue: [QueuedError] = []

    func handle(_ error: Error? = nil, message: String) {
        let text = error?.localizedDescription ?? message
        if let error {
            log("\(message): \(error.localizedDescription)", level: .error)
        } else {
            log("\(message)", level: .error)
        }
        enqueue(QueuedError(text: text))
    }

    func clear() {
        errorMessage = nil
        showAlert = false
    }

    /// Ставит ошибку в очередь на показ, дедуплицируя по итоговому тексту:
    /// если такое же сообщение уже показывается или уже ждёт в очереди —
    /// не добавляем повторно.
    private func enqueue(_ entry: QueuedError) {
        /// если алерт сейчас на экране и его текст совпадает с новым, новую запись отбрасываем (не добавляем в очередь повторно то, что и так уже показывается), и
        /// если такой же текст уже лежит в очереди и ждёт показа, второй раз не добавляем
        guard !(showAlert && errorMessage == entry.text),
              !queue.contains(where: { $0.text == entry.text }) else { return }

        if showAlert {
            queue.append(entry)
        } else {
            present(entry)
        }
    }

    private func present(_ entry: QueuedError) {
        errorMessage = entry.text
        showAlert = true
    }

    private func showNext() {
        guard !queue.isEmpty else {
            errorMessage = nil
            return
        }
        present(queue.removeFirst())
    }
}
