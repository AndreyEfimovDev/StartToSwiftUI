//
//  SnippetsRepository.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 09.03.2026.
//
//  Single source of truth for all code snippets.
//  To add a new snippet:
//  1. Create DemoView in SnippetsDemoViews/ (e.g. A003_...)
//  2. Add a case in SnippetViewRegistry
//  3. Add a CodeSnippet entry here

import Foundation

struct SnippetsRepository {

    static let all: [CodeSnippet] = [a001, a002, a003]

    // MARK: - A001
    static let a001 = CodeSnippet(
        id: "A001",
        category: Constants.mainCategory,
        title: "Loading Indicators Collection",
        intro: "A collection of five loading animations including wave patterns (both outward and inward), a pulsing circle, jumping dots, and a rotating ring. Demonstrates various SwiftUI animation techniques.",
        thanks: nil,
        githubUrlString: nil,
        notes: "",
        date: Date.from(year: 2026, month: 3, day: 8) ?? Date(),
        codeSnippet: """
        import SwiftUI
        
        struct A001_ProgressViewIndicators: View {
            
            @State private var isLoading = false
            
            var body: some View {
                VStack(spacing: 30) {
                    toggleButton
            
                    if isLoading {
                        VStack(spacing: 30) {
                            A001_WaveOut()
                            A001_WaveIn()
                            A001_PulsingCircle()
                            A001_JumpingDots()
                            A001_RotatingRing()
                        }
                    }
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
                    ForEach(0..<5, id: \\.self) { index in
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
                    ForEach(0..<5, id: \\.self) { index in
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
                    ForEach(0..<3, id: \\.self) { index in
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
        """
    )

    // MARK: - A002
    static let a002 = CodeSnippet(
        id: "A002",
        category: Constants.mainCategory,
        title: "Progressive Trim Indicators",
        intro: "An enhanced circular progress indicator with manual +/− controls, an animated auto-increment timer, and a reset button. Demonstrates Timer integration within SwiftUI state.",
        thanks: nil,
        githubUrlString: nil,
        notes: "Timer is stored as @State var timer: Timer? so it can be invalidated on .onDisappear — preventing memory leaks when the view leaves the screen. stopTimer() is always called before startTimer() to avoid running multiple timers simultaneously.",
        date: Date.from(year: 2026, month: 3, day: 9) ?? Date(),
        codeSnippet: """
        import SwiftUI

        struct A002_TrimIndicator: View {
            
            @State private var proportion: CGFloat = 0.0
            @State private var startProgressIndicator = false
            @State private var buttonCaption = "Start"
            @State private var timer: Timer? = nil
            private let frameSize: CGFloat = 150.0
            
            var body: some View {
                VStack {
                    A002_ProgressIndicator(trim: $proportion)
                        .frame(width: frameSize, height: frameSize)
                        .padding()
                    
                    HStack {
                        plusButton
                        minusButton
                    }.padding()
                    
                    actionButton
                    resetButton
                }
                .onDisappear {
                    stopTimer()
                }
            }
            
            private func startTimer() {
                stopTimer()
                
                timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                    proportion += 0.01
                    if proportion > 1 {
                        proportion = 0
                    }
                }
            }
            
            private func stopTimer() {
                timer?.invalidate()
                timer = nil
            }
            
            private var plusButton: some View {
                Button("+") {
                    if proportion != 0 && timer != nil {
                        startProgressIndicator = false
                        buttonCaption = buttonCaption == "Start" ? "Stop" : "Start"
                    }
                    proportion += 0.1
                    proportion = min(proportion,1)
                }
                .padding()
                .background(.black.opacity(0.03))
                .clipShape(.circle)
            }
            
            private var minusButton: some View {
                Button("-") {
                    if proportion != 0 && timer != nil {
                        startProgressIndicator = false
                        buttonCaption = buttonCaption == "Start" ? "Stop" : "Start"
                    }
                    proportion -= 0.1
                    proportion = max(self.proportion,0)
                }
                .padding()
                .background(.black.opacity(0.03))
                .clipShape(.circle)
            }
            
            private var actionButton: some View {
                Button(buttonCaption) {
                    switch buttonCaption {
                    case "Start":
                        startProgressIndicator = true
                        startTimer()
                    case "Stop" :
                        startProgressIndicator = false
                        stopTimer()
                    default: break
                    }
                    buttonCaption = buttonCaption == "Start" ? "Stop" : "Start"
                }
                .padding()
                .frame(maxWidth: 150)
                .background(.black.opacity(0.03))
                .clipShape(.capsule)
            }
            
            private var resetButton: some View {
                Button("Reset") {
                    stopTimer()
                    startProgressIndicator = false
                    buttonCaption = "Start"
                    proportion = 0.0
                }
                .a002_formater(frameSize: frameSize)
            }
        }

        struct A002_ProgressIndicator: View {
            
            @Binding var trim: CGFloat
            let lineWidth: CGFloat = 15.0
            
            var body: some View {
                ZStack {
                    Circle()
                        .stroke(lineWidth: lineWidth)
                        .opacity(0.3)
                        .foregroundColor(Color.green)
                    
                    Circle()
                        .trim(from: 0, to: self.trim)
                        .stroke(style: StrokeStyle(
                            lineWidth: lineWidth,
                            lineCap: .round,
                            lineJoin: .round))
                        .foregroundColor(Color.green)
                        .rotationEffect(Angle(degrees: -90))
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        Text(String(format: "%.0f", trim * 100))
                        Text("%")
                            .font(.caption2)
                    }
                    .font(.headline)
                    .foregroundColor(Color.red)
                }
            }
        }

        extension View {
            func a002_formater (frameSize: CGFloat) -> some View {
                self
                    .padding()
                    .frame(maxWidth: frameSize)
                    .background(Color.mycolor.myButtonBGGray)
                    .clipShape(.capsule)
            }
        }

        #Preview {
            A002_TrimIndicator()
        }
        """
    )
    
    // MARK: - A003
    static let a003 = CodeSnippet(
        id: "A003",
        category: Constants.mainCategory,
        title: "Progress Circle with Animated Checkmark",
        intro: "An interactive circular progress indicator that transforms into a spring-animated checkmark upon completion. Features multiple size/color variants, a progress slider, and auto-increment timer with pause/resume controls. Demonstrates advanced state management and coordinated animations.",
        thanks: nil,
        githubUrlString: nil,
        notes: "Uses a dynamic gap calculation based on progress: gapDegrees = gapStartDegrees * (1.0 - progress), creating a closing arc effect. The circle rotates continuously during progress (isSpinning state) with a .repeatForever linear animation. Upon reaching 100%, spinning stops and a checkmark appears with a spring animation after a slight delay. The onChange(of: isComplete) modifier orchestrates the transition between states, disabling rotation and triggering the checkmark animation. Multiple animation types are coordinated: linear rotation, spring for checkmark, and easing for opacity/scale changes.",
        date: Date.from(year: 2026, month: 3, day: 9) ?? Date(),
        codeSnippet: """
        import SwiftUI

        struct A003_ProgressCircleWithCheckmark: View {
            
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
                        Button(isRunning ? "Pause" : "Auto") {
                            isRunning ? pauseDemo() : startDemo()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        
                        Button("Reset") {
                            pauseDemo()
                            progress = 0
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
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

        // MARK: - Preview / Demo
        #Preview {
            A003_ProgressCircleWithCheckmark()
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
        """
    )

}
