//
//  CustomOneCapsulesLineSegmentedPicker.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 01.09.2025.
//

import SwiftUI

struct CustomOneCapsulesLineSegmentedPicker<T: Hashable>: View {
    
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
    var nilTitle: String = "All"
    
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                // Optional nil button
                if showNilOption {
                    Button {
                        withAnimation(.easeInOut) {
                            selection = nil
                        }
                    } label: {
                        Text(nilTitle)
                            .font(selectedFont).bold()
                            .foregroundColor(
                                selection == nil ? selectedTextColor : unselectedTextColor
                            )
                            .padding(.vertical, 8)
                            .frame(width: 70, height: 30)
                            .background(
                                selection == nil ? selectedBackground : unselectedBackground
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(selectedBackground, lineWidth: 1)
                            )
                            .onTapGesture {
                                selection = nil
                            }
                    }
                }
                // Regular buttons for enum's values
                ForEach(allItems, id: \.self) { selected in
                    
                    Button {
                        withAnimation(.easeInOut) {
                            selection = selected
                        }
                    } label: {
                        Text(titleForCase(selected))
                            .font(selectedFont).bold()
                            .foregroundColor(
                                selection == selected ? selectedTextColor : unselectedTextColor
                            )
                            .padding(.vertical, 8)
                            .frame(width: 70, height: 30)
                            .background(
                                selection == selected ? selectedBackground : unselectedBackground
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(selectedBackground, lineWidth: 1)
                            )
                    }
                } // ForEach
            } // HStack
            .padding(1)
        } // ScrollView
    }
}

fileprivate struct CustomOneCapsulesLineSegmentedPickerPreview: View {
    
    // Enum type
    
    @AppStorage("theme") private var theme: Theme?

    var body: some View {
        VStack(spacing: 20) {
            
            Text("Selected from Enum: \(theme?.displayName ?? "None")")

            CustomOneCapsulesLineSegmentedPicker(
                selection: $theme,
                allItems: Theme.allCases,
                titleForCase: { $0.displayName },
                selectedTextColor: .white,
                unselectedTextColor: .red,
                selectedBackground: .red,
                unselectedBackground: Color(.systemGray3),
                showNilOption: true
            )
            .frame(height: 40)
            .padding()
        }
        .padding()
    }
}


fileprivate struct CustomOneCapsulesLineSegmentedPickerPreview2: View {

    // String type
    
    @AppStorage("selectedString") var selectedForPreview: String?
    
    let listOfSelectedForPreview: [String] = ["2021", "2022", "2023", "2024", "2025", "2026"]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            
            
            VStack(spacing: 20) {
                
                Text("Selected from [Sting]: \(selectedForPreview ?? "None")")
                
                CustomOneCapsulesLineSegmentedPicker(
                    selection: $selectedForPreview,
                    allItems: listOfSelectedForPreview,
                    titleForCase: { $0 },
                    selectedTextColor: .white,
                    unselectedTextColor: .red,
                    selectedBackground: .red,
                    unselectedBackground: Color(.systemGray5),
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

fileprivate struct CustomOneCapsulesLineSegmentedPickerPreview3: View {

    // String type
    
    @AppStorage("selectedString") var selectedForPreview: String?
    
    let listOfSelectedForPreview: [String] = ["2021", "2022", "2023", "2024", "2025", "2026"]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            
            
            VStack(spacing: 20) {
                
                Text("Selected from [Sting]: \(selectedForPreview ?? "None")")
                
                CustomOneCapsulesLineSegmentedPicker(
                    selection: $selectedForPreview,
                    allItems: listOfSelectedForPreview,
                    titleForCase: { $0 },
                    selectedTextColor: .white,
                    unselectedTextColor: .red,
                    selectedBackground: .red,
                    unselectedBackground: Color(.systemGray5),
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
    VStack {
        CustomOneCapsulesLineSegmentedPickerPreview()
        CustomOneCapsulesLineSegmentedPickerPreview2()
        CustomOneCapsulesLineSegmentedPickerPreview3()

    }
}
