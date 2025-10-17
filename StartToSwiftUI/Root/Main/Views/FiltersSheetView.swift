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
            ZStack {
                Capsule()
                    .fill(Color.mycolor.background)
                    .overlay(
                        Capsule()
                            .stroke(Color.mycolor.accent.opacity(0.5), lineWidth: 1)
                    )
                    .frame(width: 100, height: 3)
                    .frame(height: 30, alignment: .top)
                    .padding(.bottom, 15)
                
//                HStack(alignment: .top) {
//                    Spacer()
//                    
//                    CircleStrokeButtonView(
//                        iconName: "xmark",
//                        isIconColorToChange: true,
//                        imageColorSecondary: Color.mycolor.red,
//                        isShownCircle: false) {
//                            isFilterButtonPressed.toggle()
//                        }
//                        .border(.red)
//                        .padding(8)
//                        .padding(.trailing, 8)
//                }
            }
            .padding(.top, 5)
            
            VStack (alignment: .leading) {
                Text("Filters")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .center)
                studyLevelFilter
                favoriteFilter
                languageFilter
                platformFilter
                yearFilter
                    .padding(.bottom, 50)
                resetAllFiltersButton
                resetAllFiltersAndExitButton
            }
            .foregroundStyle(Color.mycolor.accent)
            .padding(.top, -40)
            .padding()
            Spacer()
        }
        .background(.ultraThinMaterial)
        .onDisappear {
            vm.isFiltersEmpty = vm.checkIfAllFiltersAreEmpty()
            isFilterButtonPressed = false
        }
    }
    
    // MARK: VAR VIEWS
    
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
                selectedTextColor: Color.mycolor.background,
                unselectedTextColor: Color.mycolor.accent,
                selectedBackground: Color.mycolor.blue,
                unselectedBackground: .clear,
                showNilOption: true,
                nilTitle: "All"
            )
        }
    }
    
    private var favoriteFilter: some View {
        VStack {
            Text("Favorite")
                .font(.footnote)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
//            UnderlineSermentedPicker(
//                selection: $vm.selectedFavorite,
//                allItems: FavoriteChoice.allCases,
//                titleForCase: { $0.displayName },
//                selectedFont: selectedFont,
//                selectedTextColor: Color.mycolor.blue,
//                unselectedTextColor: Color.mycolor.accent,
//                showNilOption: true,
//                nilTitle: "All"
//            )
//            .padding(.horizontal, 3)
//            .background(.ultraThickMaterial)
//            .cornerRadius(3)
//            .padding(.bottom, 8)

            SegmentedOneLinePicker(
                selection: $vm.selectedFavorite,
                allItems: FavoriteChoice.allCases,
                titleForCase: { $0.displayName },
                selectedFont: selectedFont,
                selectedTextColor: Color.mycolor.background,
                unselectedTextColor: Color.mycolor.accent,
                selectedBackground: Color.mycolor.blue,
                unselectedBackground: .clear,
                showNilOption: true,
                nilTitle: "All"
            )
        }
    }
    
    private var languageFilter: some View {
        VStack {
            Text("Language:")
                .font(.footnote)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
//            UnderlineSermentedPicker(
//                selection: $vm.selectedLanguage,
//                allItems: LanguageOptions.allCases,
//                titleForCase: { $0.displayName },
//                selectedFont: selectedFont,
//                selectedTextColor: Color.mycolor.blue,
//                unselectedTextColor: Color.mycolor.accent,
//                showNilOption: true,
//                nilTitle: "All"
//            )
//            .padding(.horizontal, 3)
//            .background(.clear)
//            .cornerRadius(3)
//            .padding(.bottom, 8)
            SegmentedOneLinePicker(
                selection: $vm.selectedLanguage,
                allItems: LanguageOptions.allCases,
                titleForCase: { $0.displayName },
                selectedFont: selectedFont,
                selectedTextColor: Color.mycolor.background,
                unselectedTextColor: Color.mycolor.accent,
                selectedBackground: Color.mycolor.blue,
                unselectedBackground: .clear,
                showNilOption: true,
                nilTitle: "All"
            )
        }
    }
    
    private var platformFilter: some View {
        VStack(spacing: 0){
            Text("Platform:")
                .font(.footnote)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            SegmentedOneLinePicker(
                selection: $vm.selectedPlatform,
                allItems: Platform.allCases,
                titleForCase: { $0.displayName },
                selectedFont: selectedFont,
                selectedTextColor: Color.mycolor.background,
                unselectedTextColor: Color.mycolor.accent,
                selectedBackground: Color.mycolor.blue,
                unselectedBackground: .clear,
                showNilOption: true,
                nilTitle: "All"
            )
//            
//            UnderlineSermentedPicker(
//                selection: $vm.selectedPlatform,
//                allItems: Platform.allCases,
//                titleForCase: { $0.displayName },
//                selectedFont: selectedFont,
//                selectedTextColor: Color.mycolor.blue,
//                unselectedTextColor: Color.mycolor.accent,
//                showNilOption: true,
//                nilTitle: "All"
//            )
//            .padding(.horizontal, 3)
//            .background(.ultraThickMaterial)
//            .cornerRadius(3)
//            .padding(.bottom, 8)
        }
    }
    
    private var yearFilter: some View {
        VStack(alignment: .leading) {
            Text("Year:")
                .font(.footnote)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if let list = vm.listOfYearsInPosts {
                CustomOneCapsulesLineSegmentedPicker(
                    selection: $vm.selectedYear,
                    allItems: list,
                    titleForCase: { $0 },
                    selectedFont: selectedFont,
                    selectedTextColor: Color.mycolor.background,
                    unselectedTextColor: Color.mycolor.accent,
                    selectedBackground: Color.mycolor.blue,
                    unselectedBackground: .clear,
                    showNilOption: true,
                    nilTitle: "All"
                )
            }
        }
    }
    
    private var resetAllFiltersButton: some View {
        Button {
            vm.selectedLevel = nil
            vm.selectedFavorite = nil
            vm.selectedLanguage = nil
            vm.selectedPlatform = nil
            vm.selectedYear = nil
            updateFiltersSheetView.toggle()
        } label: {
            Text("Reset All Filters")
                .font(.headline)
                .foregroundColor(Color.mycolor.red)
                .padding(.vertical, 8)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .background(.clear)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.mycolor.blue, lineWidth: 1)
                )
        }
        .padding(.horizontal, 55)
    }
    
    private var resetAllFiltersAndExitButton: some View {
        Button {
            vm.selectedLevel = nil
            vm.selectedFavorite = nil
            vm.selectedLanguage = nil
            vm.selectedPlatform = nil
            vm.selectedYear = nil
            isFilterButtonPressed.toggle()
        } label: {
            Text("Reset All Filters and Exit")
                .font(.headline)
                .foregroundColor(Color.mycolor.red)
                .padding(.vertical, 8)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .background(.clear)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.mycolor.blue, lineWidth: 1)
                )
        }
        .padding(.horizontal, 55)
    }
}

fileprivate struct FiltersSheetPreview: View {
    
    var body: some View {
        
        ZStack {
            Color.mycolor.accent
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
        .myBackground(colorScheme: .dark)
        .environmentObject(PostsViewModel())
    }
}
