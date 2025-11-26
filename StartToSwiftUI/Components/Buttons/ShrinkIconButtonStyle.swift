//
//  IconButtonStyle.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.09.2025.
//

import SwiftUI

struct ShrinkIconButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.75 : 1.0) // shrink when pressed
            .animation(.spring(response: 0.25, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

struct PressableIconButtonStylePreview: View {
    var body: some View {
        
        Button {
        } label: {
            Image(systemName: "star.fill")
                .font(.title)
        }
        .buttonStyle(ShrinkIconButtonStyle())
    }
}


#Preview {
    PressableIconButtonStylePreview()
}
