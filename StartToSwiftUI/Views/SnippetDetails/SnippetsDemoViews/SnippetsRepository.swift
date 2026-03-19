//
//  SnippetsRepository.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 09.03.2026.
//
//  Single source of truth for all code snippets.
//  To add a new snippet:
//  1. Create DemoView in SnippetsDemoViews/ (e.g. A001_...)
//  2. Add a case in SnippetViewRegistry
//  3. Add a CodeSnippet entry here

import Foundation

struct SnippetsRepository {
    
    static let allDemoCodeSnippet: [CodeSnippet] = [a001, a002, a003, a004, a005, a006]
    
    // MARK: - A001 Progress indicators collection
    static let a001 = CodeSnippet(
        id: "A001",
        category: Constants.mainCategory,
        title: "Progress indicators collection",
        intro: """
        A collection of custom loading animations in SwiftUI:
        - Wave patterns — symmetrical & asymmetrical (sine-based)
        - Pulsing circle — scale & opacity
        - Jumping dots & letters — sequential bounce
        - Rotating ring with trace and dinamyc gap - gradient & rotation
        - Dynamic gap arc — winding effect with TimelineView & Canvas
        - Gauge progress — native gauges with percentage updates
        
        Techniques: Timer publishers, phase animations, staggered delays, TimelineView, Canvas drawing, state-driven animations, and native gauges.
        """,
        thanks: nil,
        date: Date.from(year: 2026, month: 3, day: 8) ?? Date(),
        codeSnippet: """
        import SwiftUI
        import Combine

        // MARK: - Demo
        struct A001_ProgressViewIndicatorsDemo: View {
            
            @State private var isLoading = false
            
            var body: some View {
                VStack(spacing: 16) {
                    A001_WaveSymmetrical()
                    A001_WaveAsymmetrical()
                    A001_PulsingCircle()
                    A001_JumpingDots()
                    A001_JumpingLetters()
                    A001_RotatingRingWithTrace()
                    A001_ArcProgressDinamycGapView(lineWidth: 3, diameter: 30)
                    A001_GaugeProgress()
                }
            }
        }

        // MARK: - Preview
        #Preview {
            NavigationStack {
                A001_ProgressViewIndicatorsDemo()
            }
        }

        // MARK: - Code Snippets
        struct A001_WaveSymmetrical: View {
            /*
             - states contains 4 frames, %4 gives an infinite loop
             - duration: 0.45 slightly less than the timer interval of 0.5 — the animation manages to finish before the next step
             */
            private let barCount = 5
            private let maxHeight: CGFloat = 30
            private let minHeight: CGFloat = 3
            
            @State private var phase: CGFloat = 0
            @State private var cancellable: AnyCancellable? = nil
            
            // the distance of each stick from the center: [2, 1, 0, 1, 2]
            private let distancesFromCenter: [CGFloat] = [2, 1, 0, 1, 2]
            
            var body: some View {
                HStack(spacing: 3) {
                    ForEach(0..<barCount, id: \\.self) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.mycolor.myBlue)
                            .frame(width: 3, height: barHeight(for: index))
                            .frame(height: maxHeight)
                            .clipped()
                            .animation(.linear(duration: 0.08), value: phase)
                    }
                }
                .onAppear {
                    cancellable = Timer
                        .publish(every: 0.08, on: .main, in: .common)
                        .autoconnect()
                        .sink { _ in
                            /*
                             The bigger the step, the faster the wave. You can vary it:
                             0.1 — slow
                             0.15 is normal
                             0.3 — fast
                             0.5 is very fast
                             */
                            phase += 0.3
                        }
                }
                .onDisappear {
                    // cancel the timer publisher to prevent memory leak
                    cancellable?.cancel()
                    cancellable = nil
                }
            }
            
            private func barHeight(for index: Int) -> CGFloat {
                // symmetry: the same distance from the center = the same height
                let angle = phase + distancesFromCenter[index] * (.pi / 2)
                let normalized = (sin(angle) + 1) / 2  // 0...1
                return minHeight + normalized * (maxHeight - minHeight)
            }
        }

        struct A001_WaveAsymmetrical: View {
            /*
             How it works:
             - phase increments every 0.15seconds — the wave shifts from left to right
             - sin() gives a smooth wave, * (.pi /3) is the step between adjacent sticks of 90°, i.e. 4 sticks = a full cycle
             - normalized translates sin from -1...1 to 0...1, then scale to minHeight...maxHeight
             
             You can play with the angle pitch.:
             - .pi/3 is a more gentle wave
             - .pi/2 is a steep wave (fast transition)
             */
            
            private let barCount = 5
            private let maxHeight: CGFloat = 30
            private let minHeight: CGFloat = 3
            
            @State private var phase: CGFloat = 0
            @State private var cancellable: AnyCancellable? = nil
            
            var body: some View {
                HStack(spacing: 3) {
                    ForEach(0..<barCount, id: \\.self) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.mycolor.myBlue)
                            .frame(width: 3, height: barHeight(for: index))
                            .frame(height: maxHeight)
                            .animation(.easeInOut(duration: 0.3), value: phase)
                    }
                }
                .onAppear {
                    cancellable = Timer
                        .publish(every: 0.08, on: .main, in: .common)
                        .autoconnect()
                        .sink { _ in
                            phase += 0.4
                        }
                }
                .onDisappear {
                    // cancel the timer publisher to prevent memory leak
                    cancellable?.cancel()
                    cancellable = nil
                }
            }
            
            private func barHeight(for index: Int) -> CGFloat {
                let angle = (CGFloat(index) - phase) * (.pi / 3)
                let normalized = (sin(angle) + 1) / 2  // 0...1
                return minHeight + normalized * (maxHeight - minHeight)
            }
        }


        struct A001_PulsingCircle: View {
            @State private var scale: CGFloat = 0.5
            
            var body: some View {
                Circle()
                    .fill(Color.mycolor.myBlue)
                    .frame(width: 16, height: 16)
                    .scaleEffect(scale)
                    .opacity((1.4 - min(scale, 1)))
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                            scale = 1.5
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
                            .fill(Color.mycolor.myBlue)
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

        struct A001_JumpingLetters: View {
            
            @State private var counter: Int = 0
            @State private var cancellable: AnyCancellable?
            
            private let loadingString: [String] = "........... loading ...........".map { String($0) }
            
            // MARK: BODY
            var body: some View {
                ZStack {
                    HStack(spacing: 0) {
                        ForEach(loadingString.indices, id: \\.self) { index in
                            Text(loadingString[index])
                                .font(.headline)
                                .offset(y: counter == index ? -11 : 0)
                        }
                    }
                    .font(.subheadline)
                }
                .foregroundColor(Color.mycolor.myBlue)
                .onAppear {
                    cancellable = Timer
                        .publish(every: 0.1, on: .main, in: .common)
                        .autoconnect()
                        .sink { _ in
                            withAnimation {
                                counter = (counter + 1) % loadingString.count
                            }
                        }
                }
                .onDisappear {
                    cancellable?.cancel()
                    cancellable = nil
                }
            }
        }

        struct A001_RotatingRingWithTrace: View {
            @State private var isRotating = false
            
            var body: some View {
                Circle()
                    .trim(from: 0.0, to: 0.7)
                    .stroke(
                        AngularGradient(
                            stops: [
                                .init(color: .clear, location: 0.0),  // tail
                                .init(color: Color.mycolor.myBlue.opacity(0.3), location: 0.3),  // trace
                                .init(color: Color.mycolor.myBlue, location: 0.7),  // head
                                .init(color: .clear, location: 1.0),  // remove a dot at the end of the tail
                            ],
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 30, height: 30)
                    .rotationEffect(Angle(degrees: isRotating ? 360 : 0))
                    .animation(
                        .linear(duration: 1.0)
                        .repeatForever(autoreverses: false),
                        value: isRotating
                    )
                    .onAppear { isRotating = true }
                    .overlay {
                        Text("A")
                            .font(.headline)
                            .foregroundStyle(Color.mycolor.myBlue)
                    }
            }
        }

        /// Winding effect: head races ahead (arc grows), tail catches up (arc shrinks).
        /// Both ends move strictly clockwise — zero backward motion, zero jitter.
        ///
        /// Seamless loop constraint:
        ///   rotationsPerCycle + (maxArc − minArc) must equal an integer.
        ///   At cycle boundary, the jump in `base` and the jump in `tailExtra`
        ///   cancel each other out exactly (both are multiples of 360°).
        ///
        ///   Here: 1.5 + 0.5 = 2 ✓
        struct A001_ArcProgressDinamycGapView: View {
            
            var lineWidth: CGFloat = 3
            var diameter: CGFloat = 40
            var color: Color = Color.mycolor.myBlue
            var cycleDuration: Double = 1.4
            
            // Arc length bounds — difference MUST equal frac(rotationsPerCycle)
            private let minArc: Double = 0.01   // smallest arc  (0–1 fraction of circle)
            private let maxArc: Double = 0.56   // largest  arc  0.56 − 0.06 = 0.50 ✓
            private let rotationsPerCycle: Double = 1.5  // 1.5 mod 1 = 0.5 ✓
            
            @State private var startDate = Date()
            
            var body: some View {
                TimelineView(.animation) { timeline in
                    let elapsed = timeline.date.timeIntervalSince(startDate)
                    let phase = (elapsed / cycleDuration)
                        .truncatingRemainder(dividingBy: 1.0)
                    arcCanvas(phase: phase)
                }
                .onAppear { startDate = Date() }
            }
            
            // MARK: - Easing
            
            private func easeInOut(_ t: Double) -> Double {
                t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2
            }
            
            // MARK: - Angle calculation
            
            private func angles(for phase: Double) -> (start: Double, end: Double) {
                let spread = (maxArc - minArc) * 360   // degrees the arc grows by = 180°
                
                // Base rotation: linear, 0 → rotationsPerCycle*360 over one cycle
                let base = phase * rotationsPerCycle * 360
                
                // Phase 0.0 → 0.5 : head races ahead (arc grows), tail is parked
                // Phase 0.5 → 1.0 : head is parked, tail catches up (arc shrinks)
                let headExtra: Double = phase < 0.5
                ? easeInOut(phase * 2) * spread
                : spread
                
                let tailExtra: Double = phase < 0.5
                ? 0
                : easeInOut((phase - 0.5) * 2) * spread
                
                // At phase ≈ 1 → 0 transition:
                //   base jumps   by −rotationsPerCycle*360 = −540°
                //   tailExtra jumps by −spread             = −180°
                //   total jump = −720° ≡ 0  (mod 360°)  → perfectly seamless ✓
                
                let startAngle = base + tailExtra - 90
                let endAngle   = base + minArc * 360 + headExtra - 90
                return (startAngle, endAngle)
            }
            
            // MARK: - Canvas
            
            @ViewBuilder
            private func arcCanvas(phase: Double) -> some View {
                let (startDeg, endDeg) = angles(for: phase)
                /* Canvas context parameters:
                 context.stroke(path, with: .color(.red), style: ...) - tracing the path
                 context.fill(path, with: .color(.blue)) - filling
                 context.draw(image, at: point) - drawing an image
                 context.opacity - current transparency
                 context.transform - current transformation
                 */
                Canvas { context, size in
                    let center = CGPoint(x: size.width / 2, y: size.height / 2)
                    let radius = (min(size.width, size.height) - lineWidth) / 2
                    
                    var path = Path()
                    path.addArc(
                        center: center,
                        radius: radius,
                        startAngle: .degrees(startDeg),
                        endAngle:   .degrees(endDeg),
                        clockwise: false
                    )
                    context.stroke(
                        path,
                        with: .color(color),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                }
                .frame(width: diameter, height: diameter)
            }
        }

        struct A001_GaugeProgress: View {
            
            @State private var progress: Double = 0
            @State private var cancellable: AnyCancellable? = nil
            
            var body: some View {
                HStack(spacing: 20) {
                    Gauge(value: progress, in: 0...1) {
                        EmptyView()
                    } currentValueLabel: {
                        Text("\\(Int(progress * 100))%")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.mycolor.myBlue)
                    }
                    .gaugeStyle(.accessoryCircularCapacity)
                    .tint(Color.mycolor.myBlue)
                    .frame(width: 50, height: 50)
                    
                    Gauge(value: progress, in: 0...1) {
                        EmptyView()
                    } currentValueLabel: {
                        Text("\\(Int(progress * 100))%")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.mycolor.myBlue)
                    }
                    .gaugeStyle(.accessoryCircular)
                    .tint(Color.mycolor.myBlue)
                    .frame(width: 50, height: 50)
                }
                .onAppear {
                    cancellable = Timer
                        .publish(every: 0.05, on: .main, in: .common)
                        .autoconnect()
                        .sink { _ in
                            progress = progress >= 1.0 ? 0.0 : min(progress + 0.01, 1.0)
                        }
                }
                .onDisappear {
                    // cancel the timer publisher to prevent memory leak
                    cancellable?.cancel()
                    cancellable = nil
                }
            }
        }
        """
    )
    
