//
//  SnippetViewRegistry.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.03.2026.
//
//  Place in Views/Snippets/
//
//  HOW TO ADD A NEW SNIPPET DEMO:
//  1. Create a new DemoView in Views/Snippets/Demos/
//  2. Add a case for the snippet's id below
//  3. Upload the snippet to Firestore with the matching id

import SwiftUI

struct SnippetViewRegistry {

    @ViewBuilder
    static func view(for snippet: CodeSnippet) -> some View {
        switch snippet.id {
        case "snippet_001": CardModifierDemoView(snippet: snippet)
        case "snippet_002": AsyncImageDemoView(snippet: snippet)
        case "snippet_003": DebouncedSearchDemoView(snippet: snippet)
        default:            SnippetNoPreviewView(snippet: snippet)
        }
    }
}
