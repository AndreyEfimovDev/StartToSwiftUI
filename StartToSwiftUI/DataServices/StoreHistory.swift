//
//  StoreHistory.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.09.2026.
//

import Foundation
import SwiftData

// MARK: - Store Entity

/// Сущности хранилища, на изменения которых реагируют ViewModel'и.
enum StoreEntity: CaseIterable {
    case post
    case notice
    case appSyncState

    /// - Parameter entityName: Имя сущности из истории SwiftData (совпадает с именем класса модели).
    ///
    /// `nonisolated` — чистое сопоставление без состояния; иначе (изоляция
    /// по умолчанию — MainActor) его нельзя передать ссылкой в `compactMap`.
    nonisolated init?(entityName: String) {
        switch entityName {
        case String(describing: Post.self): self = .post
        case String(describing: Notice.self): self = .notice
        case String(describing: AppSyncState.self): self = .appSyncState
        default: return nil
        }
    }
}

// MARK: - Store Transaction

/// Транзакция истории хранилища — только то, что нужно для фильтра:
/// кто записал и какие сущности затронуты.
struct StoreTransaction {
    let author: String?
    let entityNames: Set<String>

    /// Сущности, изменённые чужими транзакциями (импорт из iCloud и т. п.).
    ///
    /// Свои транзакции (с автором `ownAuthor`) отбрасываются: после своего
    /// сохранения данные в памяти и так актуальны, перезагрузка не нужна.
    /// Транзакция без автора считается чужой.
    ///
    /// - Parameters:
    ///   - transactions: Новые транзакции истории.
    ///   - ownAuthor: Автор, которым помечены сохранения приложения.
    /// - Returns: Изменённые сущности; неизвестные имена отбрасываются.
    static func externalEntities(in transactions: [StoreTransaction], ownAuthor: String) -> Set<StoreEntity> {
        Set(
            transactions
                .filter { $0.author != ownAuthor }
                .flatMap(\.entityNames)
                .compactMap(StoreEntity.init(entityName:))
        )
    }
}

// MARK: - History Reading

/// Читает новые изменения хранилища, сделанные не этим приложением.
protocol StoreHistoryReading {
    /// Изменённые сущности из транзакций, появившихся после предыдущего вызова,
    /// без собственных транзакций приложения.
    func fetchExternalChanges() -> Set<StoreEntity>
}

/// Чтение истории SwiftData (iOS 18+).
///
/// История локальна для устройства: изменения с другого устройства приходят
/// сюда транзакцией импорта CloudKit со своим автором, а не с `appAuthor`.
final class SwiftDataHistoryReader: StoreHistoryReading {

    /// Автор, которым помечаются все сохранения приложения
    /// (задаётся у `ModelContext` в composition root).
    static let appAuthor = "app"

    private let modelContext: ModelContext
    /// С какого момента читать историю, пока нет токена: вся история
    /// за всё время не нужна — при запуске данные и так загружаются целиком.
    private let startDate: Date
    /// Токен последней обработанной транзакции.
    private var lastToken: DefaultHistoryToken?

    /// - Parameters:
    ///   - modelContext: Контекст, из которого читается история.
    ///   - startDate: Начало чтения до появления первого токена.
    init(modelContext: ModelContext, startDate: Date = Date()) {
        self.modelContext = modelContext
        self.startDate = startDate
    }

    func fetchExternalChanges() -> Set<StoreEntity> {
        var descriptor = HistoryDescriptor<DefaultHistoryTransaction>()
        if let lastToken {
            descriptor.predicate = #Predicate { $0.token > lastToken }
        } else {
            let startDate = self.startDate
            descriptor.predicate = #Predicate { $0.timestamp > startDate }
        }

        do {
            let transactions = try modelContext.fetchHistory(descriptor)
            if let newestToken = transactions.map(\.token).max() {
                lastToken = newestToken
            }

            let storeTransactions = transactions.map { transaction in
                StoreTransaction(
                    author: transaction.author,
                    entityNames: Set(transaction.changes.compactMap(Self.entityName(of:)))
                )
            }
            logTransactions(storeTransactions)
            return StoreTransaction.externalEntities(in: storeTransactions, ownAuthor: Self.appAuthor)
        } catch {
            // Без истории нельзя отличить своё изменение от чужого — считаем,
            // что изменилось всё: лишняя перезагрузка лучше пропущенного
            // изменения из iCloud. Токен сбрасываем: если он стал
            // недействительным, следующее чтение начнётся заново со startDate.
            log("❌ Store history: \(error.localizedDescription)", level: .error)
            lastToken = nil
            return Set(StoreEntity.allCases)
        }
    }

    /// Имя сущности, затронутой изменением.
    ///
    /// `nonisolated` — по той же причине, что `StoreEntity.init(entityName:)`.
    private nonisolated static func entityName(of change: HistoryChange) -> String? {
        switch change {
        case .insert(let insert): insert.changedPersistentIdentifier.entityName
        case .update(let update): update.changedPersistentIdentifier.entityName
        case .delete(let delete): delete.changedPersistentIdentifier.entityName
        @unknown default: nil
        }
    }

    /// Пишет в лог авторов своих и чужих транзакций — по нему на втором
    /// устройстве видно, с каким автором приходит импорт из iCloud.
    private func logTransactions(_ transactions: [StoreTransaction]) {
        guard !transactions.isEmpty else { return }
        let own = transactions.filter { $0.author == Self.appAuthor }
        let externalAuthors = transactions
            .filter { $0.author != Self.appAuthor }
            .map { $0.author ?? "nil" }
        log("🗂️ Store history: skipped \(own.count) own transaction(s), external authors: \(externalAuthors)", level: .info)
    }
}
