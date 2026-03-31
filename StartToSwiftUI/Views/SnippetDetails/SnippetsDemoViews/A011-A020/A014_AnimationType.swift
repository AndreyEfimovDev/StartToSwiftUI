//
//  AnimationTiming.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 15.03.2026.
//

import SwiftUI

struct A014_AnimationTypeDemo: View {
    @State var isAnimating: Bool = false
    
    private let timing: Double = 3
    private let circleSize: CGFloat = 11
    private let fillColour: Color = Color.mycolor.myBlue.opacity(0.9)
    private let tracesCount = 21
    private let delayStep = 0.1
    
    var body: some View {
        VStack {
            circleViewWithTrace("spring:", animation: .spring(duration: timing))
            circleViewWithTrace("linear:", animation: .linear(duration: timing))
            circleViewWithTrace("easeInOut:", animation: .easeInOut(duration: timing))
            circleViewWithTrace("easeIn:", animation: .easeIn(duration: timing))
            circleViewWithTrace("easeOut:", animation: .easeOut(duration: timing))
            circleViewWithTrace("bouncy:", animation: .bouncy(duration: timing))
            circleViewWithTrace("snappy:", animation: .snappy(duration: timing))
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
