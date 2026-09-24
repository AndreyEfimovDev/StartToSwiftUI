//
//  FBAdminUploader.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 24.09.2026.
//

#if DEBUG
import Foundation
import FirebaseFirestore

/// Админ-инструмент: загрузка новых постов из `DevData.postsForCloud` в
/// реальный Firestore — вместо отдельной админ-панели. Вызывается из
/// DEBUG-кнопки в `PreferencesView` и вырезается перед релизом.
///
/// Намеренно отделён от `FBPostsManagerProtocol`: тот отвечает только за
/// чтение и в DEBUG подменяется моком, а загрузка всегда должна идти в
/// настоящий Firestore. `enum` со `static`-методом, без инстанса и инъекции
/// через composition root: состояния у загрузчика нет (коллекция берётся
/// внутри вызова), а временный инструмент не должен тянуть за собой
/// изменения в AppDependencies, которые потом тоже вырезать.
///
/// Весь файл под `#if DEBUG` — в Release код не попадёт, даже если его
/// забудут удалить.
enum FBAdminUploader {

    /// Загружает все посты из `DevData.postsForCloud` в коллекцию `posts`.
    ///
    /// id документа строится как `yyyyMMdd_<хвост UUID>` — дата в префиксе
    /// упорядочивает документы в консоли Firestore. Ошибка на отдельном
    /// посте логируется и не прерывает загрузку остальных.
    static func uploadDevDataPosts() async {
        let postsCollection = Firestore.firestore().collection("posts")
        var successCount = 0

        for post in DevData.postsForCloud {
            let datePrefix = DateFormatter.yyyyMMdd.string(from: post.date)
            let trimmedUUID = String(post.id.suffix(from: post.id.index(post.id.startIndex, offsetBy: 11)))
            post.id = "\(datePrefix)_\(trimmedUUID)"

            let data: [String: Any] = [
                "category": post.category,
                "title": post.title,
                "intro": post.intro,
                "author": post.author,
                "post_type": post.postType.rawValue,
                "url_string": post.urlString,
                "post_platform": post.postPlatform.rawValue,
                "post_date": Timestamp(date: post.postDate ?? Date()),
                "study_level": post.studyLevel.rawValue,
                // Момент публикации в приложении — время сервера Firestore
                // при записи. Курсор синка клиентов (date > последней
                // полученной) корректен, только если каждая новая загрузка
                // получает date строго позже предыдущих; дата "по дню"
                // давала одинаковые значения, и вторую загрузку за день
                // клиенты не получали.
                "date": FieldValue.serverTimestamp()
            ]

            do {
                try await postsCollection.document(post.id).setData(data)
                successCount += 1
                log("Migrated: \(post.title)", level: .info)
            } catch {
                log("Failed: \(post.title) — \(error.localizedDescription)", level: .error)
            }
        }
        log("🏁 uploadDevDataPosts complete: \(successCount)/\(DevData.postsForCloud.count) posts", level: .info)
    }
}
#endif
