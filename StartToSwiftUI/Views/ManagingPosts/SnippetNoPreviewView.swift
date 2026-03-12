//
//  SnippetNoPreviewView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.03.2026.
//
//  Place in Views/Snippets/Demos/
//  Shown when a snippet has no corresponding DemoView in SnippetViewRegistry yet.

import SwiftUI

struct SnippetNoPreviewView: View {

    let snippet: CodeSnippet

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "wrench.and.screwdriver")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.mycolor.myAccent.opacity(0.4))
                    .padding(.top, 60)

                VStack(spacing: 8) {
                    Text("Visual preview coming soon")
                        .font(.headline)
                    Text("Use the </> button to view and copy the code.")
                        .font(.subheadline)
                        .foregroundStyle(Color.mycolor.myAccent.opacity(0.6))
                        .multilineTextAlignment(.center)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text(snippet.title)
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text(snippet.intro)
                        .font(.subheadline)
                        .foregroundStyle(Color.mycolor.myAccent.opacity(0.8))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .cardBackground()

                Spacer()
            }
            .padding(.horizontal)
            .foregroundStyle(Color.mycolor.myAccent)
        }
    }
}

#Preview {
    NavigationStack {
        SnippetNoPreviewView(snippet: SnippetsRepository.a001)
            .environmentObject(AppCoordinator())
    }
}
