//
//  A003_PressableButton.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 15.03.2026.
//

import SwiftUI

// MARK: - Demo
struct A004_ShrinkingButtonForScrollViewDemo: View {
    
    @GestureState private var isPressed = false
    
    var body: some View {
        Label("PRESS ME", systemImage: "star.fill")
            .foregroundStyle(Color.mycolor.myAccent)
            .frame(maxWidth: 250)
            .frame(height: 55)
            .background(Color.mycolor.myBlue.opacity(0.3), in: .capsule)
            .padding(.horizontal)
            .scaleEffect(isPressed ? 0.85 : 1.0)
            .animation(
                isPressed
                ? .spring(response: 0.15, dampingFraction: 0.5)
                : .spring(response: 0.25, dampingFraction: 0.6),
                value: isPressed
            )
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($isPressed) { _, state, _ in state = true }
            )
            .onTapGesture {
                // your actions
            }
    }
}

struct A004_ShrinkingButtonRegularDemo: View {
    
    @GestureState private var isPressed = false
    
    var body: some View {
        Button {
            // your actions
        } label: {
            Label("PRESS ME", systemImage: "star.fill")
                .foregroundStyle(Color.mycolor.myAccent)
                .frame(maxWidth: 250)
                .frame(height: 55)
                .background(Color.mycolor.myYellow.opacity(0.3), in: .capsule)
                .padding(.horizontal)
        }
        .buttonStyle(ShrinkIconButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    A004_ShrinkingButtonForScrollViewDemo()
    A004_ShrinkingButtonRegularDemo()
}

// MARK: - Code Snippet
struct ShrinkingButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.85 : 1.0) // shrink when pressed
            .animation(.spring(response: 0.25, dampingFraction: 0.5), value: configuration.isPressed)
    }
}


