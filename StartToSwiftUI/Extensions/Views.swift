//
//  MyBackground.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 30.08.2025.
//

import Foundation
import SwiftUI


// MARK: CUSTOM BACKGROUND

//extension View {
//    func myBackground(colorScheme: ColorScheme) -> some View {
//        self
//            .background(.thinMaterial)
////            .ignoresSafeArea()
//    }
//}


extension View {
    func mySsectionBackground() -> some View {
        self
            .background(Color.mycolor.mySectionBackground)
            .cornerRadius(8)
    }
}

extension View {
    func menuFormater(
        cornerRadius: CGFloat = 30,
        borderColor: Color = Color.mycolor.myAccent,
        lineWidth: CGFloat = 1
    ) -> some View {
        self
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor.opacity(0.3), lineWidth: lineWidth)
            )

    }
}


    

extension View {
    func textFormater(
        cornerRadius: CGFloat = 30,
        borderColor: Color = Color.mycolor.myAccent,
        lineWidth: CGFloat = 1
    ) -> some View {
        self
            .font(.callout)
            .foregroundStyle(borderColor)
            .multilineTextAlignment(.center)
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor.opacity(0.3), lineWidth: lineWidth)
            )
    }
}

extension View {
    func sectionSubheaderFormater(fontSubheader: Font, colorSubheader: Color) -> some View {
        self
            .font(fontSubheader)
            .bold()
            .foregroundStyle(colorSubheader)
            .padding(5)
//            .padding(.leading, 5)
//            .padding(.bottom, 5)

    }
}

// MARK: - View Modifier for styling Preferences List Rows

extension View {
    
    func customListRowStyle(iconName: String, iconWidth: CGFloat) -> some View {
        HStack {
            Image(systemName: iconName)
                .frame(width: iconWidth)
                .foregroundStyle(Color.mycolor.myBlue)
            
            self
        }
    }
}





