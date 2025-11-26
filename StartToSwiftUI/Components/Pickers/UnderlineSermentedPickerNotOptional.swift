//
//  UnderlineSermentedPickerNotOptional.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 13.09.2025.
//

import SwiftUI

struct UnderlineSermentedPickerNotOptional<T: Hashable>: View {
    
    @Binding var selection: T
    let allItems: [T]
    let titleForCase: (T) -> String
    
    // Colors
    var selectedFont: Font = .footnote
    var selectedTextColor: Color = .white
    var unselectedTextColor: Color = .red
    var selectedBackground: Color = .red
    var unselectedBackground: Color = .clear
        
    @Namespace private var namespace

    var body: some View {
        
        HStack(alignment: .top) {
            
            ForEach(allItems, id: \.self) { item in
                VStack(spacing: 5) {
                    Text(titleForCase(item))
                        .font(selectedFont)
                        .fontWeight(selection == item ? .bold : .regular)
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
                    withAnimation {
                        selection = item
                    }
                }
            }
        }
//        .animation(.smooth, value: selection)
    }
}

fileprivate struct UnderlineSermentedPickerNotOptionalPreview: View {
    
    @State private var theme: Theme = .dark
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Selected theme: \(theme.displayName)")
            
            UnderlineSermentedPickerNotOptional(
                selection: $theme,
                allItems: Theme.allCases,
                titleForCase: { $0.displayName },
                selectedTextColor: Color.mycolor.myBlue,
                unselectedTextColor: Color.mycolor.mySecondaryText
            )
            .frame(height: 40)
            .padding()
        }
        .padding()
        .preferredColorScheme(theme.colorScheme)

    }
}

#Preview {
    UnderlineSermentedPickerNotOptionalPreview()
}
