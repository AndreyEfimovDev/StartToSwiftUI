//
//  HorizontalSermentedSmoothPicker.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 31.08.2025.
//

import SwiftUI

struct UnderlineSermentedPicker<T: Hashable>: View {
    
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
    
    @Namespace private var namespace

    var body: some View {
        HStack(alignment: .top) {
            // Optional nil button
            if showNilOption {
                VStack(spacing: 5) {
                    Text(nilTitle)
                        .font(selectedFont)
                        .frame(maxWidth: .infinity)
                        .fontWeight(.medium)
                    
                    if selection == nil {
                        RoundedRectangle(cornerRadius: 2)
                            .frame(height: 1.5)
                            .matchedGeometryEffect(id: "selection", in: namespace)
                    }
                }
                .padding(.top, 8)
                .foregroundStyle(selection == nil ? selectedTextColor : unselectedTextColor)
                .background(.black.opacity(0.001))
                .onTapGesture {
                    selection = nil
                }
            }
            
            // Regular buttons for enum's values
            ForEach(allItems, id: \.self) { item in
                VStack(spacing: 5) {
                    Text(titleForCase(item))
                        .font(selectedFont)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                    
                    if selection == item {
                        RoundedRectangle(cornerRadius: 2)
                            .frame(height: 1.5)
                            .matchedGeometryEffect(id: "selection", in: namespace)
                    }
                }
                .padding(.top, 8)
                .foregroundStyle(selection == item ? selectedTextColor : unselectedTextColor)
                .background(.black.opacity(0.001))
                .onTapGesture {
                    selection = item
                }
            }
        }
        .animation(.smooth, value: selection)
    }
}

fileprivate struct UnderlineSermentedPickerPreview: View {
    
    @AppStorage("theme") private var theme: Theme?
    
    var body: some View {
        ZStack {
            Color.pink.opacity(0.5)
            
            VStack(spacing: 20) {
                
                Text("Selected theme: \(theme?.displayName ?? "None")")
                
                UnderlineSermentedPicker(
                    selection: $theme,
                    allItems: Theme.allCases,
                    titleForCase: { $0.displayName },
                    selectedTextColor: Color.mycolor.myBlue,
                    unselectedTextColor: Color.mycolor.mySecondary,
                    showNilOption: true,
                    nilTitle: "None"
                )
                .frame(height: 40)
                .padding()
            }
            .padding()
        }
    }
}

#Preview {
    UnderlineSermentedPickerPreview()
        .padding()
}
