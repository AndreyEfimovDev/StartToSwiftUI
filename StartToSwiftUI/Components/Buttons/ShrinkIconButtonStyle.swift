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
            .scaleEffect(configuration.isPressed ? 0.85 : 1.0) // shrink when pressed
//            .animation(
//                configuration.isPressed
//                ? .spring(response: 0.15, dampingFraction: 0.5)
//                : .spring(response: 0.25, dampingFraction: 0.6),
//                value: configuration.isPressed
//            )
            .animation(.spring(response: 0.25, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

struct ShrinkPressableIconButtonStylePreview: View {
    var body: some View {
        
        Button {
        } label: {
            Label("PRESS ME", systemImage: "star.fill")
            .frame(maxWidth: 250)
            .frame(height: 55)
            .background(.yellow, in: .capsule)
            .padding(.horizontal)
        }
        .buttonStyle(ShrinkIconButtonStyle())
    }
}

#Preview {
    ShrinkPressableIconButtonStylePreview()
}
