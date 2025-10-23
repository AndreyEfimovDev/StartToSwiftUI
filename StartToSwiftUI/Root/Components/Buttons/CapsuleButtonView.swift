//
//  CupsuleButtonView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 12.09.2025.
//

import SwiftUI

struct CapsuleButtonView: View {
    
    let primaryTitle: String
    let secondaryTitle: String
    let buttonColorPrimary: Color
    let buttonColorSecondary: Color
    let isToChangeTitle: Bool
    let action: () -> ()
    
    init(
        primaryTitle: String,
        secondaryTitle: String = "",
        buttonColorPrimary: Color = Color.mycolor.myBlue,
        buttonColorSecondary: Color = Color.mycolor.myGreen,
        isToChangeTitile: Bool = false,
        action: @escaping () -> Void
    ) {
        self.primaryTitle = primaryTitle
        self.secondaryTitle = secondaryTitle
        self.buttonColorPrimary = buttonColorPrimary
        self.buttonColorSecondary = buttonColorSecondary
        self.isToChangeTitle = isToChangeTitile
        self.action = action
    }
        
    var body: some View {
        
        Button {
            action()
        } label: {
            Text(isToChangeTitle ? secondaryTitle : primaryTitle)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(Color.mycolor.myBackground)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .background(isToChangeTitle ? buttonColorSecondary : buttonColorPrimary, in: .capsule)
        }
    }
}

fileprivate struct CupsuleButtonPreview: View {
    
    @State private var count: Int = 1
    
    var body: some View {
        
        CapsuleButtonView(
            primaryTitle: "Primary title",
            secondaryTitle: "Secondary title",
            buttonColorPrimary: .blue,
            buttonColorSecondary: .green,
            isToChangeTitile: true) {
                count += 1
            }
    }
}

#Preview {
    CupsuleButtonPreview()
}
