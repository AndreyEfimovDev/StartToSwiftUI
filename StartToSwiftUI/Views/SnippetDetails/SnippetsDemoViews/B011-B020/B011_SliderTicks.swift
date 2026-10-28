//
//  B011_SliderTicks.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 28.10.2026.
//

import SwiftUI

@available(iOS 26.0, *)
struct B011_SliderTicksDemo: View {

    private static let temperatures: [Double] = [16, 18, 20, 22, 24, 26, 28]

    @State private var brightness = 50.0
    @State private var rating = 3.0
    @State private var temperature = 22.0
    @State private var balance = 0.0
    @State private var chargeLimit = 0.8

    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                namedTicksSection
                stepTicksSection
                dataTicksSection
                neutralValueSection
                enabledBoundsSection
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }

    // MARK: - 1. Named ticks

    private var namedTicksSection: some View {
        section("Named ticks", value: "\(Int(brightness))%") {
            Slider(value: $brightness, in: 0...100) {
                Text("Brightness")
            } ticks: {
                SliderTick("Low", 0)
                SliderTick("Mid", 50)
                SliderTick("High", 100)
            }
        }
    }

    // MARK: - 2. A tick on every step

    private var stepTicksSection: some View {
        section("Tick on every step", value: String(repeating: "★", count: Int(rating))) {
            // The closure is asked for a tick at each step value; nil skips it.
            Slider(value: $rating, in: 1...5, step: 1) {
                Text("Rating")
            } tick: { value in
                SliderTick(value)
            }
        }
    }

    // MARK: - 3. Ticks from data

    private var dataTicksSection: some View {
        section("Ticks from data", value: "\(Int(temperature))°") {
            Slider(value: $temperature, in: 16...28) {
                Text("Temperature")
            } ticks: {
                SliderTickContentForEach(Self.temperatures, id: \.self) { value in
                    SliderTick(value) {
                        Text("\(Int(value))")
                    }
                }
            }
        }
    }

    // MARK: - 4. Neutral value

    private var neutralValueSection: some View {
        section("Neutral value", value: balanceText) {
            // The track fills from the neutral value (center) toward the thumb, not from the minimum.
            Slider(value: $balance, in: -1...1, neutralValue: 0) {
                Text("Balance")
            } minimumValueLabel: {
                Text("L")
            } maximumValueLabel: {
                Text("R")
            }
        }
    }

    private var balanceText: String {
        if abs(balance) < 0.01 { return "Center" }
        return balance < 0 ? "L \(Int(-balance * 100))%" : "R \(Int(balance * 100))%"
    }

    // MARK: - 5. Enabled bounds

    private var enabledBoundsSection: some View {
        section("Enabled bounds", value: "\(Int((chargeLimit * 100).rounded()))%") {
            // The full track is visible, but the thumb can only move within 50%...100%.
            // Range kept at 0...1: on iOS 26 enabledBounds with a wider range traps inside UISlider.
            Slider(value: $chargeLimit, in: 0...1, enabledBounds: 0.5...1) {
                Text("Charge limit")
            } minimumValueLabel: {
                Image(systemName: "battery.25percent")
            } maximumValueLabel: {
                Image(systemName: "battery.100percent")
            }
        }
    }

    // MARK: - Helpers

    /// A titled block with the current value on the right and a control below.
    /// - Parameters:
    ///   - title: Section title.
    ///   - value: Current value shown next to the title.
    ///   - content: The slider.
    private func section(_ title: String, value: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.mycolor.myAccent)
                Spacer()
                Text(value)
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            content()
                .tint(Color.mycolor.myBlue)
        }
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        B011_SliderTicksDemo()
    }
}
