//
//  AnimationTiming.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 15.03.2026.
//

import SwiftUI

struct A014_AnimationTypeDemo: View {
    @State private var isAnimating: Bool = false
    @State private var isFinished: Bool = false

    private let timing: Double = 3
    private let circleSize: CGFloat = 11
    private let fillColour: Color = Color.mycolor.myBlue.opacity(0.9)
    private let tracesCount = 21
    private let delayStep = 0.1

    private var animationStyles: [(label: String, animation: Animation)] {[
        ("spring:",    .spring(duration: timing)),
        ("linear:",    .linear(duration: timing)),
        ("easeInOut:", .easeInOut(duration: timing)),
        ("easeIn:",    .easeIn(duration: timing)),
        ("easeOut:",   .easeOut(duration: timing)),
        ("bouncy:",    .bouncy(duration: timing)),
        ("snappy:",    .snappy(duration: timing))
    ]}

    // Total time of the last circle: duration + all delays
    private var totalDuration: Double {
        timing + Double(tracesCount - 1) * delayStep
    }

    var body: some View {
        VStack {
            ForEach(animationStyles, id: \.label) { style in
                circleViewWithTrace(style.label, animation: style.animation)
            }
        }
        .foregroundStyle(Color.mycolor.myAccent)
        .padding()

        Button(isFinished ? "Reset" : "Animate") {
            if isFinished {
                // Instant reset without animation
                isAnimating = false
                isFinished = false
            } else {
                isAnimating = true
                // We are waiting for the end of the last circle
                DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
                    isFinished = true
                }
            }
        }
        .font(.headline)
        .foregroundStyle(isFinished ? Color.mycolor.myRed : Color.mycolor.myBlue)
        .padding(8)
        .frame(width: 150)
        .background(.ultraThinMaterial, in: .capsule)
        .overlay(
            Capsule()
                .stroke(isFinished ? Color.mycolor.myRed : Color.mycolor.myBlue, lineWidth: 1)
        )
        .padding()
        .opacity(!isAnimating || isFinished ? 1 : 0)
        .animation(.easeInOut(duration: 0.25), value: isFinished)
    }

    private func circleViewWithTrace(_ title: String, animation: Animation) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .frame(width: 80, alignment: .leading)

            GeometryReader { geometry in
                let maxOffset = geometry.size.width - circleSize

                ZStack(alignment: .leading) {
                    ForEach((0..<tracesCount).reversed(), id: \.self) { index in
                        Circle()
                            .fill(fillColour.opacity(opacityForTrace(index: index)))
                            .frame(width: circleSize, height: circleSize)
                            .offset(x: isAnimating ? maxOffset : 0)
                            .animation(
                                // Animation only when moving to the right, reset is instant
                                isAnimating ? animation.delay(Double(index) * delayStep) : .none,
                                value: isAnimating
                            )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: circleSize)
            .clipped()
        }
    }

    private func opacityForTrace(index: Int) -> Double {
        Double(tracesCount - index) / Double(tracesCount) * 0.8
    }
}

#Preview {
    A014_AnimationTypeDemo()
}
