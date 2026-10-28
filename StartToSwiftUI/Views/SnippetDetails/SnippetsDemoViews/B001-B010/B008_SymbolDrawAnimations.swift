//
//  B008_SymbolDrawAnimations.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 28.10.2026.
//

import SwiftUI

@available(iOS 26.0, *)
struct B008_SymbolDrawAnimationsDemo: View {

    /// How a Draw animation walks through the symbol's paths.
    private enum Granularity: CaseIterable, Identifiable {
        case wholeSymbol
        case byLayer
        case individually

        var id: Self { self }

        var title: String {
            switch self {
            case .wholeSymbol: "Whole"
            case .byLayer: "By Layer"
            case .individually: "Individually"
            }
        }

        var drawOff: DrawOffSymbolEffect {
            switch self {
            case .wholeSymbol: .drawOff.wholeSymbol
            case .byLayer: .drawOff.byLayer
            case .individually: .drawOff.individually
            }
        }
    }

    // Multi-layer symbols: on single-layer ones Whole and By Layer look the same.
    private static let drawSymbols = ["cloud.sun.rain", "wind.snow", "sun.horizon", "checklist", "pencil.and.scribble", "list.bullet"]
    private static let gradientSymbols: [(name: String, color: Color)] = [("flame.fill", .orange), ("drop.fill", .blue)]

    // MARK: - Draw On / Off state
    @State private var isErased = false
    @State private var granularity: Granularity = .byLayer

    // MARK: - Transition state
    @State private var isDone = true

    var body: some View {
        ScrollView {
            VStack(spacing: 50) {
                drawOnOffSection
                drawTransitionSection
                // A separate view: its 10 Hz updates redraw only this section, not the whole demo.
                B008_VariableDrawSection()
                gradientSection
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }

    // MARK: - 1. Draw On / Draw Off

    private var drawOnOffSection: some View {
        VStack(spacing: 16) {
            sectionTitle("Draw On / Draw Off")

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                ForEach(Self.drawSymbols, id: \.self) { name in
                    Image(systemName: name)
                        .font(.system(size: 44))
                        .foregroundStyle(Color.mycolor.myBlue)
                        // Hierarchical shading makes each layer distinguishable while it draws.
                        .symbolRenderingMode(.hierarchical)
                        // While active the symbol is "erased" stroke by stroke;
                        // deactivating plays it back, drawing the strokes in.
                        // Half speed makes the difference between granularities visible.
                        .symbolEffect(granularity.drawOff, options: .speed(0.5), isActive: isErased)
                        .frame(height: 56)
                }
            }

            Picker("Granularity", selection: $granularity) {
                ForEach(Granularity.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.segmented)

            Button(isErased ? "Draw" : "Erase") {
                isErased.toggle()
            }
            .buttonStyle(.glass)
        }
    }

    // MARK: - 2. Draw-in transition

    private var drawTransitionSection: some View {
        VStack(spacing: 16) {
            sectionTitle("Draw-in Transition")

            ZStack {
                if isDone {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 72))
                        .foregroundStyle(Color.mycolor.myGreen)
                        // Inserted symbols draw themselves in instead of fading.
                        .transition(.symbolEffect(.drawOn.individually))
                }
            }
            .frame(height: 90)

            Button(isDone ? "Reset" : "Complete") {
                withAnimation { isDone.toggle() }
            }
            .buttonStyle(.glassProminent)
            .tint(Color.mycolor.myGreen)
        }
    }

    // MARK: - 3. Gradient rendering

    private var gradientSection: some View {
        VStack(spacing: 16) {
            sectionTitle("Gradient Rendering")

            gradientRow(title: "Flat", mode: .flat)
            gradientRow(title: "Gradient", mode: .gradient)
        }
    }

    private func gradientRow(title: String, mode: SymbolColorRenderingMode) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .frame(width: 60, alignment: .leading)

            ForEach(Self.gradientSymbols, id: \.name) { symbol in
                Image(systemName: symbol.name)
                    .font(.system(size: 100))
                    .foregroundStyle(symbol.color)
                    // .gradient derives a subtle gradient from the single foreground color.
                    .symbolColorRenderingMode(mode)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Helpers

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .foregroundStyle(Color.mycolor.myAccent)
    }
}

// MARK: - Variable Draw

/// Symbols whose variable value cycles between 0 and 1, rendered with .color and .draw modes.
@available(iOS 26.0, *)
struct B008_VariableDrawSection: View {

    private static let variableSymbols = ["cellularbars", "wifi", "speaker.wave.3"]
    private static let levelSteps = 20

    @State private var levelStep = 0

    /// The variable value derived from an integer step, so it never accumulates floating-point drift.
    private var level: Double {
        Double(levelStep) / Double(Self.levelSteps)
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Variable Draw")
                .font(.headline)
                .foregroundStyle(Color.mycolor.myAccent)

            variableRow(title: "Color", mode: .color)
            variableRow(title: "Draw", mode: .draw)

            Text("variableValue: \(level, format: .number.precision(.fractionLength(2)))")
                .font(.subheadline.monospacedDigit())
        }
        .task { await cycleLevel() }
    }

    /// Ping-pongs the variable value between 0 and 1 until the view disappears.
    private func cycleLevel() async {
        var direction = 1
        while true {
            do {
                try await Task.sleep(for: .milliseconds(100))
            } catch {
                return
            }
            if levelStep + direction > Self.levelSteps || levelStep + direction < 0 {
                direction = -direction
            }
            levelStep += direction
        }
    }

    private func variableRow(title: String, mode: SymbolVariableValueMode) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .frame(width: 60, alignment: .leading)

            ForEach(Self.variableSymbols, id: \.self) { name in
                Image(systemName: name, variableValue: level)
                    .font(.system(size: 36))
                    .foregroundStyle(Color.mycolor.myOrange)
                    // .color dims inactive layers; .draw trims each layer's path by the value.
                    .symbolVariableValueMode(mode)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        B008_SymbolDrawAnimationsDemo()
    }
}