    // MARK: - A002 Progress Trim indicator
    static let a002 = CodeSnippet(
        id: "A002",
        category: Constants.mainCategory,
        title: "Progress Trim indicator",
        intro: "An enhanced circular progress indicator with manual +/− controls, an animated auto-increment timer, and a reset button. Demonstrates Timer integration within SwiftUI state.",
        thanks: nil,
        date: Date.from(year: 2026, month: 3, day: 9) ?? Date(),
        codeSnippet: """
        import SwiftUI

        // MARK: - Demo
        struct A002_TrimIndicatorDemo: View {
            
            @State private var proportion: CGFloat = 0.0
            @State private var startProgressIndicator = false
            @State private var buttonCaption = "Start"
            @State private var timer: Timer? = nil
            private let frameSize: CGFloat = 150.0
            
            var body: some View {
                VStack {
                    A002_ProgressIndicatorView(trim: $proportion)
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
                Button {
                    if proportion != 0 && timer != nil {
                        startProgressIndicator = false
                        buttonCaption = buttonCaption == "Start" ? "Stop" : "Start"
                    }
                    proportion += 0.1
                    proportion = min(proportion,1)
                } label: {
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundStyle(Color.mycolor.myBlue)
                        .frame(width: 55, height: 55)
                        .background(.ultraThinMaterial, in: Circle())
                        .overlay(Circle().stroke(Color.mycolor.myBlue, lineWidth: 1))
                }
            }
            
            private var minusButton: some View {
                Button {
                    if proportion != 0 && timer != nil {
                        startProgressIndicator = false
                        buttonCaption = buttonCaption == "Start" ? "Stop" : "Start"
                    }
                    proportion -= 0.1
                    proportion = max(self.proportion,0)
                } label: {
                    Image(systemName: "minus")
                        .font(.headline)
                        .foregroundStyle(Color.mycolor.myBlue)
                        .frame(width: 55, height: 55)
                        .background(.ultraThinMaterial, in: Circle())
                        .overlay(Circle().stroke(Color.mycolor.myBlue, lineWidth: 1))
                }
            }
            
            private var actionButton: some View {
                Button {
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
                } label: {
                    Text(buttonCaption)
                        .font(.headline)
                        .foregroundColor(startProgressIndicator ? Color.mycolor.myBlue : Color.mycolor.myGreen)
                        .padding(.vertical, 8)
                        .frame(height: 55)
                        .frame(width: 150)
                        .background(.thinMaterial)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.mycolor.myBlue, lineWidth: 1))
                }
            }
            
            private var resetButton: some View {
                Button {
                    stopTimer()
                    startProgressIndicator = false
                    buttonCaption = "Start"
                    proportion = 0.0
                } label: {
                    Text("Reset")
                        .font(.headline)
                        .foregroundColor(Color.mycolor.myRed)
                        .padding(.vertical, 8)
                        .frame(height: 55)
                        .frame(width: 150)
                        .background(.thinMaterial)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.mycolor.myBlue, lineWidth: 1))
                }
            }
        }

        // MARK: - Preview
        #Preview {
            NavigationStack {
                A002_TrimIndicatorDemo()
            }
        }

        // MARK: - Code Snippet
        struct A002_ProgressIndicatorView: View {
            
            @Binding var trim: CGFloat
            let lineWidth: CGFloat = 15.0
            
            var body: some View {
                ZStack {
                    Circle()
                        .stroke(lineWidth: lineWidth)
                        .opacity(0.3)
                        .foregroundColor(Color.mycolor.myGreen)
                    
                    Circle()
                        .trim(from: 0, to: self.trim)
                        .stroke(style: StrokeStyle(
                            lineWidth: lineWidth,
                            lineCap: .round,
                            lineJoin: .round))
                        .foregroundColor(Color.mycolor.myGreen)
                        .rotationEffect(Angle(degrees: -90))
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        Text(String(format: "%.0f", trim * 100))
                        Text("%")
                            .font(.caption2)
                    }
                    .font(.headline)
                    .foregroundColor(Color.mycolor.myRed)
                }
            }
        }
        """
    )
    
