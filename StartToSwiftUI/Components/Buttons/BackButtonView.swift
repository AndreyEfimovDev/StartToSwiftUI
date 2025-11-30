//
//  BackButtonView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 30.11.2025.
//

import SwiftUI

struct BackButtonView: View {
    
    let completion: () -> Void
    
    var body: some View {
        
        CircleStrokeButtonView(
            iconName: "chevron.left",
            isShownCircle: false)
        {
            completion()
        }
    }
}

#Preview {
    BackButtonView() {}
}
