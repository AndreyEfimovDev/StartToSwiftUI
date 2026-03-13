//
//  MockFBSnippetsManager.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.03.2026.
//

import Foundation

// MARK: - Mock Firebase Manager
// Place in DataServices/Mock/ alongside MockFBPostsManager.swift

final class MockFBSnippetsManager: FBSnippetsManagerProtocol {
    var stubbedSnippets: [FBSnippetModel]

    init(snippets: [FBSnippetModel] = []) {
        self.stubbedSnippets = snippets
    }

    func fetchFBSnippets(after date: Date?) async -> [FBSnippetModel] {
        guard let date else { return stubbedSnippets }
        return stubbedSnippets.filter { $0.date > date }
    }

    func uploadDevDataSnippetsToFirebase() async {}
}






