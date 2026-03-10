//
//  A001_ProgressViewIndicators.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.03.2026.
//

import SwiftUI

struct A001_ProgressViewIndicators: View {
    
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 30) {
            if isLoading {
                VStack(spacing: 30) {
                    A001_WaveOut()
                    A001_WaveIn()
                    A001_PulsingCircle()
                    A001_JumpingDots()
                    A001_RotatingRing()
                }
            }
            toggleButton
        }
    }
    
    private var toggleButton: some View {
        Button {
            isLoading.toggle()
        } label: {
            Text(isLoading ? "Stop" : "Start")
                .font(.headline)
                .foregroundStyle(isLoading ? Color.mycolor.myRed : Color.mycolor.myBlue)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(.capsule)
                .padding(.horizontal)
        }
    }
}

struct A001_WaveOut: View {
    
    @State private var scales: [CGFloat] = [0.5, 0.5, 0.5, 0.5, 0.5]
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<5, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.blue)
                    .frame(width: 3, height: 12 * scales[index])
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.1), value: scales[index])
            }
        }
        .onAppear {
            for i in 0..<scales.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                    scales[i] = 1.0
                }
            }
        }
    }
}

struct A001_WaveIn: View {
    
    @State private var animate = false
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<5, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.blue)
                    .frame(width: 3, height: animate ? 16 : 8)
                    .animation(
                        .easeInOut(duration: 0.5)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.1), value: animate)
            }
        }
        .onAppear {
            animate = true
        }
    }
}

struct A001_PulsingCircle: View {
    @State private var scale: CGFloat = 0.5
    
    var body: some View {
        Circle()
            .fill(Color.blue)
            .frame(width: 16, height: 16)
            .scaleEffect(scale)
            .opacity(max(scale, 1))
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    scale = 1
                }
            }
    }
}

struct A001_JumpingDots: View {
    @State private var scale: [Bool] = [false, false, false]
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(.blue)
                    .frame(width: 6, height: 6)
                    .scaleEffect(scale[index] ? 1.0 : 0.5)
            }
        }
        .frame(width: 8, height: 8)
        .onAppear { startDotAnimation() }
    }
    
    private func startDotAnimation() {
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    scale[i] = true
                }
            }
        }
    }

}

struct A001_RotatingRing: View {
    @State private var isRotating = false
    
    var body: some View {
        Circle()
            .trim(from: 0.0, to: 0.7)
            .stroke(Color.blue, lineWidth: 3)
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
    A001_ProgressViewIndicators()
}
