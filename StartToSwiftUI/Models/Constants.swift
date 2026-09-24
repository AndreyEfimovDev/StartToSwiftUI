//
//  Constants.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 23.10.2025.
//

import Foundation


// nonisolated: чистые константы без связи с UI/main thread, не должны
// наследовать MainActor-изоляцию по умолчанию (SWIFT_DEFAULT_ACTOR_ISOLATION)
nonisolated struct Constants {
    static let mainCategory = "SwiftUI"
    static let urlStart = "https://"
    static let appStoreURL = "https://apps.apple.com/ru/app/starttoswiftui/id6755787606?l=en-GB"
    static let bundleID = "PELSH.StartToSwiftUI"
    static let dispatchFor: Double = 2.5 // for async methods
    /// Пауза перед автозакрытием экрана после успешной операции — чтобы
    /// пользователь успел увидеть результат на кнопке (см. `autoDismiss`).
    static let autoDismissDelay: Duration = .seconds(2.5)
}
