//
//  FiltersSheetView3.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 01.09.2025.
//

import SwiftUI
import SwiftData

struct FiltersView: View {
    
    // MARK: Dependencies
    @EnvironmentObject var vm: PostsViewModel
    
    // MARK: States
    @State private var updateFiltersSheetView: Bool = false
    
    // MARK: Constants

    let selectedFont: Font = .caption.bold()
    let opacityBackground: Double = 0.10
    
    // MARK: Variables
    @Binding var isFilterButtonPressed: Bool

    // MARK: Body
    
    var body: some View {
        VStack (spacing: 0) {
            Text("Filters")
                .font(.largeTitle)
                .padding(.top, 35)

            // Filters section
                VStack(spacing: 0) {
#warning("Remove before deployment to App Store")
                    //                categoryFilter
                    studyLevelFilter
                    favouriteFilter
                    typeFilter
                    typeMedia
                    yearFilter
                    sortOptions
                }
                .padding(.horizontal, UIDevice.isiPad ? 15 : 0)

                Spacer()
                
                // Buttons section
                VStack {
                    applyFiltersButton
                    HStack {
                        resetAllFiltersButton
                        resetAllFiltersAndExitButton
                    }
                }
                .padding(.horizontal, UIDevice.isiPad ? 90 : 30)
                .padding(.bottom, UIDevice.isiPad ? 15 : 30)
        }
        .foregroundStyle(Color.mycolor.myAccent)
        .padding(.horizontal)
        .onDisappear {
            vm.isFiltersEmpty = vm.checkIfAllFiltersAreEmpty()
            isFilterButtonPressed = false
        }
    }
    
    // MARK: Subviews
    private var studyLevelFilter: some View {
        filterSection(
            title: "Study level:",
            selection: $vm.selectedLevel,
            allItems: StudyLevel.allCases,
            titleForCase: { $0.displayName }
        )
    }
    
    private var favouriteFilter: some View {
        filterSection(
            title: "Favourite:",
            selection: $vm.selectedFavorite,
            allItems: FavoriteChoice.allCases,
            titleForCase: { $0.displayName }
        )
    }

    private var typeFilter: some View {
        filterSection(
            title: "Post type:",
            selection: $vm.selectedType,
            allItems: PostType.selectablePostTypeCases,
            titleForCase: { $0.displayName }
        )
    }

    private var typeMedia: some View {
        filterSection(
            title: "Media:",
            selection: $vm.selectedPlatform,
            allItems: Platform.allCases,
            titleForCase: { $0.displayName }
        )
    }
    
    private var yearFilter: some View {
        Group {
            if let list = vm.allYears {
                filterSection(
                    title: "Year:",
                    selection: $vm.selectedYear,
                    allItems: list,
                    titleForCase: { $0 }
                )
            }
        }
    }

    private var categoryFilter: some View {
        Group {
            if let list = vm.allCategories {
                filterSection(
                    title: "Category:",
                    selection: $vm.selectedCategory,
                    allItems: list,
                    titleForCase: { $0 }
                )
            }
        }
    }

    private var sortOptions: some View {
        filterSection(
            title: "Sort:",
            selection: $vm.selectedSortOption,
            allItems: SortOption.allCases,
            titleForCase: { $0.displayName }
        )
    }
        
