//
//  SnippetsHomeView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.03.2026.
//

import SwiftUI

struct SnippetsHomeView: View {

    // MARK: - Dependencies
    @EnvironmentObject private var snippetvm: SnippetsViewModel
    @EnvironmentObject private var noticevm: NoticesViewModel
    @EnvironmentObject private var coordinator: AppCoordinator

    private let hapticManager = HapticManager.shared

    // MARK: - States
    @State private var showOnTopButton = false
    @State private var isFilterButtonPressed = false
    @State private var hasSnippetsUpdate = false

    // MARK: - Body
    var body: some View {
        GeometryReader { _ in
            ScrollViewReader { scrollProxy in
                ZStack(alignment: .bottom) {
                    if snippetvm.allSnippets.isEmpty {
                        allSnippetsIsEmpty
                    } else if snippetvm.filteredSnippets.isEmpty {
                        filteredSnippetsIsEmpty
                    } else {
                        listContent
                        onTopButton(proxy: scrollProxy)
                    }
                }
            }
            .navigationTitle("Code Snippets")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar { navigationToolbar() }
            .safeAreaInset(edge: .top) {
                SearchBarView(searchText: $snippetvm.searchText)
            }
            .sheet(isPresented: $isFilterButtonPressed) { filtersSheet }
        }
        .task {
            FBAnalyticsManager.shared.logScreen(name: "SnippetsHomeView")
            
//            vm.loadPostsFromSwiftData()
            noticevm.loadNoticesFromSwiftData()
//            vm.updateWidgetData()
            await noticevm.importNoticesFromFirebase()
        }

    }

    // MARK: - List

    private var listContent: some View {
        List {
            ForEach(snippetvm.filteredSnippets) { snippet in
                SnippetRowView(snippet: snippet, isFavorite: snippetvm.isFavorite(snippet))
                    .id(snippet.id)
                    .background(trackingFirstSnippet(snippet: snippet))
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
        .tint(snippetvm.isFavorite(snippet) ? Color.mycolor.myAccent : Color.mycolor.mySecondary)
    }
    
    // MARK: - Search Bar

//    private var searchBar: some View {
//        HStack {
//            Image(systemName: "magnifyingglass")
//                .foregroundStyle(Color.mycolor.myAccent.opacity(0.5))
//            TextField("Search snippets", text: $snippetvm.searchText)
//                .foregroundStyle(Color.mycolor.myAccent)
//        }
//        .padding(10)
//        .background(.ultraThinMaterial)
//        .clipShape(RoundedRectangle(cornerRadius: 12))
//        .padding(.horizontal)
//        .padding(.vertical, 6)
//    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private func navigationToolbar() -> some ToolbarContent {

        // ⚙️ and 🔔 — shared items from StartView
        SharedToolbarLeadingItems()

        // ⇄ switch section
        SharedToolbarSwitchItem()

//        ToolbarItemGroup(placement: .navigationBarTrailing) {
            // ⋯ Manage menu

            // ≡ Filter
//            if !snippetvm.allSnippets.isEmpty {
//                CircleStrokeButtonView(
//                    iconName: "line.3.horizontal.decrease",
//                    isIconColorToChange: !snippetvm.isFiltersEmpty,
//                    isShownCircle: false
//                ) {
//                    isFilterButtonPressed.toggle()
//                    hapticManager.impact(style: .light)
//                }
//            }
//        }
    }

    // MARK: - Filters Sheet

    private var filtersSheet: some View {
        SnippetsFiltersView(isPresented: $isFilterButtonPressed)
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

    @ViewBuilder
    private func trackingFirstSnippet(snippet: CodeSnippet) -> some View {
        GeometryReader { geo in
            Color.clear
                .onChange(of: geo.frame(in: .global).minY) { _, newY in
                    if snippet.id == snippetvm.filteredSnippets.first?.id {
                        showOnTopButton = newY < 0
                    }
                }
        }
    }

    @ViewBuilder
    private func onTopButton(proxy: ScrollViewProxy) -> some View {
        if showOnTopButton {
            CircleStrokeButtonView(
                iconName: "control",
                iconFont: .title,
                imageColorPrimary: Color.mycolor.myBlue,
                widthIn: 55,
                heightIn: 55
            ) {
                withAnimation {
                    if let firstID = snippetvm.filteredSnippets.first?.id {
                        proxy.scrollTo(firstID, anchor: .top)
                    }
                }
            }
        }
    }

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
