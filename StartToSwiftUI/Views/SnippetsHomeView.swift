//
//  SnippetsHomeView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.03.2026.
//

import SwiftUI
import SwiftData

struct SnippetsHomeView: View {

    // MARK: - Dependencies
    @EnvironmentObject private var vm: SnippetsViewModel
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
                    if vm.allSnippets.isEmpty {
                        allSnippetsIsEmpty
                    } else if vm.filteredSnippets.isEmpty {
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
            .safeAreaInset(edge: .top) { searchBar }
            .sheet(isPresented: $isFilterButtonPressed) { filtersSheet }
            .alert("Error", isPresented: $vm.showErrorMessageAlert) {
                Button("OK") {}
            } message: {
                if let msg = vm.errorMessage { Text(msg) }
            }
            .task {
                FBAnalyticsManager.shared.logScreen(name: "SnippetsHomeView")
                vm.loadSnippetsFromSwiftData()
                hasSnippetsUpdate = await vm.checkFBSnippetsForUpdates()
            }
        }
    }

    // MARK: - List

    private var listContent: some View {
        List {
            ForEach(vm.filteredSnippets) { snippet in
                SnippetRowView(snippet: snippet)
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
        .refreshControl {
            vm.loadSnippetsFromSwiftData()
            Task { hasSnippetsUpdate = await vm.checkFBSnippetsForUpdates() }
        }
    }

    // MARK: - Tap

    private func handleTap(on snippet: CodeSnippet) {
        vm.selectedSnippet = snippet
        if snippet.origin == .cloudNew { vm.updateSnippetOrigin(snippet) }
        if UIDevice.isiPhone {
            coordinator.push(.snippetDetails(snippet: snippet))
        }
    }

    // MARK: - Swipe Actions

    @ViewBuilder
    private func leadingSwipeActions(for snippet: CodeSnippet) -> some View {
        Button(
            snippet.favoriteChoice == .yes ? "Unmark" : "Mark",
            systemImage: snippet.favoriteChoice == .yes ? "star.slash" : "star"
        ) {
            vm.favoriteToggle(snippet)
        }
        .tint(snippet.favoriteChoice == .yes ? Color.mycolor.myAccent : Color.mycolor.mySecondary)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.mycolor.myAccent.opacity(0.5))
            TextField("Search snippets", text: $vm.searchText)
                .foregroundStyle(Color.mycolor.myAccent)
        }
        .padding(10)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .padding(.vertical, 6)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private func navigationToolbar() -> some ToolbarContent {

        // ⚙️ and 🔔 — shared items from StartView
        SharedToolbarLeadingItems()

        // ⇄ switch section
        SharedToolbarSwitchItem()

        ToolbarItemGroup(placement: .navigationBarTrailing) {
            // ⋯ Manage menu
            manageMenu

            // ≡ Filter
            if !vm.allSnippets.isEmpty {
                CircleStrokeButtonView(
                    iconName: "line.3.horizontal.decrease",
                    isIconColorToChange: !vm.isFiltersEmpty,
                    isShownCircle: false
                ) {
                    isFilterButtonPressed.toggle()
                    hapticManager.impact(style: .light)
                }
            }
        }
    }

    // MARK: - Manage Menu (⋯)

    private var manageMenu: some View {
        Menu {
            if vm.shouldShowImportFromCloud {
                Button("Download curated collection", systemImage: "icloud.and.arrow.down") {
                    coordinator.push(.importSnippetsFromCloud)
                }
            } else if hasSnippetsUpdate {
                Button("Check for updates", systemImage: "arrow.trianglehead.counterclockwise") {
                    coordinator.push(.importSnippetsFromCloud)
                }
            }
            if vm.hasHidden {
                Button("Archived (\(vm.hiddenCount))", systemImage: "archivebox") {
                    coordinator.push(.archivedSnippets)
                }
            }
        } label: {
            CircleStrokeButtonView(iconName: "ellipsis", isShownCircle: false) {}
        }
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
                    if snippet.id == vm.filteredSnippets.first?.id {
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
                    if let firstID = vm.filteredSnippets.first?.id {
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

// MARK: - Preview

private struct SnippetsHomeViewPreview: View {
    @StateObject var vm: SnippetsViewModel = {
        let vm = SnippetsViewModel(
            dataSource: MockSnippetsDataSource(snippets: PreviewData.sampleSnippets),
            fbSnippetsManager: MockFBSnippetsManager()
        )
        vm.start()
        return vm
    }()
    @StateObject var noticesVM = NoticesViewModel(
        dataSource: MockNoticesDataSource(),
        fbNoticesManager: MockFBNoticesManager()
    )

    var body: some View {
        NavigationStack {
            SnippetsHomeView()
                .environmentObject(AppCoordinator())
                .environmentObject(vm)
                .environmentObject(noticesVM)
        }
    }
}

#Preview("With Mock Snippets") {
    let container = try! ModelContainer(
        for: CodeSnippet.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    SnippetsHomeViewPreview().modelContainer(container)
}
