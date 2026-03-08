//
//  SnippetRowView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.03.2026.
//

import SwiftUI

struct SnippetRowView: View {

    let snippet: CodeSnippet

    // MARK: - Computed Properties

    private var subtitleText: String {
        var parts: [String] = []
        parts.append(snippet.date.formatted(date: .numeric, time: .omitted))
        if let thanks = snippet.thanks, !thanks.isEmpty {
            parts.append("@\(thanks)")
        }
        return parts.joined(separator: "  ·  ")
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Group {
                titleRow
                subtitleRow
                bottomRow
            }
            .foregroundStyle(Color.mycolor.myAccent)
        }
        .padding(8)
        .padding(.horizontal, 8)
        .frame(height: 100)
        .background(.black.opacity(0.001))
    }

    // MARK: - Subviews

    private var titleRow: some View {
        HStack {
            Text(snippet.title)
                .font(.title3)
                .fontWeight(.bold)
                .minimumScaleFactor(0.75)
                .lineLimit(1)
                .padding(.top, 12)

            Spacer()

            if snippet.origin == .cloudNew {
                Text("NEW")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.mycolor.myBackground)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.mycolor.myAccent)
                    .clipShape(Capsule())
                    .padding(.top, 12)
            }
        }
    }

    private var subtitleRow: some View {
        Text(subtitleText)
            .font(.footnote)
            .minimumScaleFactor(0.75)
            .lineLimit(1)
    }

    private var bottomRow: some View {
        HStack {
            Text(snippet.category)
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundStyle(Color.mycolor.myAccent.opacity(0.6))

            Spacer()

            HStack(spacing: 6) {
                if snippet.favoriteChoice == .yes {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color.mycolor.myYellow)
                }
                if snippet.githubUrlString != nil {
                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                        .foregroundStyle(Color.mycolor.myAccent.opacity(0.4))
                }
            }
            .font(.caption)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ZStack {
            Color.pink.opacity(0.1).ignoresSafeArea()
            VStack {
                SnippetRowView(snippet: PreviewData.sampleSnippet1)
                SnippetRowView(snippet: PreviewData.sampleSnippet2)
                SnippetRowView(snippet: PreviewData.sampleSnippet3)
            }
        }
    }
}
