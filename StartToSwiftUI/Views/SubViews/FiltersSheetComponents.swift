//
//  FiltersSheetComponents.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 28.10.2026.
//

import SwiftUI

/// Общий каркас листа фильтров: заголовок "Filters", секции фильтров
/// и кнопки Apply / Reset All / Reset All & Exit. Используется экранами
/// фильтров постов и сниппетов, чтобы они выглядели одинаково.
struct FiltersSheetLayout<Filters: View>: View {

    let onApply: () -> Void
    let onReset: () -> Void
    let onResetAndExit: () -> Void
    @ViewBuilder let filters: () -> Filters

    var body: some View {
        VStack (spacing: 0) {
            Text("Filters")
                .font(.largeTitle)
                .padding(.top, 35)

            // Filters section
                VStack(spacing: 0) {
                    filters()
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
    }

    // MARK: Buttons
    private var applyFiltersButton: some View {
        ClearCupsuleButton(primaryTitle: "Apply", primaryTitleColor: Color.mycolor.myBlue) {
            onApply()
        }
    }

    private var resetAllFiltersButton: some View {
        ClearCupsuleButton(primaryTitle: "Reset All", primaryTitleColor: Color.mycolor.myRed) {
            onReset()
        }
    }

    private var resetAllFiltersAndExitButton: some View {
        ClearCupsuleButton(primaryTitle: "Reset All & Exit", primaryTitleColor: Color.mycolor.myRed) {
            onResetAndExit()
        }
    }
}

/// Секции фильтров (подпись + однострочный пикер) для `FiltersSheetLayout`.
/// Перегрузки выбирают пикер по типу выбора: обязательный, опциональный
/// CaseIterable или опциональный произвольный список.
enum FilterSection {

    static let selectedFont: Font = .caption.bold()

    /// Секция для обязательного выбора (например, SortOption).
    static func make<T: Hashable & CaseIterable>(
        title: String,
        selection: Binding<T>,
        allItems: [T],
        titleForCase: @escaping (T) -> String
    ) -> some View {
        VStack(spacing: 3) {
            header(title)
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

    /// Секция для опционального CaseIterable-выбора (StudyLevel?, FavoriteChoice? и т.п.);
    /// `nil` показывается как "All".
    static func make<T: Hashable & CaseIterable>(
        title: String,
        selection: Binding<T?>,
        allItems: [T],
        titleForCase: @escaping (T) -> String
    ) -> some View {
        VStack(spacing: 3) {
            header(title)
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

    /// Секция для опционального выбора из произвольного списка (год, категория);
    /// `nil` показывается как "All".
    static func make<T: Hashable>(
        title: String,
        selection: Binding<T?>,
        allItems: [T],
        titleForCase: @escaping (T) -> String
    ) -> some View {
        VStack(spacing: 3) {
            header(title)
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

    /// Подпись секции над пикером.
    private static func header(_ title: String) -> some View {
        Text(title)
            .font(.footnote)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
    }
}
