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
    @Environment(\.dismiss) var dismiss
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
        VStack (alignment: .leading) {
            Text("Filters")
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 55)
            
            // Filters section
//                categoryFilter
            VStack(spacing: 0) {
                studyLevelFilter
                favoriteFilter
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
            .padding(.horizontal, UIDevice.isiPad ? 90 : 35)
            .padding(.bottom, UIDevice.isiPad ? 15 : 30)
        }
        .foregroundStyle(Color.mycolor.myAccent)
        .padding(.top, -40)
        .padding(.horizontal)
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(
                    Color.mycolor.mySecondary,
                    lineWidth: UIDevice.isiPhone ? 1 : 0
                )
                .mask(
                    VStack {
                        Rectangle().frame(height: 100)
                        Spacer()
                    }
                )
        )
        .onDisappear {
            vm.isFiltersEmpty = vm.checkIfAllFiltersAreEmpty()
            isFilterButtonPressed = false
        }
    }
    
    // MARK: Subviews
    
    private var sortOptions: some View {
        
        VStack {
            Text("Sort:")
                .font(.footnote)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            SegmentedOneLinePickerNotOptional(
                selection: $vm.selectedSortOption,
                allItems: SortOption.allCases,
                titleForCase: { $0.displayName },
                selectedFont: selectedFont,
                selectedTextColor: Color.mycolor.myBackground,
                unselectedTextColor: Color.mycolor.myAccent,
                selectedBackground: Color.mycolor.myBlue,
                unselectedBackground: .clear
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
                allItems: PostType.selectablePostTypeCases,
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
    
    private var typeMedia: some View {
        VStack {
            Text("Media:")
                .font(.footnote)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            SegmentedOneLinePicker(
                selection: $vm.selectedPlatform,
                allItems: Platform.allCases,
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
//            .padding(.horizontal, 55)
        
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
                vm.selectedSortOption = .newestFirst
                updateFiltersSheetView.toggle()
            }
//            .padding(.horizontal, 55)
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
                vm.selectedSortOption = .newestFirst
                isFilterButtonPressed.toggle()
            }
//            .padding(.horizontal, 55)
    }
    
}

#Preview {
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppSyncState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let context = ModelContext(container)
    
    let vm = PostsViewModel(modelContext: context)
    
    ZStack {
        FiltersView(
            isFilterButtonPressed: .constant(true)
        )
        .environmentObject(vm)
    }
}
