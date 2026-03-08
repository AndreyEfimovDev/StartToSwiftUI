//
//  CardModifierDemoView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.03.2026.
//
//  Place in Views/Snippets/Demos/

import SwiftUI

// MARK: - Card Modifier Demo
// Snippet ID: "snippet_001"

struct CardModifierDemoView: View {

    let snippet: CodeSnippet

    // MARK: - The modifier being demonstrated

    private struct CardModifier: ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header

                // Live Demo
                demoSection

                descriptionSection
            }
            .padding(.horizontal)
            .padding(.top)
            .foregroundStyle(Color.mycolor.myAccent)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(snippet.title)
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(snippet.intro)
                .font(.subheadline)
                .foregroundStyle(Color.mycolor.myAccent.opacity(0.7))
        }
        .cardBackground()
    }

    private var demoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Live Demo")
                .font(.headline)

            // Applying the modifier to different content
            Text("Simple text with .cardStyle()")
                .modifier(CardModifier())

            HStack {
                Image(systemName: "star.fill")
                    .foregroundStyle(Color.mycolor.myYellow)
                Text("HStack with .cardStyle()")
            }
            .modifier(CardModifier())

            VStack(alignment: .leading, spacing: 4) {
                Text("VStack with .cardStyle()")
                    .fontWeight(.semibold)
                Text("Subtitle content here")
                    .font(.caption)
                    .foregroundStyle(Color.mycolor.myAccent.opacity(0.6))
            }
            .modifier(CardModifier())
        }
        .cardBackground()
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How it works")
                .font(.headline)
            Text("ViewModifier wraps any View in a reusable style. The .cardStyle() extension makes the syntax clean at the call site — just chain it like any built-in modifier.")
                .font(.subheadline)
                .foregroundStyle(Color.mycolor.myAccent.opacity(0.8))
        }
        .cardBackground()
    }
}

// MARK: - Async Image Demo
// Snippet ID: "snippet_002"

struct AsyncImageDemoView: View {

    let snippet: CodeSnippet

    private let sampleURL = "https://picsum.photos/seed/swiftui/200/200"

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerCard

                demoSection

                descriptionSection
            }
            .padding(.horizontal)
            .padding(.top)
            .foregroundStyle(Color.mycolor.myAccent)
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(snippet.title)
                .font(.title2)
                .fontWeight(.semibold)
            Text(snippet.intro)
                .font(.subheadline)
                .foregroundStyle(Color.mycolor.myAccent.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardBackground()
    }

    private var demoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Live Demo")
                .font(.headline)

            HStack(spacing: 16) {
                // The actual AsyncImage from the snippet
                AsyncImage(url: URL(string: sampleURL)) { phase in
                    switch phase {
                    case .empty:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.secondary.opacity(0.2))
                            .overlay { ProgressView() }
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        Image(systemName: "photo")
                            .foregroundStyle(.secondary)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Remote Image")
                        .fontWeight(.semibold)
                    Text("Loaded asynchronously with a placeholder while downloading.")
                        .font(.caption)
                        .foregroundStyle(Color.mycolor.myAccent.opacity(0.7))
                }
            }
        }
        .cardBackground()
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How it works")
                .font(.headline)
            Text("AsyncImage handles three phases automatically: .empty (placeholder), .success (loaded image) and .failure (error state). No extra packages needed — it's built into SwiftUI.")
                .font(.subheadline)
                .foregroundStyle(Color.mycolor.myAccent.opacity(0.8))
        }
        .cardBackground()
    }
}

// MARK: - Debounced Search Demo
// Snippet ID: "snippet_003"

struct DebouncedSearchDemoView: View {

    let snippet: CodeSnippet

    @State private var searchText = ""
    @State private var displayedQuery = ""

    private let items = [
        "SwiftUI", "Swift", "Combine", "NavigationStack",
        "ViewModifier", "AsyncAwait", "MVVM", "SwiftData",
        "Coordinator", "EnvironmentObject"
    ]

    private var filteredItems: [String] {
        searchText.isEmpty ? items : items.filter {
            $0.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerCard

                demoSection

                descriptionSection
            }
            .padding(.horizontal)
            .padding(.top)
            .foregroundStyle(Color.mycolor.myAccent)
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(snippet.title)
                .font(.title2)
                .fontWeight(.semibold)
            Text(snippet.intro)
                .font(.subheadline)
                .foregroundStyle(Color.mycolor.myAccent.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardBackground()
    }

    private var demoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Live Demo")
                .font(.headline)

            TextField("Type to filter...", text: $searchText)
                .padding(10)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                // Debounce with .onChange — same effect as Combine debounce
                .onChange(of: searchText) { _, newValue in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if newValue == searchText {
                            displayedQuery = newValue
                        }
                    }
                }

            if !displayedQuery.isEmpty {
                Text("Filtering after 0.5s pause: \"\(displayedQuery)\"")
                    .font(.caption)
                    .foregroundStyle(Color.mycolor.myBlue)
            }

            ForEach(filteredItems, id: \.self) { item in
                Text(item)
                    .padding(.vertical, 4)
                Divider()
            }
        }
        .cardBackground()
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How it works")
                .font(.headline)
            Text("Debounce delays the filter until the user stops typing (0.5s pause). Without it, every keystroke triggers an expensive filter or network call. In a ViewModel, Combine's .debounce() operator handles this elegantly.")
                .font(.subheadline)
                .foregroundStyle(Color.mycolor.myAccent.opacity(0.8))
        }
        .cardBackground()
    }
}

// MARK: - Previews

#Preview("Card Modifier") {
    NavigationStack {
        CardModifierDemoView(snippet: PreviewData.sampleSnippet1)
            .environmentObject(AppCoordinator())
    }
}

#Preview("Async Image") {
    NavigationStack {
        AsyncImageDemoView(snippet: PreviewData.sampleSnippet2)
            .environmentObject(AppCoordinator())
    }
}

#Preview("Debounced Search") {
    NavigationStack {
        DebouncedSearchDemoView(snippet: PreviewData.sampleSnippet3)
            .environmentObject(AppCoordinator())
    }
}
