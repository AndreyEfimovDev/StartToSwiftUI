//
//  BackButtonView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 30.11.2025.
//

import SwiftUI

struct BackButtonView: View {
    
    let iconName: String
    let completion: () -> Void
    
    init(
        iconName: String = "chevron.left",
        completion: @escaping () -> Void
    ) {
        self.iconName = iconName
        self.completion = completion
    }
    
    var body: some View {
        
        CircleStrokeButtonView(
            iconName: iconName,
            isShownCircle: false)
        {
            completion()
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        BackButtonView() {}
        BackButtonView(iconName: "xmark") {}
    }
}
