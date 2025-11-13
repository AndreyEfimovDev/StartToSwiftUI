//
//  RotatingRingProgressView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 09.11.2025.
//

import SwiftUI

struct RotatingRingProgressView: View {
    @State private var isRotating = false
    
    var body: some View {
        Circle()
            .trim(from: 0.0, to: 0.7)
            .stroke(Color.mycolor.myBlue, lineWidth: 3)
            .frame(width: 20, height: 20)
            .rotationEffect(Angle(degrees: isRotating ? 360 : 0))
            .animation(
                .linear(duration: 1.0)
                .repeatForever(autoreverses: false),
                value: isRotating
            )
            .onAppear { isRotating = true }
    }

}

#Preview {
    RotatingRingProgressView()
}
