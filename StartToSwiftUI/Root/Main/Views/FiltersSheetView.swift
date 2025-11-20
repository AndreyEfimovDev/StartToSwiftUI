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
        
        VStack {
//            drugHundler
            VStack (alignment: .leading) {
                Text("Filters")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 55)
//                categoryFilter
//                    .opacity(vm.allCategories == nil ? 0 : 1)
                studyLevelFilter
                favoriteFilter
                typeFilter
                yearFilter
                    .opacity(vm.allYears == nil ? 0 : 1)
                
                Spacer()
                
                applyFiltersButton
                resetAllFiltersButton
                resetAllFiltersAndExitButton
            }
            .foregroundStyle(Color.mycolor.myAccent)
            .padding(.top, -40)
            .padding(.horizontal)
            
            Spacer()
        }
        .background(.ultraThinMaterial)
        .onDisappear {
            vm.isFiltersEmpty = vm.checkIfAllFiltersAreEmpty()
            isFilterButtonPressed = false
        }
    }
    
    // MARK: Subviews
    
//    private var drugHundler: some View {
//        Capsule()
//            .fill(Color.mycolor.myBackground)
//            .overlay(
//                Capsule()
//                    .stroke(Color.mycolor.myAccent.opacity(0.5), lineWidth: 1)
//            )
//            .frame(width: 100, height: 3)
//            .frame(height: 30, alignment: .top)
//            .padding(.top, 10)
//            .padding(.bottom, 15)
//    }
    
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
                selectedBackground: Color.mycolor.myButtonBGBlue,
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
                selectedBackground: Color.mycolor.myButtonBGBlue,
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
                selectedBackground: Color.mycolor.myButtonBGBlue,
                unselectedBackground: .clear,
                showNilOption: true,
                nilTitle: "All"
            )
        }
    }
    
    private var yearFilter: some View {
        VStack(alignment: .leading) {
            Text("Year:")
                .font(.footnote)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if let list = vm.allYears {
                CustomOneCapsulesLineSegmentedPicker(
                    selection: $vm.selectedYear,
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
    
    private var categoryFilter: some View {
        VStack(alignment: .leading) {
            Text("Category:")
                .font(.footnote)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if let list = vm.allCategories {
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

    
    private var applyFiltersButton: some View {
        
        CapsuleButtonView(
            primaryTitle: "Apply") {
                isFilterButtonPressed.toggle()
            }
            .padding(.horizontal, 55)

    }

    private var resetAllFiltersButton: some View {
        
        
        CapsuleButtonView(
            primaryTitle: "Reset All",
            textColorPrimary: Color.mycolor.myButtonTextRed,
            buttonColorPrimary: Color.mycolor.myButtonBGRed) {
                vm.selectedLevel = nil
                vm.selectedFavorite = nil
                vm.selectedType = nil
                vm.selectedYear = nil
                updateFiltersSheetView.toggle()
            }
            .padding(.horizontal, 55)
    }
    
    private var resetAllFiltersAndExitButton: some View {
        
        
        CapsuleButtonView(
            primaryTitle: "Reset All & Exit",
            textColorPrimary: Color.mycolor.myButtonTextRed,
            buttonColorPrimary: Color.mycolor.myButtonBGRed) {
                vm.selectedLevel = nil
                vm.selectedFavorite = nil
                vm.selectedType = nil
                vm.selectedYear = nil
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
