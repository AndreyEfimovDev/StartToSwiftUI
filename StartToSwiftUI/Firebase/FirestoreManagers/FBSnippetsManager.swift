//
//  FBSnippetsManager.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.03.2026.
//

import Foundation
import FirebaseFirestore

final class FBSnippetsManager: FBSnippetsManagerProtocol {

    init() {}
    
    private let snippetsCollection: CollectionReference = Firestore.firestore().collection("snippets")

    func fetchFBSnippets(after date: Date?) async -> [FBSnippetModel] {
        do {
            let query: Query
            if let date {
                query = snippetsCollection.whereField("date", isGreaterThan: Timestamp(date: date))
            } else {
                query = snippetsCollection // return all Firebase snippets if date = nil
            }

            let snapshot = try await query.getDocuments()
            let snippets = snapshot.documents.compactMap{ FBSnippetModel(document: $0) }
            log("🔥 Firebase: received \(snippets.count) posts", level: .info)
            return snippets
        } catch {
            log("❌ Firebase: getAllPosts_after_date error: \(error.localizedDescription)", level: .error)
            return []
        }
    }

    func uploadDevDataSnippetsToFirebase() async {
        
    }
}

// MARK: - Firestore Snippetsv Manager Protocol
protocol FBSnippetsManagerProtocol {
    func fetchFBSnippets(after: Date?) async -> [FBSnippetModel]
    func uploadDevDataSnippetsToFirebase() async
}

//
//// MARK: - Errors
//
//enum FirestoreSnippetsError: LocalizedError {
//    case decodingFailed(documentID: String, underlying: Error)
//    case unknown(Error)
//
//    var errorDescription: String? {
//        switch self {
//        case .decodingFailed(let id, let err):
//            return "Failed to decode snippet '\(id)': \(err.localizedDescription)"
//        case .unknown(let err):
//            return err.localizedDescription
//        }
//    }
//}
