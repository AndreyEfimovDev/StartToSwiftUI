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
    
    static let allDemoCodeSnippet: [CodeSnippet] = [a001, a002, a003, a004, a005]
    
    // MARK: - A001 Progress indicators collection
    static let a001 = CodeSnippet(
        id: "A001",
        category: Constants.mainCategory,
        title: "Progress indicators collection",
        intro: "A collection of five loading animations including wave patterns (both outward and inward), a pulsing circle, jumping dots, and a rotating ring. Demonstrates various SwiftUI animation techniques.",
        thanks: nil,
        githubUrlString: nil,
        notes: "",
        date: Date.from(year: 2026, month: 3, day: 8) ?? Date(),
        codeSnippet: """
        import SwiftUI
        import Combine
        
        // MARK: - Demo
        struct A001_ProgressViewIndicatorsDemo: View {
            
            @State private var isLoading = false
            
            var body: some View {
                VStack(spacing: 30) {
                    A001_Wave()
                    A001_PulsingCircle()
                    A001_JumpingDots()
                    A001_JumpingLetters()
                    A001_ArcProgressDinamycGapView(lineWidth: 3, diameter: 30)
                    A001_RotatingRingWithTrace()
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
        struct A001_Wave: View {
            
            @State private var scales: [CGFloat] = [0.5, 0.5, 0.5, 0.5, 0.5]
            
            var body: some View {
                HStack(spacing: 3) {
                    ForEach(0..<5, id: \\.self) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.mycolor.myBlue)
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
                                .init(color: .clear, location: 1.0),  // remove a dot
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
        """
    )
    
    // MARK: - A002 Progress Trim indicator
    static let a002 = CodeSnippet(
        id: "A002",
        category: Constants.mainCategory,
        title: "Progress Trim indicator",
        intro: "An enhanced circular progress indicator with manual +/− controls, an animated auto-increment timer, and a reset button. Demonstrates Timer integration within SwiftUI state.",
        thanks: nil,
        githubUrlString: nil,
        notes: "Timer is stored as @State var timer: Timer? so it can be invalidated on .onDisappear — preventing memory leaks when the view leaves the screen. stopTimer() is always called before startTimer() to avoid running multiple timers simultaneously.",
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
                        .frame(maxWidth: 150)
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
                        .frame(maxWidth: 150)
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
        """
    )
    
    // MARK: - A003 Progress circle with animated checkmark
    static let a003 = CodeSnippet(
        id: "A003",
        category: Constants.mainCategory,
        title: "Progress Circle with animated Checkmark",
        intro: "An interactive circular progress indicator that transforms into a spring-animated checkmark upon completion. Features multiple size/color variants, a progress slider, and auto-increment timer with pause/resume controls. Demonstrates advanced state management and coordinated animations.",
        thanks: nil,
        githubUrlString: nil,
        notes: "Uses a dynamic gap calculation based on progress: gapDegrees = gapStartDegrees * (1.0 - progress), creating a closing arc effect. The circle rotates continuously during progress (isSpinning state) with a .repeatForever linear animation. Upon reaching 100%, spinning stops and a checkmark appears with a spring animation after a slight delay. The onChange(of: isComplete) modifier orchestrates the transition between states, disabling rotation and triggering the checkmark animation. Multiple animation types are coordinated: linear rotation, spring for checkmark, and easing for opacity/scale changes.",
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
                                .foregroundColor(isRunning ? Color.mycolor.myBlue : Color.mycolor.myGreen)
                                .padding(.vertical, 8)
                                .frame(height: 55)
                                .frame(maxWidth: .infinity)
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
                                .frame(maxWidth: .infinity)
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
    
    // MARK: - A004 Shrinking Button
    static let a004 = CodeSnippet(
        id: "A004",
        category: Constants.mainCategory,
        title: "Shrinking button",
        intro: "Button with a custom shrinking effect. Two versions: regular and ScrollView-compatible. Because ScrollView absorbs touches, the regular shrinking button does not work — so we use DragGesture for the ScrollView version to avoid this effect.",
        thanks: nil,
        githubUrlString: nil,
        notes: "",
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
        - .replace with .contentTransition — smooth transition between different symbols (trash ↔ trash.slash)
        - .variableColor — WiFi symbol animation with three variations:
            * Standard variable colour
            * .iterative — sequential filling
            * .hideInactiveLayers — hides inactive segments
        """,
        thanks: nil,
        githubUrlString: nil,
        notes: "",
        date: Date.from(year: 2026, month: 3, day: 15) ?? Date(),
        codeSnippet: """
        import SwiftUI

        struct A005_SFSymbolEffectsDemo: View {
            
            @State var isAnimated: Bool = false
            
            var body: some View {
                VStack {
                    Image(systemName: "trash")
                        .font(.system(size: 50, weight: .bold))
                        .symbolEffect(.pulse, value: isAnimated)
                        .padding()

                    Image(systemName: "trash")
                        .font(.system(size: 50, weight: .bold))
                        .symbolEffect(.bounce, value: isAnimated)
                        .padding()
                                
                    HStack {
                        Image(systemName: "wifi")
                            .font(.system(size: 50, weight: .bold))
                            .symbolEffect(.variableColor, value: isAnimated)
                        Image(systemName: "wifi")
                            .font(.system(size: 50, weight: .bold))
                            .symbolEffect(.variableColor.iterative, value: isAnimated)
                        
                        Image(systemName: "wifi")
                            .font(.system(size: 50, weight: .bold))
                            .symbolEffect(.variableColor.hideInactiveLayers, value: isAnimated)
                    }
                    .padding()

                    Button {
                        isAnimated.toggle()
                    }label: {
                        Text("Animate")
                            .font(.headline)
                            .foregroundStyle(Color.mycolor.myButtonTextPrimary)
                            .padding()
                            .background(Color.mycolor.myBlue, in: .capsule)
                    }
                    .padding()

                    Image(systemName: isAnimated ? "trash.slash" : "trash")
                        .font(.system(size: 50, weight: .bold))
                        .contentTransition(.symbolEffect(.replace))
                        .padding()
                }
            }
        }

        #Preview {
            A005_SFSymbolEffectsDemo()
        }
        """
    )
    
    
}
