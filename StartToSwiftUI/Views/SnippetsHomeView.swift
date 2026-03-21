//
//  SnippetsHomeView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.03.2026.
//

import SwiftUI
import Splash

struct SnippetsHomeView: View {

    // MARK: - Dependencies
    @EnvironmentObject private var snippetvm: SnippetsViewModel
    @EnvironmentObject private var noticevm: NoticesViewModel
    @EnvironmentObject private var coordinator: AppCoordinator

    private let hapticManager = HapticManager.shared

    // MARK: - Splash vars

    private var splashTheme: Splash.Theme {
        .midnight(withFont: .init(size: 13))
    }

    // MARK: - States
    @State private var showOnTopButton = false
    @State private var isFilterButtonPressed = false
    @State private var hasSnippetsUpdate = false

    // MARK: - Body
    var body: some View {
        ScrollViewReader { scrollProxy in
            ZStack(alignment: .bottom) {
                if snippetvm.allSnippets.isEmpty {
                    allSnippetsIsEmpty
                } else if snippetvm.filteredSnippets.isEmpty {
                    filteredSnippetsIsEmpty
                } else {
                    listContent
                    OnTopButton(isVisible: showOnTopButton) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            scrollProxy.scrollTo(snippetvm.filteredSnippets.first?.id, anchor: .top)
                        }
                    }
                }
            }
        }
        .navigationTitle("Code Snippets")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar { SharedToolbarLeadingItems() }
        .safeAreaInset(edge: .top) { searchBarStack }
        .sheet(isPresented: $isFilterButtonPressed) { filtersSheet }
        .task {
            FBAnalyticsManager.shared.logScreen(name: "SnippetsHomeView")
        }
    }

    // MARK: - List

    private var listContent: some View {
        List {
            ForEach(snippetvm.filteredSnippets) { snippet in
                SnippetRowView(snippet: snippet, isFavorite: snippetvm.isFavorite(snippet))
                    .id(snippet.id)
                    .background(.black.opacity(0.001))
                    .onTapGesture { handleTap(on: snippet) }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        leadingSwipeActions(for: snippet)
                    }
            }
            .listRowBackground(Color.clear)
            .listRowSeparatorTint(Color.mycolor.myAccent.opacity(0.35))
            .listRowSeparator(.hidden, edges: [.top])
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
        .listStyle(.plain)
        .onScrollGeometryChange(for: CGFloat.self) { geo in
            geo.contentOffset.y
        } action: { _, newOffset in
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                showOnTopButton = newOffset > 100
            }
        }
    }

    // MARK: - Tap

    private func handleTap(on snippet: CodeSnippet) {
        snippetvm.selectedSnippet = snippet
        if UIDevice.isiPhone {
            coordinator.push(.snippetDetails(snippet: snippet))
        }
    }

    // MARK: - Swipe Actions

    @ViewBuilder
    private func leadingSwipeActions(for snippet: CodeSnippet) -> some View {
        Button(
            snippetvm.isFavorite(snippet) ? "Unmark" : "Mark",
            systemImage: snippetvm.isFavorite(snippet) ? "star.slash" : "star"
        ) {
            snippetvm.favoriteToggle(snippet)
        }
        .tint(snippetvm.isFavorite(snippet) ? FavoriteChoice.yes.color : FavoriteChoice.no.color)
    }

    // MARK: - Search Bar Stack
    private var searchBarStack: some View {
        HStack {
            SearchBarView(searchText: $snippetvm.searchText)

            // Fliters for posts
            if !snippetvm.allSnippets.isEmpty {
                CircleStrokeButtonView(
                    iconName: "line.3.horizontal.decrease",
                    isIconColorToChange: !snippetvm.isFiltersEmpty,
                    isShownCircle: false
                ) {
                    isFilterButtonPressed.toggle()
                    hapticManager.impact(style: .light)
                }
                .background(.ultraThinMaterial)
                .clipShape(.circle)
                .background(
                    Circle()
                        .stroke(Color.mycolor.mySecondary,lineWidth: 1)
                )
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Filters Sheet

    private var filtersSheet: some View {
        SnippetsFilterView(isPresented: $isFilterButtonPressed)
            .overlay(alignment: .top) {
                if UIDevice.isiPhone {
                    LinearGradient(
                        colors: [Color.mycolor.mySecondary.opacity(0.1), Color.clear],
                        startPoint: .top, endPoint: .bottom
                    )
                    .frame(height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                }
            }
            .presentationBackground(.ultraThinMaterial)
            .presentationDetents([.height(400)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(30)
    }

    // MARK: - Supporting Views

    private var allSnippetsIsEmpty: some View {
        ContentUnavailableView(
            "No Code Snippets",
            systemImage: "chevron.left.forwardslash.chevron.right",
            description: Text("Download the curated collection from the menu.")
        )
    }

    private var filteredSnippetsIsEmpty: some View {
        ContentUnavailableView(
            "No Results",
            systemImage: "magnifyingglass",
            description: Text("Check the spelling or try a new search.")
        )
    }
}

#Preview("With Mock Snippets") {
    NavigationStack {
        SnippetsHomeView()
            .environmentObject(SnippetsViewModel())
            .environmentObject(NoticesViewModel(
                dataSource: MockNoticesDataSource(),
                fbNoticesManager: MockFBNoticesManager()
            ))
            .environmentObject(AppCoordinator())
    }
}
