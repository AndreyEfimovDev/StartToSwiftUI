//
//  AnimationTiming.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 15.03.2026.
//

import SwiftUI

struct A014_AnimationTypeDemo: View {
    @State private var isAnimating: Bool = false
    
    private let timing: Double = 3
    private let circleSize: CGFloat = 11
    private let fillColour: Color = Color.mycolor.myBlue.opacity(0.9)
    private let tracesCount = 21
    private let delayStep = 0.1
    
    // var, because it refers to the instance property timing
    private var animationStyles: [(label: String, animation: Animation)] {[
        ("spring:",    .spring(duration: timing)),
        ("linear:",    .linear(duration: timing)),
        ("easeInOut:", .easeInOut(duration: timing)),
        ("easeIn:",    .easeIn(duration: timing)),
        ("easeOut:",   .easeOut(duration: timing)),
        ("bouncy:",    .bouncy(duration: timing)),
        ("snappy:",    .snappy(duration: timing))
    ]}
    
    var body: some View {
        VStack {
            ForEach(animationStyles, id: \.label) { style in
                circleViewWithTrace(style.label, animation: style.animation)
            }
        }
        .foregroundStyle(Color.mycolor.myAccent)
        .padding()
        
        Button("Animate") {
            isAnimating.toggle()
        }
        .font(.headline)
        .foregroundStyle(Color.mycolor.myBlue)
        .padding(8)
        .background(.ultraThinMaterial, in: .capsule)
        .overlay(Capsule().stroke(Color.mycolor.myBlue, lineWidth: 1))
        .padding()
    }
    
    private func circleViewWithTrace(_ title: String, animation: Animation) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .frame(width: 80, alignment: .leading)
            
            GeometryReader { geometry in
                let maxOffset = geometry.size.width - circleSize
                
                ZStack(alignment: .leading) {
                    ForEach(0..<tracesCount, id: \.self) { index in
                        Circle()
                            .fill(fillColour.opacity(opacityForTrace(index: index)))
                            .frame(width: circleSize, height: circleSize)
                            .offset(x: isAnimating ? maxOffset : 0)
                            .animation(
                                animation.delay(Double(index) * delayStep),
                                value: isAnimating
                            )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: circleSize)
        }
    }
    
    private func opacityForTrace(index: Int) -> Double {
        return Double(tracesCount - index) / Double(tracesCount) * 0.8
    }
    
}

#Preview {
    A014_AnimationTypeDemo()
}
