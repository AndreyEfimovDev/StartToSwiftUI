//
//  A017_AnimatableMacro.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 28.10.2026.
//

import SwiftUI

// MARK: - Shapes

/// A star (or polygon, when innerRatio is 1) with a fractional number of points,
/// so it can morph smoothly between, say, a triangle and an eight-point burst.
///
/// Without the macro you'd hand-write the nested pair:
/// var animatableData: AnimatablePair<AnimatablePair<Double, Double>, Double>
@Animatable
struct A017_Star: Shape {
    var points: Double
    var innerRatio: Double
    var rotation: Double

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) / 2
        let inner = outer * innerRatio
        let step = .pi / points
        let vertexCount = Int((points * 2).rounded(.up))

        var path = Path()
        for i in 0..<vertexCount {
            let angle = Double(i) * step + rotation * .pi / 180 - .pi / 2
            let radius = i.isMultiple(of: 2) ? outer : inner
            let point = CGPoint(x: center.x + cos(angle) * radius, y: center.y + sin(angle) * radius)
            if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }
}

/// A sine wave whose amplitude, frequency and phase are all animatable.
@Animatable
struct A017_Wave: Shape {
    var amplitude: Double
    var frequency: Double
    var phase: Double
    // Not animatable: an Int sample count can't be interpolated, so it's excluded from animatableData.
    @AnimatableIgnored var resolution: Int = 80

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.maxY))
        for i in 0...resolution {
            let x = rect.width * Double(i) / Double(resolution)
            let relative = x / rect.width
            let y = rect.midY + sin((relative * frequency + phase) * 2 * .pi) * amplitude * rect.height / 2
            path.addLine(to: CGPoint(x: x, y: y))
        }
        path.addLine(to: CGPoint(x: rect.width, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Demo

struct A017_AnimatableMacroDemo: View {

    private enum StarPreset: CaseIterable, Identifiable {
        case triangle
        case star
        case burst

        var id: Self { self }

        var title: String {
            switch self {
            case .triangle: "Triangle"
            case .star: "Star"
            case .burst: "Burst"
            }
        }

        var points: Double {
            switch self {
            case .triangle: 3
            case .star: 5
            case .burst: 8
            }
        }

        var innerRatio: Double {
            switch self {
            case .triangle: 0.5
            case .star: 0.42
            case .burst: 0.7
            }
        }

        var rotation: Double {
            switch self {
            case .triangle: 0
            case .star: 36
            case .burst: 90
            }
        }
    }

    // MARK: - Star state
    @State private var preset: StarPreset = .star

    // MARK: - Wave state
    @State private var isStormy = false

    var body: some View {
        ScrollView {
            VStack(spacing: 50) {
                starSection
                waveSection
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }

    // MARK: - 1. Morphing star

    private var starSection: some View {
        VStack(spacing: 16) {
            sectionTitle("Three properties, one macro")

            A017_Star(points: preset.points, innerRatio: preset.innerRatio, rotation: preset.rotation)
                .fill(
                    LinearGradient(
                        colors: [Color.mycolor.myYellow, Color.mycolor.myOrange],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 200, height: 200)

            HStack(spacing: 8) {
                ForEach(StarPreset.allCases) { item in
                    Button(item.title) {
                        withAnimation(.spring(duration: 0.8, bounce: 0.4)) { preset = item }
                    }
                    .buttonStyle(.bordered)
                    .tint(preset == item ? Color.mycolor.myOrange : .secondary)
                }
            }
        }
    }

    // MARK: - 2. Endless wave

    private var waveSection: some View {
        VStack(spacing: 16) {
            sectionTitle("Spring amplitude + frequency")

            // The timeline scrolls the phase every frame; the toggle springs amplitude and frequency.
            TimelineView(.animation) { context in
                A017_Wave(
                    amplitude: isStormy ? 0.8 : 0.25,
                    frequency: isStormy ? 3 : 1.5,
                    phase: context.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 2) / 2
                )
                .fill(
                    LinearGradient(
                        colors: [Color.mycolor.myBlue, Color.mycolor.myPurple],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .frame(height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 20))

            Toggle("Stormy sea", isOn: $isStormy.animation(.spring(duration: 1, bounce: 0.3)))
                .font(.subheadline)
        }
    }

    // MARK: - Helpers

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .foregroundStyle(Color.mycolor.myAccent)
    }
}

#Preview {
    A017_AnimatableMacroDemo()
}
