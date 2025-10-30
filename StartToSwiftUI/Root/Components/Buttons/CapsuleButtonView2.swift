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
    let textColor: Color
    let buttonColorPrimary: Color
    let buttonColorSecondary: Color
    let isToChange: Bool
    let action: () -> ()
    
    init(
        primaryTitle: String,
        secondaryTitle: String = "",
        textColor: Color = Color.mycolor.myButtonTextPrimary,
        buttonColorPrimary: Color = Color.mycolor.myButtonBGBlue,
        buttonColorSecondary: Color = Color.mycolor.myButtonBGGreen,
        isToChange: Bool = false,
        action: @escaping () -> Void
    ) {
        self.primaryTitle = primaryTitle
        self.secondaryTitle = secondaryTitle
        self.textColor = textColor
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
                .foregroundColor(textColor)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .background(
                    isToChange ? buttonColorSecondary : buttonColorPrimary,
                    in: .capsule
                )
        }
    }
}

fileprivate struct CupsuleButtonPreview2: View {
    
    @State private var count: Int = 1
    
    var body: some View {
        
        CapsuleButtonView2(
            primaryTitle: "Primary title",
            secondaryTitle: "Secondary title",
            isToChange: false) {
                count += 1
            }
        
        
        CapsuleButtonView2(
            primaryTitle: "Primary title",
            secondaryTitle: "Secondary title",
            textColor: Color.mycolor.myButtonTextPrimary,
            isToChange: true) {
                count += 1
            }
        
        CapsuleButtonView2(
            primaryTitle: "Primary title",
            secondaryTitle: "Secondary title",
            textColor: Color.mycolor.myButtonTextRed,
            buttonColorPrimary: Color.mycolor.myButtonBGRed) {
                count += 1
            }
        
        CapsuleButtonView2(
            primaryTitle: "Primary title",
            secondaryTitle: "Secondary title",
            textColor: Color.mycolor.myButtonTextSecondary,
            buttonColorPrimary: Color.mycolor.myButtonBGGray) {
                count += 1
            }

    }
}


#Preview {
    CupsuleButtonPreview2()
}
