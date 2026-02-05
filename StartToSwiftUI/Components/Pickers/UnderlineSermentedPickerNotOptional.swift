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
    
    var selectedFont: Font = .footnote
    var selectedTextColor: Color = Color.mycolor.myBlue
    var unselectedTextColor: Color = Color.mycolor.myAccent
//    var selectedBackground: Color = Color.mycolor.myRed
//    var unselectedBackground: Color = .clear
        
    @Namespace private var namespace

    var body: some View {
        
        HStack(alignment: .top) {
            ForEach(allItems, id: \.self) { item in
                let isSelected = selection == item
                
                VStack(spacing: 5) {
                    Text(titleForCase(item))
                        .font(selectedFont)
                        .fontWeight(selection == item ? .bold : .regular)
                        .frame(maxWidth: .infinity)
                    
                    if isSelected {
                        RoundedRectangle(cornerRadius: 2)
                            .frame(height: 1.5)
                            .matchedGeometryEffect(id: "selection", in: namespace)
                    } else {
                        RoundedRectangle(cornerRadius: 2)
                            .frame(height: 1.5)
                            .hidden()
                    }
                }
                .padding(.top, 8)
                .foregroundStyle(selection == item ? selectedTextColor : unselectedTextColor)
                .background(.black.opacity(0.001))
//                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selection = item
                    }
                }
                .id(item)
            }
        }
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
                unselectedTextColor: Color.mycolor.mySecondary
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