    // MARK: Helpers
    /// For Non-Optional filters (SortOption)
    private func filterSection<T: Hashable & CaseIterable>(
        title: String,
        selection: Binding<T>,
        allItems: [T],
        titleForCase: @escaping (T) -> String
    ) -> some View {
        VStack(spacing: 3) {
            Text(title)
                .font(.footnote)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)
            SegmentedOneLinePickerNotOptional(
                selection: selection,
                allItems: allItems,
                titleForCase: titleForCase,
                selectedFont: selectedFont,
                selectedTextColor: Color.mycolor.myBackground,
                unselectedTextColor: Color.mycolor.myAccent,
                selectedBackground: Color.mycolor.myBlue,
                unselectedBackground: .clear
            )
        }
    }
    
    /// For Optional filters CaseIterable (StudyLevel?, FavoriteChoice?, etc.)
    private func filterSection<T: Hashable & CaseIterable>(
        title: String,
        selection: Binding<T?>,
        allItems: [T],
        titleForCase: @escaping (T) -> String
    ) -> some View {
        VStack(spacing: 3) {
            Text(title)
                .font(.footnote)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)
            SegmentedOneLinePicker(
                selection: selection,
                allItems: allItems,
                titleForCase: titleForCase,
                selectedFont: selectedFont,
                selectedTextColor: Color.mycolor.myBackground,
                unselectedTextColor: Color.mycolor.myAccent,
                selectedBackground: Color.mycolor.myBlue,
                unselectedBackground: .clear,
                showNilOption: true,
                nilTitle: "All"
            )
        }
    }
    
    /// For Optional filters not CaseIterable (year, category)
    private func filterSection<T: Hashable>(
        title: String,
        selection: Binding<T?>,
        allItems: [T],
        titleForCase: @escaping (T) -> String
    ) -> some View {
        VStack(spacing: 3) {
            Text(title)
                .font(.footnote)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)
            CustomOneCapsulesLineSegmentedPicker(
                selection: selection,
                allItems: allItems,
                titleForCase: titleForCase,
                selectedFont: selectedFont,
                selectedTextColor: Color.mycolor.myBackground,
                unselectedTextColor: Color.mycolor.myAccent,
                selectedBackground: Color.mycolor.myBlue,
                unselectedBackground: .clear,
                showNilOption: true,
                nilTitle: "All"
            )
        }
    }

    // MARK: Buttons
    private var applyFiltersButton: some View {
#warning("Delete the line with 'category' before deployment to App Store")
        ClearCupsuleButton(
            primaryTitle: "Apply",
            primaryTitleColor: Color.mycolor.myBlue) {
                FBAnalyticsManager.shared.logEvent(name: "filter_applied", params: [
                    "level": vm.selectedLevel?.rawValue ?? "",
                    "favorite": vm.selectedFavorite?.rawValue ?? "",
                    "type": vm.selectedType?.rawValue ?? "",
                    "platform": vm.selectedPlatform?.rawValue ?? "",
                    "year": vm.selectedYear ?? "",
                    "sort": vm.selectedSortOption.rawValue
//                    "category": vm.selectedCategory ?? ""
                ])
                isFilterButtonPressed.toggle()
            }
    }
    
    private var resetAllFiltersButton: some View {
        
        ClearCupsuleButton(
            primaryTitle: "Reset All",
            primaryTitleColor: Color.mycolor.myRed) {
                vm.selectedLevel = nil
                vm.selectedFavorite = nil
                vm.selectedType = nil
                vm.selectedPlatform = nil
                vm.selectedYear = nil
                vm.selectedSortOption = .notSorted
                updateFiltersSheetView.toggle()
            }
    }
    
    private var resetAllFiltersAndExitButton: some View {
        
        ClearCupsuleButton(
            primaryTitle: "Reset All & Exit",
            primaryTitleColor: Color.mycolor.myRed) {
                vm.selectedLevel = nil
                vm.selectedFavorite = nil
                vm.selectedType = nil
                vm.selectedPlatform = nil
                vm.selectedYear = nil
                vm.selectedSortOption = .notSorted
                isFilterButtonPressed.toggle()
            }
    }
    
}

#Preview {
    
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppSyncState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let context = ModelContext(container)
    
    let vm = PostsViewModel(
        dataSource: MockPostsDataSource(posts: PreviewData.samplePosts)
    )
    ZStack {
        FiltersView(
            isFilterButtonPressed: .constant(true)
        )
        .environmentObject(vm)
    }
}
