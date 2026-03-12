//
//  SnippetsFiltersView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.03.2026.
//

import SwiftUI

struct SnippetsFiltersView: View {

    @EnvironmentObject private var vm: SnippetsViewModel
    @Binding var isPresented: Bool

    private let selectedFont: Font = .caption.bold()

    var body: some View {
        VStack(spacing: 0) {
            Text("Filters")
                .font(.largeTitle)
                .padding(.top, 35)

            VStack(spacing: 0) {
                sortOptions
                categoryFilter
            }
            .padding(.horizontal, UIDevice.isiPad ? 15 : 0)

            Spacer()

            VStack {
                applyButton
                HStack {
                    resetButton
                    resetAndExitButton
                }
            }
            .padding(.horizontal, UIDevice.isiPad ? 90 : 30)
            .padding(.bottom, UIDevice.isiPad ? 15 : 30)
        }
        .foregroundStyle(Color.mycolor.myAccent)
        .padding(.horizontal)
        .onDisappear {
            vm.isFiltersEmpty = vm.checkIfAllFiltersAreEmpty()
            isPresented = false
        }
    }

    // MARK: - Filter Sections

    private var sortOptions: some View {
        filterSectionNonOptional(
            title: "Sort:",
            selection: $vm.selectedSortOption,
            allItems: SortOption.allCases,
            titleForCase: { $0.displayName }
        )
    }

    private var categoryFilter: some View {
        Group {
            if let list = vm.allCategories, list.count > 1 {
                filterSectionOptionalNonCaseIterable(
                    title: "Category:",
                    selection: $vm.selectedCategory,
                    allItems: list,
                    titleForCase: { $0 }
                )
            }
        }
    }

    // MARK: - Helpers

    private func filterSectionNonOptional<T: Hashable & CaseIterable>(
        title: String,
        selection: Binding<T>,
        allItems: [T],
        titleForCase: @escaping (T) -> String
    ) -> some View {
        VStack(spacing: 3) {
            sectionLabel(title)
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

    private func filterSectionOptionalNonCaseIterable<T: Hashable>(
        title: String,
        selection: Binding<T?>,
        allItems: [T],
        titleForCase: @escaping (T) -> String
    ) -> some View {
        VStack(spacing: 3) {
            sectionLabel(title)
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

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.footnote)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
    }

    // MARK: - Buttons

    private var applyButton: some View {
        ClearCupsuleButton(primaryTitle: "Apply", primaryTitleColor: Color.mycolor.myBlue) {
            isPresented.toggle()
        }
    }

    private var resetButton: some View {
        ClearCupsuleButton(primaryTitle: "Reset All", primaryTitleColor: Color.mycolor.myRed) {
            vm.resetAllFilters()
        }
    }

    private var resetAndExitButton: some View {
        ClearCupsuleButton(primaryTitle: "Reset & Exit", primaryTitleColor: Color.mycolor.myRed) {
            vm.resetAllFilters()
            isPresented.toggle()
        }
    }
}
