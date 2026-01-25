//
//  FormSection.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.01.2026.
//

import SwiftUI

// MARK: - Form Section Component fro AddEditView

struct FormSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    private let sectionBackground = Color.mycolor.mySectionBackground
    private let sectionCornerRadius: CGFloat = 8
    private let fontSubheader: Font = .caption
    private let colorSubheader = Color.mycolor.myAccent.opacity(0.5)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .textCase(.uppercase)
                .sectionSubheaderFormater(
                    fontSubheader: fontSubheader,
                    colorSubheader: colorSubheader
                )
            
            content
                .background(
                    sectionBackground,
                    in: RoundedRectangle(cornerRadius: sectionCornerRadius)
                )
        }
    }
}

