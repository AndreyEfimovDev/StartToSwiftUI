//
//  CapsuleButtonView2.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 30.10.2025.
//

import SwiftUI

struct CapsuleButtonView: View {
    
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
        textColorPrimary: Color = Color.mycolor.myButtonTextPrimary,
        textColorSecondary: Color = Color.mycolor.myButtonTextPrimary,
        buttonColorPrimary: Color = Color.mycolor.myButtonBGBlue,
        buttonColorSecondary: Color = Color.mycolor.myButtonBGGreen,
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
                .foregroundColor(isToChange ? textColorSecondary : textColorPrimary)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .background(
                    isToChange ? buttonColorSecondary : buttonColorPrimary,
                    in: .capsule
                )
        }
    }
}

fileprivate struct CupsuleButtonPreview: View {
    
    @State private var count: Int = 1
    
    var body: some View {
        
        CapsuleButtonView(
            primaryTitle: "Primary title",
            secondaryTitle: "Secondary title",
            isToChange: false) {
                count += 1
            }
        
        
        CapsuleButtonView(
            primaryTitle: "Primary title",
            secondaryTitle: "Secondary title",
            textColorPrimary: Color.mycolor.myButtonTextPrimary,
            isToChange: true) {
                count += 1
            }
        
        CapsuleButtonView(
            primaryTitle: "Primary title",
            secondaryTitle: "Secondary title",
            textColorPrimary: Color.mycolor.myButtonTextRed,
            buttonColorPrimary: Color.mycolor.myButtonBGRed) {
                count += 1
            }
        
        
        CapsuleButtonView(
            primaryTitle: "Primary title",
            secondaryTitle: "Secondary title",
            textColorPrimary: Color.mycolor.myButtonTextRed,
            isToChange: true) {
                count += 1
            }
        
        CapsuleButtonView(
            primaryTitle: "Primary title",
            secondaryTitle: "Secondary title",
            textColorPrimary: Color.mycolor.myButtonTextSecondary,
            buttonColorPrimary: Color.mycolor.myButtonBGGray) {
                count += 1
            }

    }
}


#Preview {
    CupsuleButtonPreview()
}
