//
//  SnippetsFilterView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 28.10.2026.
//

import SwiftUI

struct SnippetsFilterView: View {

    // MARK: Dependencies
    @EnvironmentObject private var snippetvm: SnippetsViewModel

    // MARK: Variables
    @Binding var isFilterButtonPressed: Bool

    // MARK: Body

    var body: some View {
        FiltersSheetLayout(
            onApply: applyFilters,
            onReset: { snippetvm.resetAllFilters() },
            onResetAndExit: {
                snippetvm.resetAllFilters()
                isFilterButtonPressed.toggle()
            }
        ) {
            minOSFilter
            favouriteFilter
            sortOptions
        }
        .onDisappear {
            isFilterButtonPressed = false
        }
    }

    // MARK: Subviews
    private var minOSFilter: some View {
        FilterSection.make(
            title: "iOS version:",
            selection: $snippetvm.selectedMinOS,
            allItems: CodeSnippet.MinOS.allCases,
            titleForCase: { $0.displayName }
        )
    }

    private var favouriteFilter: some View {
        FilterSection.make(
            title: "Favourite:",
            selection: $snippetvm.selectedFavorite,
            allItems: FavoriteChoice.allCases,
            titleForCase: { $0.displayName }
        )
    }

    private var sortOptions: some View {
        FilterSection.make(
            title: "Sort:",
            selection: $snippetvm.selectedSortOption,
            allItems: SortOption.allCases,
            titleForCase: { $0.displayName }
        )
    }

    // MARK: Actions
    /// Логирует выбранные фильтры и закрывает лист.
    private func applyFilters() {
        snippetvm.analyticsManager.logEvent(name: "snippet_filter_applied", params: [
            "min_os": snippetvm.selectedMinOS?.rawValue ?? "",
            "favorite": snippetvm.selectedFavorite?.rawValue ?? "",
            "sort": snippetvm.selectedSortOption.rawValue
        ])
        isFilterButtonPressed.toggle()
    }
}

#Preview {
    SnippetsFilterView(isFilterButtonPressed: .constant(true))
        .environmentObject(SnippetsViewModel(services: .make()))
}
