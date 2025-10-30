//
//  CapsuleButtonView2.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 30.10.2025.
//

import SwiftUI

struct CapsuleButtonView2: View {
    
    let primaryTitle: String
    let secondaryTitle: String
    let textColorPrimary: Color
    let textColorSecondary: Color
    let buttonColorPrimary: Color
    let buttonColorSecondary: Color
    let isToChange: Bool
    let action: () -> ()
    
    init(
        primaryTitle: String,
        secondaryTitle: String = "",
        textColorPrimary: Color = Color.mycolor.myAccent,
        textColorSecondary: Color = Color.mycolor.mySecondaryText,
        buttonColorPrimary: Color = Color.mycolor.myBlue,
        buttonColorSecondary: Color = Color.mycolor.myGreen,
        isToChange: Bool = false,
        action: @escaping () -> Void
    ) {
        self.primaryTitle = primaryTitle
        self.secondaryTitle = secondaryTitle
        self.textColorPrimary = textColorPrimary
        self.textColorSecondary = textColorSecondary
        self.buttonColorPrimary = buttonColorPrimary
        self.buttonColorSecondary = buttonColorSecondary
        self.isToChange = isToChange
        self.action = action
    }
        
    var body: some View {
        
        Button {
            action()
        } label: {
            Text(isToChange ? secondaryTitle : primaryTitle)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(isToChange ? Color.mycolor.myAccent : Color.mycolor.myBackground)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .background(isToChange ? buttonColorSecondary : buttonColorPrimary, in: .capsule)
        }
    }
}

fileprivate struct CupsuleButtonPreview2: View {
    
    @State private var count: Int = 1
    
    var body: some View {
        
        CapsuleButtonView2(
            primaryTitle: "Primary title",
            secondaryTitle: "Secondary title",
            buttonColorPrimary: Color.mycolor.myBlue.opacity(0.7),
            buttonColorSecondary: Color.mycolor.myGreen.opacity(0.7),
            isToChange: false) {
                count += 1
            }
        
        CapsuleButtonView2(
            primaryTitle: "Primary title",
            secondaryTitle: "Secondary title",
            buttonColorPrimary: Color.mycolor.myBlue.opacity(0.7),
            buttonColorSecondary: Color.mycolor.myGreen.opacity(0.7),
            isToChange: true) {
                count += 1
            }

    }
}


#Preview {
    CupsuleButtonPreview2()
}
