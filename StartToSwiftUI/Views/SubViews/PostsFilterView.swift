//
//  FiltersSheetView3.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 01.09.2025.
//

import SwiftUI
import SwiftData

struct PostsFilterView: View {
    
    // MARK: Dependencies
    @EnvironmentObject var vm: PostsViewModel
    
    // MARK: States
    @State private var updateFiltersSheetView: Bool = false
    
    // MARK: Constants

    let opacityBackground: Double = 0.10
    
    // MARK: Variables
    @Binding var isFilterButtonPressed: Bool

    // MARK: Body
    
    var body: some View {
        FiltersSheetLayout(
            onApply: applyFilters,
            onReset: {
                vm.resetAllFilters()
                updateFiltersSheetView.toggle()
            },
            onResetAndExit: {
                vm.resetAllFilters()
                isFilterButtonPressed.toggle()
            }
        ) {
#warning("Remove before deployment to App Store")
            //                categoryFilter
            studyLevelFilter
            favouriteFilter
            typeFilter
            typeMedia
            yearFilter
            sortOptions
        }
        .onDisappear {
            isFilterButtonPressed = false
        }
    }
    
    // MARK: Subviews
    private var studyLevelFilter: some View {
        FilterSection.make(
            title: "Study level:",
            selection: $vm.selectedLevel,
            allItems: StudyLevel.allCases,
            titleForCase: { $0.displayName }
        )
    }
    
    private var favouriteFilter: some View {
        FilterSection.make(
            title: "Favourite:",
            selection: $vm.selectedFavorite,
            allItems: FavoriteChoice.allCases,
            titleForCase: { $0.displayName }
        )
    }

    private var typeFilter: some View {
        FilterSection.make(
            title: "Post type:",
            selection: $vm.selectedType,
            allItems: PostType.selectablePostTypeCases,
            titleForCase: { $0.displayName }
        )
    }

    private var typeMedia: some View {
        FilterSection.make(
            title: "Media:",
            selection: $vm.selectedPlatform,
            allItems: Platform.allCases,
            titleForCase: { $0.displayName }
        )
    }
    
    private var yearFilter: some View {
        Group {
            if let list = vm.allYears {
                FilterSection.make(
                    title: "Year:",
                    selection: $vm.selectedYear,
                    allItems: list,
                    titleForCase: { $0 }
                )
            }
        }
    }

    private var sortOptions: some View {
        FilterSection.make(
            title: "Sort:",
            selection: $vm.selectedSortOption,
            allItems: SortOption.allCases,
            titleForCase: { $0.displayName }
        )
    }
        
    // MARK: Actions
    /// Логирует выбранные фильтры и закрывает лист.
    private func applyFilters() {
        vm.analyticsManager.logEvent(name: "filter_applied", params: [
            "level": vm.selectedLevel?.rawValue ?? "",
            "favorite": vm.selectedFavorite?.rawValue ?? "",
            "type": vm.selectedType?.rawValue ?? "",
            "platform": vm.selectedPlatform?.rawValue ?? "",
            "year": vm.selectedYear ?? "",
            "sort": vm.selectedSortOption.rawValue,
            "category": Constants.mainCategory
        ])
        isFilterButtonPressed.toggle()
    }
    
}

#Preview {
    let vm = PostsViewModel(
        dataSource: MockPostsDataSource(posts: PreviewData.samplePosts),
        fbPostsManager: MockFBPostsManager(),
        services: .make()
    )
    ZStack {
        PostsFilterView(
            isFilterButtonPressed: .constant(true)
        )
        .environmentObject(vm)
    }
}
