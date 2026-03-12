//
//  A003_ProgressCircleWithCheckmark.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 11.03.2026.
//

import SwiftUI

// MARK: - Demo
struct A003_ProgressCircleWithCheckmarkDemo: View {
    
    @State private var progress: Double = 0
    @State private var isRunning = false
    @State private var timer: Timer?
    
    private let durationSeconds: Double = 1.0
    private var step: Double { 0.04 / durationSeconds }
    
    var body: some View {
        VStack(spacing: 48) {
            
            // Samples with different sizes / colors
            HStack(spacing: 32) {
                A003_ProgressCircleWithCheckmarkView(progress: progress, size: 36, color: .blue)
                A003_ProgressCircleWithCheckmarkView(progress: progress, lineWidth: 6, size: 52, color: .green)
                A003_ProgressCircleWithCheckmarkView(progress: progress, lineWidth: 8, size: 72, color: .orange)
            }
            
            Text(String(format: "%.0f%%", progress * 100))
                .font(.system(size: 22, weight: .semibold, design: .monospaced))
                .foregroundStyle(.secondary)
            
            Slider(value: $progress, in: 0...1)
                .padding(.horizontal, 40)
                .tint(.green)
            
            HStack(spacing: 16) {
                
                Button {
                    isRunning ? pauseDemo() : startDemo()
                } label: {
                    Text(isRunning ? "Pause" : "Start")
                        .font(.headline)
                        .foregroundColor(isRunning ? .yellow : .green)
                        .padding(.vertical, 8)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(.thinMaterial)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.mycolor.myBlue, lineWidth: 1)
                        )
                }

                Button {
                    pauseDemo()
                    progress = 0
                } label: {
                    Text("Reset")
                        .font(.headline)
                        .foregroundColor(Color.mycolor.myRed)
                        .padding(.vertical, 8)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(.thinMaterial)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.mycolor.myBlue, lineWidth: 1)
                        )
                }
            }
        }
        .padding()
    }
    
    private func startDemo() {
        isRunning = true
        if progress >= 1 { progress = 0 }
        timer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { _ in
            if progress < 1 {
                progress = min(progress + step, 1)
            } else {
                pauseDemo()
            }
        }
    }
    
    private func pauseDemo() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        A003_ProgressCircleWithCheckmarkDemo()
    }
}

// MARK: - Code Snippet
struct A003_ProgressCircleWithCheckmarkView: View {
    
    // MARK: - Public API
    var progress: Double
    var lineWidth: CGFloat = 5
    var size: CGFloat = 52
    var color: Color = .green
    
    // MARK: - States vars
    @State private var isSpinning: Bool = false
    @State private var showCheckmark: Bool = false
    
    // MARK: - Private vars
    private let gapStartDegrees: Double = 135 // initial gap
    private var gapDegrees: Double {
        gapStartDegrees * (1.0 - min(progress, 1.0))
    }
    private var isComplete: Bool { progress >= 1.0 }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            arcView
            checkmarkView
        }
        .frame(width: size, height: size)
        .onAppear {
            isSpinning = true
        }
        .onChange(of: isComplete) { _, complete in
            if complete {
                isSpinning = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.55)) {
                        showCheckmark = true
                    }
                }
            } else {
                withAnimation(.easeOut(duration: 0.2)) {
                    showCheckmark = false
                }
                isSpinning = true
            }
        }
    }
    
    @ViewBuilder
    private var arcView: some View {
        Circle()
            .trim(from: 0, to: CGFloat((360.0 - gapDegrees) / 360.0))
            .stroke(
                color,
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
            )
            .rotationEffect(.degrees(isSpinning ? 360 : 0))
            .animation(
                isSpinning
                ? .linear(duration: 1.0).repeatForever(autoreverses: false)
                : .easeOut(duration: 0.3),
                value: isSpinning
            )
            .rotationEffect(.degrees(-90 + gapDegrees / 2))
//            .opacity(showCheckmark ? 0 : 1) // uncomment to hide the circle when completed
            .animation(.easeInOut(duration: 0.35), value: gapDegrees)
            .animation(.easeOut(duration: 0.3), value: showCheckmark)
    }
    
    @ViewBuilder
    private var checkmarkView: some View {
        Image(systemName: "checkmark")
            .font(.system(size: size * 0.42, weight: .bold))
            .foregroundStyle(color)
            .scaleEffect(showCheckmark ? 1 : 0.3)
            .opacity(showCheckmark ? 1 : 0)
    }
}
