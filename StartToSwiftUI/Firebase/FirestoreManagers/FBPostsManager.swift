//
//  FBPostsManager.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 21.02.2026.
//

import Foundation
import FirebaseFirestore


enum FBFetchError: Error {
    case networkUnavailable
    case unknown(Error)
}

// MARK: - Firestore Manager
final class FBPostsManager: FBPostsManagerProtocol {
    
    init() {}
    
    private let postsCollection: CollectionReference = Firestore.firestore().collection("posts")

    func fetchFBPosts(after date: Date?) async -> Result<[FBPostModel], FBFetchError> {
        do {
            let query: Query
            if let date {
                query = postsCollection.whereField("date", isGreaterThan: Timestamp(date: date))
            } else {
                query = postsCollection // return all Firebase posts if date = nil
            }

            let snapshot = try await query.getDocuments()
            let decoded = snapshot.documents.map { ($0.documentID, FBPostModel(document: $0)) }
            let posts = decoded.compactMap { $0.1 }
            let droppedIDs = decoded.filter { $0.1 == nil }.map { $0.0 }
            if !droppedIDs.isEmpty {
                log("⚠️ Firebase: \(droppedIDs.count) post document(s) failed to decode: \(droppedIDs)", level: .error)
            }
            log("🔥 Firebase: received \(posts.count) posts", level: .info)
            return .success(posts)
        } catch {
            return .failure(Self.fetchError(from: error))
        }
    }

    func hasFBPosts(after date: Date) async -> Result<Bool, FBFetchError> {
        do {
            // Firestore тарифицирует чтения по числу возвращённых документов
            // (пустой ответ — одно чтение). Для ответа "да/нет" хватает
            // одного документа: без limit проверка скачивала бы все новые
            // посты целиком, и импорт после неё — ещё раз.
            //
            // Документ не декодируется: битый (недозаполненный) документ тоже
            // считается "обновлением". Иначе, если он оказался первым, новые
            // валидные посты за ним остались бы незамеченными. Цена — кнопка
            // обновления может показываться, пока битый документ не исправят
            // (см. комментарий о дате синка в PostsViewModel+FBImport).
            let snapshot = try await postsCollection
                .whereField("date", isGreaterThan: Timestamp(date: date))
                .limit(to: 1)
                .getDocuments()
            let hasPosts = !snapshot.documents.isEmpty
            log("🔍 Firebase: new posts available: \(hasPosts)", level: .info)
            return .success(hasPosts)
        } catch {
            return .failure(Self.fetchError(from: error))
        }
    }

    // MARK: - Private

    /// Переводит ошибку Firestore в `FBFetchError` и логирует её.
    ///
    /// Общая для всех запросов менеджера, чтобы отличие "нет сети" от прочих
    /// сбоев определялось в одном месте.
    private static func fetchError(from error: Error) -> FBFetchError {
        let nsError = error as NSError
        // Firestore offline error code = 14 (unavailable)
        if nsError.domain == FirestoreErrorDomain,
           nsError.code == FirestoreErrorCode.unavailable.rawValue {
            log("📵 Firebase: network unavailable", level: .warning)
            return .networkUnavailable
        }
        log("Firebase: error: \(nsError.localizedDescription)", level: .error)
        return .unknown(error)
    }
}

// MARK: - Firestore Posts Manager Protocol
protocol FBPostsManagerProtocol {
    func fetchFBPosts(after: Date?) async -> Result<[FBPostModel], FBFetchError>
    /// Есть ли в Firestore посты новее `date`. Дешёвая проверка для кнопки
    /// обновления: читает не больше одного документа, в отличие от
    /// `fetchFBPosts(after:)`, который скачивает все новые посты.
    func hasFBPosts(after date: Date) async -> Result<Bool, FBFetchError>
}