    // MARK: - A003 Progress circle with animated checkmark
    static let a003 = CodeSnippet(
        id: "A003",
        category: Constants.mainCategory,
        title: "Progress Circle with animated Checkmark",
        intro: "An interactive circular progress indicator that transforms into a spring-animated checkmark upon completion. Features multiple size/color variants, a progress slider, and auto-increment timer with pause/resume controls. Demonstrates advanced state management and coordinated animations.",
        thanks: nil,
        date: Date.from(year: 2026, month: 3, day: 9) ?? Date(),
        codeSnippet: """
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
                        A003_ProgressCircleWithCheckmarkView(progress: progress, size: 36, color: Color.mycolor.myBlue)
                        A003_ProgressCircleWithCheckmarkView(progress: progress, lineWidth: 6, size: 52, color: Color.mycolor.myGreen)
                        A003_ProgressCircleWithCheckmarkView(progress: progress, lineWidth: 8, size: 72, color: Color.mycolor.myOrange)
                    }
                    
                    Text(String(format: "%.0f%%", progress * 100))
                        .font(.system(size: 22, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.secondary)
                    
                    Slider(value: $progress, in: 0...1)
                        .padding(.horizontal, 40)
                        .tint(Color.mycolor.myGreen)
                    
                    HStack(spacing: 16) {
                        Button {
                            isRunning ? pauseDemo() : startDemo()
                        } label: {
                            Text(isRunning ? "Pause" : "Start")
                                .font(.headline)
                                .foregroundColor(isRunning ? Color.mycolor.myBlue : Color.mycolor.myGreen)
                                .padding(.vertical, 8)
                                .frame(height: 55)
                                .frame(width: 150)
                                .background(.ultraThinMaterial, in: Capsule())
                                .overlay(Capsule().stroke(Color.mycolor.myBlue, lineWidth: 1))
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
                                .frame(width: 150)
                                .background(.ultraThinMaterial, in: Capsule())
                                .overlay(Capsule().stroke(Color.mycolor.myBlue, lineWidth: 1))
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
            var color: Color = Color.mycolor.myGreen
            
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
    
    // MARK: - A004 Shrinking Button
    static let a004 = CodeSnippet(
        id: "A004",
        category: Constants.mainCategory,
        title: "Shrinking button",
        intro: "Button with a custom shrinking effect. Two versions: regular and ScrollView-compatible. Because ScrollView absorbs touches, the regular shrinking button does not work — so we use DragGesture for the ScrollView version to avoid this effect.",
        thanks: nil,
        date: Date.from(year: 2026, month: 3, day: 15) ?? Date(),
        codeSnippet: """
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
        """
    )
    
    // MARK: - A005 SF Symbol Animation Effects
    static let a005 = CodeSnippet(
        id: "A005",
        category: Constants.mainCategory,
        title: "SF Symbol built-in animation effects",
        intro: """
        This code showcases various symbol effect modifiers:
        - .pulse — gentle opacity pulsing
        - .bounce — playful scaling animation
        - .replace with .contentTransition — smooth transition between different symbols (microphone ↔ microphone.slash)
        - Antenna Radiowaves symbol animation with three variations:
            * .variableColor - animation of the opacity of variable layers in a repeatable sequence
            * .variableColor.iterative — sequential filling
            * .variableColor.hideInactiveLayers — hides inactive segments
        """,
        thanks: nil,
        date: Date.from(year: 2026, month: 3, day: 15) ?? Date(),
        codeSnippet: """
        import SwiftUI

        struct A005_SFSymbolEffectsDemo: View {
            
            @State var isAnimated: Bool = false
            
            var body: some View {
                VStack {
                    Group {
                        Image(systemName: isAnimated ? "microphone.slash.fill" : "microphone.fill")
                            .font(.system(size: 50, weight: .bold))
                            .contentTransition(.symbolEffect(.replace))
                            .padding()
                        
                        HStack {
                            Image(systemName: "sun.max.fill")
                                .font(.system(size: 50, weight: .bold))
                                .symbolEffect(.pulse, value: isAnimated)
                            Image(systemName: "sun.max.fill")
                                .font(.system(size: 50, weight: .bold))
                                .symbolEffect(.bounce, value: isAnimated)
                        }
                        .padding()
                        
                        HStack {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                                .font(.system(size: 50, weight: .bold))
                                .symbolEffect(.variableColor, value: isAnimated)
                            Image(systemName: "antenna.radiowaves.left.and.right")
                                .font(.system(size: 50, weight: .bold))
                                .symbolEffect(.variableColor.iterative, value: isAnimated)
                            Image(systemName: "antenna.radiowaves.left.and.right")
                                .font(.system(size: 50, weight: .bold))
                                .symbolEffect(.variableColor.hideInactiveLayers, value: isAnimated)
                        }
                    }
                    .foregroundStyle(Color.mycolor.myAccent.opacity(0.8))
                    .padding()
                    
                    Button {
                        isAnimated.toggle()
                    }label: {
                        Text("Animate")
                            .font(.headline)
                            .foregroundStyle(Color.mycolor.myBlue)
                            .padding()
                            .background(.ultraThinMaterial, in: .capsule)
                            .overlay(Capsule().stroke(Color.mycolor.myBlue, lineWidth: 1))
                    }
                    .padding()
                }
            }
        }

        #Preview {
            A005_SFSymbolEffectsDemo()
        }
        """
    )
    
    // MARK: - A006 Frame Transition
    static let a006 = CodeSnippet(
        id: "A006",
        category: Constants.mainCategory,
        title: "Frame Transition",
        intro: """
        This code demonstrates four different frame transition:
        - Bottom-Bottom — standard sheet behaviour
        - Bottom-Right — enters from bottom, exits to the right
        - Right-Right — slides in/out from the right edge
        - Slider — slider-style navigation
        
