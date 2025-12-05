//
//  FiltersSheetView3.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 01.09.2025.
//

import SwiftUI

struct FiltersSheetView: View {
    
    // MARK: PROPERTIES
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: PostsViewModel
    
    @Binding var isFilterButtonPressed: Bool
    @State private var updateFiltersSheetView: Bool = false
    
    let selectedFont: Font = .caption.bold()
    let opacityBackground: Double = 0.10
    
    // MARK: MAIN VIEW
    
    var body: some View {
        
        ZStack {
//            Color.clear
//            .ignoresSafeArea()
            
            ScrollView {
                VStack (alignment: .leading) {
                    Text("Filters")
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 55)
                    //                categoryFilter
                    studyLevelFilter
                    favoriteFilter
                    typeFilter
                    yearFilter
                    //                sortOptions
                    
                    Spacer()
                    
                    applyFiltersButton
                    resetAllFiltersButton
                    resetAllFiltersAndExitButton
                        .padding(.bottom, 30)
                }
                .foregroundStyle(Color.mycolor.myAccent)
                .padding(.top, -40)
                .padding(.horizontal)
//                .background(.ultraThinMaterial)
                .onDisappear {
                    vm.isFiltersEmpty = vm.checkIfAllFiltersAreEmpty()
                    isFilterButtonPressed = false
                } // VStack
            } // ScrollView
            .scrollIndicators(.hidden)
        }
    }
    // MARK: Subviews
    
    private var sortOptions: some View {
        
        VStack {
            Text("Sort:")
                .font(.footnote)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            SegmentedOneLinePicker(
                selection: $vm.selectedSortOption,
                allItems: SortOption.allCases,
                titleForCase: { $0.displayName },
                selectedFont: selectedFont,
                selectedTextColor: Color.mycolor.myBackground,
                unselectedTextColor: Color.mycolor.myAccent,
                selectedBackground: Color.mycolor.myBlue,
                unselectedBackground: .clear,
                showNilOption: true,
                nilTitle: "Unsorted"
            )
        }
    }
    
    private var studyLevelFilter: some View {
        VStack {
            Text("Study level:")
                .font(.footnote)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            SegmentedOneLinePicker(
                selection: $vm.selectedLevel,
                allItems: StudyLevel.allCases,
                titleForCase: { $0.displayName },
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
    
    private var favoriteFilter: some View {
        VStack {
            Text("Favorite:")
                .font(.footnote)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            SegmentedOneLinePicker(
                selection: $vm.selectedFavorite,
                allItems: FavoriteChoice.allCases,
                titleForCase: { $0.displayName },
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
    
    private var typeFilter: some View {
        VStack {
            Text("Post type:")
                .font(.footnote)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            SegmentedOneLinePicker(
                selection: $vm.selectedType,
                allItems: PostType.allCases,
                titleForCase: { $0.displayName },
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
    
    private var yearFilter: some View {
        Group {
            if let list = vm.allYears {
                VStack(alignment: .leading) {
                    Text("Year:")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    CustomOneCapsulesLineSegmentedPicker(
                        selection: $vm.selectedYear,
                        allItems: list,
                        titleForCase: { $0 },
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
        }
    }
    
    private var categoryFilter: some View {
        Group {
            if let list = vm.allCategories {
                VStack(alignment: .leading) {
                    Text("Category:")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    CustomOneCapsulesLineSegmentedPicker(
                        selection: $vm.selectedCategory,
                        allItems: list,
                        titleForCase: { $0 },
                        selectedFont: selectedFont,
                        selectedTextColor: Color.mycolor.myBackground,
                        unselectedTextColor: Color.mycolor.myAccent,
                        selectedBackground: Color.mycolor.myButtonBGBlue,
                        unselectedBackground: .clear,
                        showNilOption: true,
                        nilTitle: "All"
                    )
                }
            }
        }
    }
    
    private var applyFiltersButton: some View {
        
        ClearCupsuleButton(
            primaryTitle: "Apply",
            primaryTitleColor: Color.mycolor.myBlue) {
                isFilterButtonPressed.toggle()
            }
            .padding(.horizontal, 55)
        
    }
    
    private var resetAllFiltersButton: some View {
        
        ClearCupsuleButton(
            primaryTitle: "Reset All",
            primaryTitleColor: Color.mycolor.myRed) {
                vm.selectedLevel = nil
                vm.selectedFavorite = nil
                vm.selectedType = nil
                vm.selectedYear = nil
                vm.selectedSortOption = nil
                updateFiltersSheetView.toggle()
            }
            .padding(.horizontal, 55)
    }
    
    private var resetAllFiltersAndExitButton: some View {
        
        ClearCupsuleButton(
            primaryTitle: "Reset All & Exit",
            primaryTitleColor: Color.mycolor.myRed) {
                vm.selectedLevel = nil
                vm.selectedFavorite = nil
                vm.selectedType = nil
                vm.selectedYear = nil
                vm.selectedSortOption = nil
                isFilterButtonPressed.toggle()
            }
            .padding(.horizontal, 55)
    }

}

fileprivate struct FiltersSheetPreview: View {
    
    var body: some View {
        
        ZStack {
            Color.mycolor.myAccent
                .ignoresSafeArea()
            FiltersSheetView(
                isFilterButtonPressed: .constant(true)
            )
        }
    }
}
#Preview {
    
    ZStack {
        FiltersSheetView(
            isFilterButtonPressed: .constant(true)
        )
        .environmentObject(PostsViewModel())
    }
}
