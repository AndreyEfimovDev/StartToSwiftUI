//
//  SegmentedOneLinePickerNotOptional.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 13.01.2026.
//

import SwiftUI

struct SegmentedOneLinePickerNotOptional<T: Hashable>: View {
    @Binding var selection: T
    let allItems: [T]
    let titleForCase: (T) -> String
    
    // Colors
    var selectedFont: Font = .footnote
    var selectedTextColor: Color = Color.mycolor.myBackground
    var unselectedTextColor: Color = Color.mycolor.myAccent
    var selectedBackground: Color = Color.mycolor.myButtonBGBlue
    var unselectedBackground: Color = .clear
    
    var body: some View {
        HStack(spacing: 0) {
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
                        .padding(.vertical, 4)
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

fileprivate struct SegmentedOneLinePickerNotOptionalPreview: View {
    
    
    @State private var theme: Theme = .dark
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Selected theme: \(theme.displayName)")

            SegmentedOneLinePickerNotOptional(
                selection: $theme,
                allItems: Theme.allCases,
                titleForCase: { $0.displayName },
//                selectedTextColor: .white,
//                unselectedTextColor: .red,
//                selectedBackground: .red,
//                unselectedBackground: Color(.systemGray6)
            )
//            .frame(height: 40)
            .padding()
        }
        .padding()
        .preferredColorScheme(theme.colorScheme)
    }
}


#Preview {
    SegmentedOneLinePickerNotOptionalPreview()
}


