//
//  ArcProgressDinamicGapView.swift
//  CreateWithSwift
//
//  Created by Andrey Efimov on 12.03.2026.
//

import SwiftUI

// MARK: - Arc Progress View
//
// Winding effect: head races ahead (arc grows), tail catches up (arc shrinks).
// Both ends move strictly clockwise — zero backward motion, zero jitter.
//
// Seamless loop constraint:
//   rotationsPerCycle + (maxArc − minArc) must equal an integer.
//   At cycle boundary, the jump in `base` and the jump in `tailExtra`
//   cancel each other out exactly (both are multiples of 360°).
//
//   Here: 1.5 + 0.5 = 2 ✓

struct ArcProgressDinamicGapView: View {
    
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

// MARK: - Preview

#Preview {
    ArcProgressDinamicGapView(lineWidth: 3, diameter: 40)
}