        Each transition is implemented using .offset modifier with different combinations of enter/exit directions.
        """,
        thanks: nil,
        date: Date.from(year: 2026, month: 3, day: 16) ?? Date(),
        codeSnippet: """
        import SwiftUI

        struct A006_FrameTransitionDemo: View {
            
            @State private var selectedTab: FrameTab = .bottomBottom
            
            enum FrameTab: CaseIterable {
                case bottomBottom, bottomRight, rightRight, sliderStyle
            }

            var body: some View {
                GeometryReader { geo in
                    
                    let availableHeight = geo.size.height * 0.5
                    let availableWidth = geo.size.width
                    
                    VStack(spacing: 0) {
                        
                        A006_SegmentedOneLinePickerNotOptional(
                            selection: $selectedTab,
                            allItems: FrameTab.allCases,
                            titleForCase: { tab in
                                switch tab {
                                case .bottomBottom: return "↑↓"
                                case .bottomRight:  return "↑→"
                                case .rightRight:   return "←→"
                                case .sliderStyle:       return "←←"
                                }
                            }
                        )
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        switch selectedTab {
                            // bottom in, bottom out
                        case .bottomBottom: A006_FrameBottomTransition(height: availableHeight)
                            // bottom in, right out
                        case .bottomRight:  A006_FrameBottomRightTransition(height: availableHeight, width: availableWidth)
                            // right in, right out
                        case .rightRight:   A006_FrameRightRightTransition(height: availableHeight)
                            // right in, left out (slider)
                        case .sliderStyle:       A006_FrameSliderTransition(height: availableHeight, width: availableWidth)
                        }
                    }
                }
            }
        }

