//
//  A019_TextRenderer.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 28.10.2026.
//

import SwiftUI

// MARK: - Renderers

/// Reveals glyphs one after another: each fades in, rises and sharpens.
/// `elapsed` is the animatable value — animating it from 0 plays the reveal.
struct A019_AppearRenderer: TextRenderer {
    var elapsed: TimeInterval
    var glyphDelay: TimeInterval = 0.04
    var glyphDuration: TimeInterval = 0.5

    var animatableData: Double {
        get { elapsed }
        set { elapsed = newValue }
    }

    // Extra room so risen and blurred glyphs aren't clipped.
    var displayPadding: EdgeInsets {
        EdgeInsets(top: 16, leading: 8, bottom: 16, trailing: 8)
    }

    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        var index = 0
        for line in layout {
            for run in line {
                for glyph in run {
                    let start = Double(index) * glyphDelay
                    let progress = min(max((elapsed - start) / glyphDuration, 0), 1)

                    var copy = ctx
                    copy.opacity = progress
                    copy.translateBy(x: 0, y: (1 - progress) * 16)
                    copy.addFilter(.blur(radius: (1 - progress) * 6))
                    copy.draw(glyph)
                    index += 1
                }
            }
        }
    }
}

/// Moves every glyph along a sine wave driven by the current time.
struct A019_WaveRenderer: TextRenderer {
    var time: TimeInterval
    var amplitude: CGFloat = 6

    var displayPadding: EdgeInsets {
        EdgeInsets(top: amplitude, leading: 0, bottom: amplitude, trailing: 0)
    }

    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        var index = 0
        for line in layout {
            for run in line {
                for glyph in run {
                    var copy = ctx
                    copy.translateBy(x: 0, y: sin(time * 4 + Double(index) * 0.5) * amplitude)
                    copy.draw(glyph)
                    index += 1
                }
            }
        }
    }
}

/// Marks the part of a Text that A019_EmphasisRenderer should animate.
struct A019_Emphasis: TextAttribute {}

/// Draws plain runs as is and makes runs marked with A019_Emphasis bounce and shift hue.
struct A019_EmphasisRenderer: TextRenderer {
    var time: TimeInterval

    var displayPadding: EdgeInsets {
        EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0)
    }

    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        for line in layout {
            for run in line {
                // A run carries the custom attribute it was built with.
                guard run[A019_Emphasis.self] != nil else {
                    ctx.draw(run)
                    continue
                }
                var emphasized = ctx
                emphasized.addFilter(.hueRotation(.degrees(time * 90)))
                for (index, glyph) in run.enumerated() {
                    var copy = emphasized
                    copy.translateBy(x: 0, y: -abs(sin(time * 3 + Double(index) * 0.35)) * 10)
                    copy.draw(glyph)
                }
            }
        }
    }
}

// MARK: - Demo

struct A019_TextRendererDemo: View {

    private static let message = "Every glyph has its own entrance"
    private static let appearDuration = Double(message.count) * 0.04 + 0.5

    @State private var elapsed: TimeInterval = 0
    // Each tap bumps the counter; .task(id:) restarts the reveal from the beginning.
    @State private var replayCount = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 50) {
                appearSection
                waveSection
                emphasisSection
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }

    // MARK: - 1. Glyph-by-glyph reveal

    private var appearSection: some View {
        VStack(spacing: 16) {
            sectionTitle("Glyph-by-glyph reveal")

            Text(Self.message)
                .font(.title.bold())
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.mycolor.myPurple)
                .textRenderer(A019_AppearRenderer(elapsed: elapsed))
                .task(id: replayCount) { await playReveal() }

            Button("Replay") { replayCount += 1 }
                .buttonStyle(.bordered)
        }
    }

    /// Resets the reveal, then animates it to the end.
    private func playReveal() async {
        elapsed = 0
        // Let the reset render first, otherwise both changes merge and nothing animates.
        do {
            try await Task.sleep(for: .milliseconds(50))
        } catch {
            return
        }
        withAnimation(.linear(duration: Self.appearDuration)) {
            elapsed = Self.appearDuration
        }
    }

    // MARK: - 2. Wave

    private var waveSection: some View {
        VStack(spacing: 16) {
            sectionTitle("Wave")

            TimelineView(.animation) { context in
                Text("Riding the sine wave")
                    .font(.title2.weight(.heavy))
                    .foregroundStyle(Color.mycolor.myBlue)
                    .textRenderer(A019_WaveRenderer(time: context.date.timeIntervalSinceReferenceDate))
            }
        }
    }

    // MARK: - 3. Custom attribute

    private var emphasisSection: some View {
        VStack(spacing: 16) {
            sectionTitle("Animate only part of a Text")

            TimelineView(.animation) { context in
                Text("Make \(Text("these words").customAttribute(A019_Emphasis()).foregroundStyle(Color.mycolor.myRed)) stand out")
                    .font(.title2.bold())
                    .textRenderer(A019_EmphasisRenderer(time: context.date.timeIntervalSinceReferenceDate))
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

#Preview {
    A019_TextRendererDemo()
}
