//
//  ColorTextPickerView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 31.08.2025.
//

import SwiftUI

// MARK: CustomOneLineSegmentedPickerForEnums
///
/// Functionality:
///
/// Supports optional values (nil)
/// Lets customize text and background colors
/// Can include a “None” option for clearing the selection
///
/// <T> where T : Hashable
///
/// init(
///  selection: Binding<T?>,
///  allCases: [T],
///  titleForCase: @escaping (Value) -> String,
///  selectedFont: Font = .body,
///  selectedTextColor: Color = .white,
///  unselectedTextColor: Color = .red,
///  selectedBackground: Color = .red,
///  unselectedBackground: Color = .clear,
///  showNilOption: Bool = true,
///  nilTitle: String = "None"
/// )
///
struct SegmentedOneLinePicker<T: Hashable>: View {
    
    @Binding var selection: T?
    let allItems: [T]
    let titleForCase: (T) -> String
    
    // Colors
    var selectedFont: Font = .footnote
    var selectedTextColor: Color = .white
    var unselectedTextColor: Color = .red
    var selectedBackground: Color = .red
    var unselectedBackground: Color = .clear
    
    // parameters for optional values
    var showNilOption: Bool = true
    var nilTitle: String = "None"
    
    var body: some View {
        HStack(spacing: 0) {
            // Optional nil button
            if showNilOption {
                Button {
                    withAnimation(.easeInOut) {
                        selection = nil
                    }
                } label: {
                    Text(nilTitle)
                        .font(selectedFont)
                        .foregroundColor(selection == nil ? selectedTextColor : unselectedTextColor)
                        .padding(.vertical, 8)
                        .frame(width: 60, height: 30)
                        .frame(maxWidth: .infinity)
                        .background(selection == nil ? selectedBackground : unselectedBackground)
                }
            }
            // Regular buttons for enum's values
            ForEach(allItems, id: \.self) { item in
                Button {
                    withAnimation(.easeInOut) {
                        selection = item
                    }
                } label: {
                    Text(titleForCase(item))
                        .font(selectedFont)
                        .foregroundColor(selection == item ? selectedTextColor : unselectedTextColor)
                        .padding(.vertical, 8)
                        .frame(width: 60, height: 30)
                        .frame(maxWidth: .infinity)
                        .background(selection == item ? selectedBackground : unselectedBackground)
                }
            } //ForEach
        } // HStack
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(selectedBackground, lineWidth: 1)
        )
    }
}

fileprivate struct CustomOneLineSegmentedPickerPreview: View {
    @AppStorage("theme") private var theme: Theme?
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Selected theme: \(theme?.displayName ?? "None")")
            
            SegmentedOneLinePicker(
                selection: $theme,
                allItems: Theme.allCases,
                titleForCase: { $0.displayName },
                selectedTextColor: .white,
                unselectedTextColor: .red,
                selectedBackground: .red,
                unselectedBackground: Color(.systemGray6),
                showNilOption: true,
                nilTitle: "None"
            )
            .frame(height: 40)
            .padding()
        }
        .padding()
    }
}



#Preview {
    CustomOneLineSegmentedPickerPreview()
}
