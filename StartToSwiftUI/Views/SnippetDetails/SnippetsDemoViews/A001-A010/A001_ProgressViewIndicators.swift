//
//  A001_ProgressViewIndicators.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.03.2026.
//

import SwiftUI
import Combine

// MARK: - Demo
struct A001_ProgressViewIndicatorsDemo: View {
    
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 32) {
            HStack(spacing: 32) {
                A001_WaveSymmetrical()
                A001_WaveAsymmetrical()
            }
            A001_PulsingCircle()
            A001_JumpingDots()
            A001_JumpingLetters()
            HStack(spacing: 32) {
                A001_RotatingRingWithTrace()
                A001_ArcProgressDinamycGapView(lineWidth: 3, diameter: 30)
            }
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
            ForEach(0..<barCount, id: \.self) { index in
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
            ForEach(0..<barCount, id: \.self) { index in
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
            ForEach(0..<3, id: \.self) { index in
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
                ForEach(loadingString.indices, id: \.self) { index in
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
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.mycolor.myBlue)
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .tint(Color.mycolor.myBlue)
            .frame(width: 50, height: 50)
            
            Gauge(value: progress, in: 0...1) {
                EmptyView()
            } currentValueLabel: {
                Text("\(Int(progress * 100))%")
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
