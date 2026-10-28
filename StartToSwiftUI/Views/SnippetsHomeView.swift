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
    @State private var isFilterButtonPressed: Bool = false
    /// Выбор в List(selection:) на iPad (iPadListContent) — привязан к id
    /// (String), а не к самому CodeSnippet, для единообразия с MaterialsHomeView.
    /// Источник правды — snippetvm.selectedSnippet; это локальное зеркало для
    /// List, синхронизируется в обе стороны и восстанавливается из VM в
    /// onAppear после смены секции — подробнее у selectedPostID в MaterialsHomeView.
    @State private var selectedSnippetID: String?

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
                    // На iPad это view — sidebar-колонка NavigationSplitView
                    // (без собственного нижнего toolbar) — её нижняя safe
                    // area примыкает вплотную к краю экрана, в отличие от
                    // полноэкранного NavigationStack на iPhone, поэтому
                    // кнопку нужно явно приподнять.
                    .padding(.bottom, UIDevice.isiPad ? 20 : 0)
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
            snippetvm.analyticsManager.logScreen(name: "SnippetsHomeView")

        }
    }

    // MARK: - List

    /// iPhone — обычный ForEach с onTapGesture + swipe. iPad — List(selection:),
    /// привязанный к NavigationSplitView: тап сам переключает detail-колонку
    /// и даёт системную кнопку "назад" в схлопнутом (compact) состоянии —
    /// вручную через columnVisibility это заставить работать не удалось
    /// (см. аналогичное обсуждение для MaterialsHomeView).
    @ViewBuilder
    private var listContent: some View {
        if UIDevice.isiPad {
            iPadListContent
        } else {
            iPhoneListContent
        }
    }

    private var iPhoneListContent: some View {
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
        // Отслеживаем только пересечение порога, а не каждый пиксель смещения:
        // action (и withAnimation) срабатывает лишь при смене true/false.
        .onScrollGeometryChange(for: Bool.self) { geo in
            geo.contentOffset.y > 100
        } action: { _, isPastThreshold in
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                showOnTopButton = isPastThreshold
            }
        }
    }

    private var iPadListContent: some View {
        List(snippetvm.filteredSnippets, selection: $selectedSnippetID) { snippet in
            SnippetRowView(snippet: snippet, isFavorite: snippetvm.isFavorite(snippet))
                .id(snippet.id)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    leadingSwipeActions(for: snippet)
                }
        }
        .listStyle(.plain)
        // Отслеживаем только пересечение порога, а не каждый пиксель смещения:
        // action (и withAnimation) срабатывает лишь при смене true/false.
        .onScrollGeometryChange(for: Bool.self) { geo in
            geo.contentOffset.y > 100
        } action: { _, isPastThreshold in
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                showOnTopButton = isPastThreshold
            }
        }
        // Восстановить выделение из VM после появления списка (см. MaterialsHomeView).
        .onAppear { selectedSnippetID = snippetvm.selectedSnippet?.id }
        // Список → VM: тап по строке.
        .onChange(of: selectedSnippetID) { _, newID in
            snippetvm.selectedSnippet = snippetvm.filteredSnippets.first { $0.id == newID }
        }
        // VM → список: выбор изменён снаружи.
        .onChange(of: snippetvm.selectedSnippet?.id) { _, newID in
            selectedSnippetID = newID
        }
    }

    // MARK: - Tap

    /// Используется только на iPhone (см. iPhoneListContent). На iPad деталь
    /// открывается через List(selection:) в iPadListContent.
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
            systemImage: snippetvm.isFavorite(snippet) ? "heart.fill" : "heart"
        ) {
            snippetvm.favoriteToggle(snippet)
        }
        .tint(snippetvm.isFavorite(snippet) ? FavoriteChoice.yes.color : FavoriteChoice.no.color)
    }

    // MARK: - Search Bar Stack
    private var searchBarStack: some View {
        HStack {
            SearchBarView(searchText: $snippetvm.searchText)
            // Filters for snippets
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
                    .stroke(
                        Color.mycolor.mySecondary,
                        lineWidth: 1)
            )
        }
        .padding(.horizontal)
    }

    // MARK: - Filters View

    private var filtersSheet: some View {
        SnippetsFilterView(isFilterButtonPressed: $isFilterButtonPressed)
            .overlay(alignment: .top) {
                if UIDevice.isiPhone {
                    LinearGradient(
                        colors: [
                            Color.mycolor.mySecondary.opacity(0.1),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 30)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 30)
                    )
                }
            }
            .presentationBackground(.ultraThinMaterial)
            // Три секции вместо шести у постов — лист ниже, чем в Materials (600).
            .presentationDetents([.height(420)])
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
        .foregroundStyle(Color.mycolor.myAccent)
    }

    private var filteredSnippetsIsEmpty: some View {
        ContentUnavailableView(
            "No Results matching your search criteria",
            systemImage: "magnifyingglass",
            description: Text("Check the spelling or try a new search.")
        )
        .foregroundStyle(Color.mycolor.myAccent)
    }
}

#Preview("With Mock Snippets") {
    NavigationStack {
        SnippetsHomeView()
            .environmentObject(SnippetsViewModel(services: .make()))
            .environmentObject(NoticesViewModel(
                dataSource: MockNoticesDataSource(),
                fbNoticesManager: MockFBNoticesManager(),
                services: .make()
            ))
            .environmentObject(AppCoordinator())
    }
}
