//
//  ClearCupsuleButton.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.10.2025.
//

import SwiftUI

struct ClearCupsuleButton: View {
    
    let primaryTitle: String
    let secondaryTitle: String
    let primaryTitleColor: Color
    let secondaryTitleColor: Color
    let isToChange: Bool // shift top secondary title and color
    let action: () -> ()
    
    init(
        primaryTitle: String,
        secondaryTitle: String = "",
        primaryTitleColor: Color = Color.mycolor.myAccent,
        secondaryTitleColor: Color = Color.mycolor.myGreen,
        isToChange: Bool = false,
        action: @escaping () -> Void
    ) {
        self.primaryTitle = primaryTitle
        self.secondaryTitle = secondaryTitle
        self.primaryTitleColor = primaryTitleColor
        self.secondaryTitleColor = secondaryTitleColor
        self.isToChange = isToChange
        self.action = action
    }

    var body: some View {
        Button {
            action()
        } label: {
            Text(isToChange ? secondaryTitle : primaryTitle)
                .font(.headline)
                .foregroundColor(isToChange ? secondaryTitleColor : primaryTitleColor)
                .padding(.vertical, 8)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .background(.clear)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.mycolor.myBlue, lineWidth: 1)
                )
        }
    }
}

#Preview {
    ClearCupsuleButton(primaryTitle: "TEST") {}
}
