//
//  CircleShaddowButtonView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 12.09.2025.
//

import SwiftUI

struct CircleShadowButtonView: View {
    
    let iconName: String
    let iconFont: Font
    let isIconColorToChange: Bool
    let imageColorPrimary: Color
    let imageColorSecondary: Color
    let shadowColor: Color
    let widthIn: CGFloat
    let heightIn: CGFloat
    let widthInOut: CGFloat
    let alignmentInOut: Alignment
    let completion: () -> Void
    
    init(
        iconName: String,
        iconFont: Font = .headline,
        isIconColorToChange: Bool = false,
        imageColorPrimary: Color = Color.mycolor.mySecondaryText,
        imageColorSecondary: Color = Color.mycolor.myRed,
        shadowColor: Color = Color.mycolor.myAccent,
        widthIn: CGFloat = 35,
        heightIn: CGFloat = 35,
        widthInOut: CGFloat = 35,
        alignmentInOut: Alignment = .center,
        completion: @escaping () -> Void
    ) {
        self.iconName = iconName
        self.iconFont = iconFont
        self.isIconColorToChange = isIconColorToChange
        self.imageColorPrimary = imageColorPrimary
        self.imageColorSecondary = imageColorSecondary
        self.shadowColor = shadowColor
        self.widthIn = widthIn
        self.heightIn = heightIn
        self.widthInOut = widthInOut
        self.alignmentInOut = alignmentInOut
        self.completion = completion
    }
    
    var body: some View {
        
        Button {
            completion()
        } label: {
            Image(systemName: iconName)
                .font(iconFont)
                .foregroundStyle(isIconColorToChange ? imageColorSecondary : imageColorPrimary)
                .imageScale(.large) // .small .medium .large
                .frame(width: widthIn, height: heightIn)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .shadow(
                    color: shadowColor.opacity(0.15),
                    radius: 5
                )
                .frame(width: widthInOut, alignment: alignmentInOut)
        }
        .buttonStyle(ShrinkIconButtonStyle())
    }
}

#Preview {
    
    VStack {
        Spacer()
        CircleShadowButtonView(
            iconName: "gearshape"
        ) {}
        
        
        CircleShadowButtonView(
            iconName: "line.3.horizontal.decrease"
        ) {}
        //        Spacer()
        
        CircleShadowButtonView(
            iconName: "line.3.horizontal.decrease",
            isIconColorToChange: true
        ) {}
        //        Spacer()
        
        CircleShadowButtonView(
            iconName: "arrow.up",
            widthIn: 55,
            heightIn: 55,
            widthInOut: 80,
            alignmentInOut: .leading
        ) {}
        
        Spacer()
    }
}
