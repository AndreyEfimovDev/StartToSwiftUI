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
//                .padding(.top, 55)
#warning("Remove before deployment to App Store")
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
//        .padding(.top, -40)
        .padding(.horizontal)
        .onDisappear {
            vm.isFiltersEmpty = vm.checkIfAllFiltersAreEmpty()
            isFilterButtonPressed = false
        }
    }
    
    // MARK: Subviews
    
    @ViewBuilder
    private func formatedFilterTitle(_ title: String) -> some View {
        Text(title)
            .font(.footnote)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
    }
    
    private var sortOptions: some View {
        VStack {
            formatedFilterTitle("Sort:")
            
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
            formatedFilterTitle("Study level:")
            
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
            formatedFilterTitle("Favorite:")
            
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
            formatedFilterTitle("Post type:")
            
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
            formatedFilterTitle("Media:")
            
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
                    formatedFilterTitle("Year:")
                    
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
                    formatedFilterTitle("Category:")

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
    
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppSyncState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let context = ModelContext(container)
    
    let vm = PostsViewModel(
        dataSource: MockPostsDataSource(posts: PreviewData.samplePosts)
//        fbPostsManager: MockFBPostsManager()
    )
    ZStack {
        FiltersView(
            isFilterButtonPressed: .constant(true)
        )
        .environmentObject(vm)
    }
}
