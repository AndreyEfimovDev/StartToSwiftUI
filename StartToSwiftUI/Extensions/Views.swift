//
//  MyBackground.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 30.08.2025.
//

import Foundation
import SwiftUI


// MARK: CUSTOM BACKGROUND

extension View {
    func myBackground(colorScheme: ColorScheme) -> some View {
        self
            .background(.thinMaterial)
//            .ignoresSafeArea()
    }
}


extension View {
    func mySsectionBackground() -> some View {
        self
            .background(Color.mycolor.mySectionBackground)
            .cornerRadius(8)
    }
}


extension View {
    func managingPostsTextFormater() -> some View {
        self
            .font(.callout)
            .foregroundStyle(Color.mycolor.myAccent)
            .multilineTextAlignment(.center)
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.mycolor.myAccent.opacity(0.3), lineWidth: 1)
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
    
    func customPreferencesListRowStyle(iconName: String, iconWidth: CGFloat) -> some View {
        HStack {
            Image(systemName: iconName)
                .frame(width: iconWidth)
                .foregroundStyle(Color.mycolor.myBlue)
            
            self
        }
    }
}