        #Preview {
            A006_FrameTransitionDemo()
        }

        struct A006_FrameBottomTransition: View {
            
            @State private var showView: Bool = false
            
            let height: CGFloat
            
            var body: some View {
                ZStack(alignment: .bottom) {
                    VStack {
                        Button {
                            showView.toggle()
                        }
                        label: {
                            Text("Animate Bottom-Bottom")
                                .font(.headline)
                                .foregroundStyle(Color.mycolor.myRed)
                                .padding()
                                .background(.ultraThinMaterial, in: .capsule)
                                .overlay(Capsule().stroke(Color.mycolor.myRed, lineWidth: 1))
                        }
                        Spacer()
                    }
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.mycolor.myRed.A006_verticalGradient())
                        .frame(height: height)
                        .offset(y: showView ? 0 : height)
                        .animation(.easeInOut(duration: 0.5), value: showView)
                }
                .padding(.top)
                .edgesIgnoringSafeArea(.bottom)
            }
        }

        struct A006_FrameBottomRightTransition: View {
            /*
             Logic:
             - Initial offset = width — hidden behind the right edge
             - Appearance → offset = 0 (moves from right to left)
             - Disappearance → offset = -width (moves left)
             - asyncAfter resets the offset back to width while the view is hidden
             */
            @State private var showView: Bool = false
            @State private var offset: CGSize
            
            let height: CGFloat
            let width: CGFloat
            
            private let duration: Double = 0.5
            
            init(height: CGFloat, width: CGFloat) {
                    self.height = height
                    self.width = width
                    _offset = State(initialValue: CGSize(width: 0, height: height))
                }

            var body: some View {
                ZStack(alignment: .bottom) {
                    VStack {
                        Button {
                            if !showView {
                                // appearance from the bottom
                                showView = true
                                withAnimation(.easeInOut(duration: duration)) {
                                    offset = .zero
                                }
                            } else {
                                // disappearance to the right
                                withAnimation(.easeInOut(duration: duration)) {
                                    offset = CGSize(width: width, height: 0)
                                }
                                // resetting the position back down after disappearing
                                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                                    showView = false
                                    offset = CGSize(width: 0, height: height)
                                }
                            }
                        } label: {
                            Text("Animate Bottom-Right")
                                .font(.headline)
                                .foregroundStyle(Color.mycolor.myGreen)
                                .padding()
                                .background(.ultraThinMaterial, in: .capsule)
                                .overlay(Capsule().stroke(Color.mycolor.myGreen, lineWidth: 1))
                        }
                        Spacer()
                    }
                    
                    if showView {
                        UnevenRoundedRectangle(cornerRadii: .init(
                            topLeading: 30,
                            topTrailing: 30
                        ))
                        .fill(Color.mycolor.myGreen.A006_verticalGradient())
                        .frame(height: height)
                        .offset(offset)
                    }
                }
                .padding(.top)
                .edgesIgnoringSafeArea(.bottom)
            }
        }

        struct A006_FrameRightRightTransition: View {
            
            @State private var showView: Bool = false
            
            let height: CGFloat

            var body: some View {
                ZStack(alignment: .bottom) {
                    VStack {
                        Button {
                            showView.toggle()
                        } label: {
                            Text("Animate Right-Right")
                                .foregroundStyle(Color.mycolor.myOrange)
                                .font(.headline)
                                .padding()
                                .background(.ultraThinMaterial, in: .capsule)
                                .overlay(Capsule().stroke(Color.mycolor.myOrange, lineWidth: 1))
                        }
                        Spacer()
                    }
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.mycolor.myOrange.A006_verticalGradient())
                        .frame(height: height)
                        .offset(x: showView ? 0 : UIScreen.main.bounds.width) // from right to left
                        .animation(.easeInOut(duration: 0.5), value: showView)
                }
                .padding(.top)
                .edgesIgnoringSafeArea(.bottom)
            }
        }

        struct A006_FrameSliderTransition: View {
            
            @State private var showView: Bool = false
            @State private var offset: CGSize

            let height: CGFloat
            let width: CGFloat
            
            private let duration: Double = 0.5
            
            init(height: CGFloat, width: CGFloat) {
                    self.height = height
                    self.width = width
                    _offset = State(initialValue: CGSize(width: 0, height: height))
                }
            
            var body: some View {
                ZStack(alignment: .bottom) {
                    VStack {
                        Button {
                            if !showView {
                                // appearance from the right
                                showView = true
                                withAnimation(.easeInOut(duration: duration)) {
                                    offset = .zero
                                }
                            } else {
                                // disappearance to the left
                                withAnimation(.easeInOut(duration: duration)) {
                                    offset = CGSize(width: -width, height: 0)
                                }
                                // reset position back to the right after disappearing
                                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                                    showView = false
                                    offset = CGSize(width: width, height: 0)
                                }
                            }
                        } label: {
                            Text("Animate Slider")
                                .foregroundStyle(Color.mycolor.myPurple)
                                .font(.headline)
                                .padding()
                                .background(.ultraThinMaterial, in: .capsule)
                                .overlay(Capsule().stroke(Color.mycolor.myPurple, lineWidth: 1))
                        }
                        Spacer()
                    }
                    
                    if showView {
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.mycolor.myPurple.A006_verticalGradient())
                            .frame(height: height)
                            .offset(offset)
                    }
                }
                .padding(.top)
                .edgesIgnoringSafeArea(.bottom)
            }
        }

        extension Color {
            func A006_verticalGradient() -> LinearGradient {
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: self.opacity(0.1), location: 0.0),
                        .init(color: self.opacity(0.3), location: 0.3),
                        .init(color: self.opacity(0.7), location: 0.7),
                        .init(color: self.opacity(1.0), location: 1.0)
                    ]),
                    startPoint: .bottom,
                    endPoint: .top
                )
            }
        }

        struct A006_SegmentedOneLinePickerNotOptional<T: Hashable>: View {
            @Binding var selection: T
            let allItems: [T]
            let titleForCase: (T) -> String
            
            // Colors
            var selectedFont: Font = .footnote
            var selectedTextColor: Color = Color.mycolor.myBackground
            var unselectedTextColor: Color = Color.mycolor.myAccent
            var selectedBackground: Color = Color.mycolor.myButtonBGBlue
            var unselectedBackground: Color = .clear
            
            var body: some View {
                HStack(spacing: 0) {
                    // Regular buttons for enum's values
                    ForEach(allItems, id: \\.self) { item in
                        Button {
                            withAnimation(.easeInOut) {
                                selection = item
                            }
                        } label: {
                            Text(titleForCase(item))
                                .font(selectedFont)
                                .foregroundColor(selection == item ? selectedTextColor : unselectedTextColor)
                                .frame(width: 60, height: 30)
                                .frame(maxWidth: .infinity)
                                .background(selection == item ? selectedBackground : unselectedBackground)
                        }
                    } //ForEach
                } // HStack
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(selectedBackground, lineWidth: 1)
                )
            }
        }
        """
    )

}
