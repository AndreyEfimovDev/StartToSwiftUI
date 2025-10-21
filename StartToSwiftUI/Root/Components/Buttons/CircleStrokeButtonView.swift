//
//  CircleButtonView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.09.2025.
//
// Customizing the appearance of symbol images in SwiftUI: https://nilcoalescing.com/blog/CustomizingTheAppearanceOfSymbolImagesInSwiftUI/
// 22 July 2024
// Natalia Panferova

import SwiftUI

struct CircleStrokeButtonView: View {
    
    let iconName: String
    let iconFont: Font
    let isIconColorToChange: Bool
    let imageColorPrimary: Color
    let imageColorSecondary: Color
    let buttonBackground: Color
    let widthIn: CGFloat
    let heightIn: CGFloat
    let isShownCircle: Bool
    let action: () -> Void
    
    init(
        iconName: String,
        iconFont: Font = .headline,
        isIconColorToChange: Bool = false,
        imageColorPrimary: Color = Color.mycolor.mySecondaryText,
        imageColorSecondary: Color = Color.mycolor.myBlue,
        buttonBackground: Color = .clear,
        widthIn: CGFloat = 30,
        heightIn: CGFloat = 30,
        isShownCircle: Bool = true,
        action: @escaping () -> Void
    ) {
        self.iconName = iconName
        self.iconFont = iconFont
        self.isIconColorToChange = isIconColorToChange
        self.imageColorPrimary = imageColorPrimary
        self.imageColorSecondary = imageColorSecondary
        self.buttonBackground = buttonBackground
        self.widthIn = widthIn
        self.heightIn = heightIn
        self.isShownCircle = isShownCircle
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: iconName)
                .font(iconFont)
                .foregroundStyle(isIconColorToChange ? imageColorSecondary : imageColorPrimary)
                .frame(width: widthIn, height: widthIn)
//                .border(.yellow)
//                .padding(8)
                .background(.black.opacity(0.001))
                .overlay(
                    Circle()
                        .fill(buttonBackground)
                        .stroke(imageColorPrimary, lineWidth: 1)
                        .opacity(isShownCircle ? 1 : 0)
                )
//                .border(.blue)
//                .border(.green)

        }
    }
}

#Preview {
    NavigationStack {
        ZStack {
            Color.yellow
            //            .ignoresSafeArea()
            VStack {
                CircleStrokeButtonView(iconName: "lines.measurement.horizontal") {
                    
                }
                CircleStrokeButtonView(iconName: "plus", isIconColorToChange: true, imageColorPrimary: Color.mycolor.myBlue, imageColorSecondary: Color.mycolor.myRed) {
                    
                }
                CircleStrokeButtonView(iconName: "plus", isIconColorToChange: false, imageColorPrimary: Color.mycolor.myBlue, imageColorSecondary: Color.mycolor.myRed) {
                    
                }
                
                CircleStrokeButtonView(iconName: "arrow.up", isIconColorToChange: false, imageColorPrimary: Color.mycolor.myBlue, imageColorSecondary: Color.mycolor.myRed, widthIn: 55, heightIn: 55) {
                    
                }
                
                List {
                    ForEach(0...50, id: \.self) { index in
                    Text("\(index)")
                    }
                }
            }
            
        }
        .navigationTitle("Header")
        .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
//                    .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                CircleStrokeButtonView(
                    iconName: "gearshape",
                    isShownCircle: false) {
                        
                    }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                
                CircleStrokeButtonView(
                    iconName: "plus",
                    isShownCircle: false) {
                        
                    }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                
                CircleStrokeButtonView(
                    iconName: "line.3.horizontal.decrease",
                    isShownCircle: false) {
                    }
            }
        }
    }
}
