//
//  B010_ConcentricCorners.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 28.10.2026.
//

import SwiftUI

@available(iOS 26.0, *)
struct B010_ConcentricCornersDemo: View {

    // MARK: - Comparison state
    @State private var outerRadius: CGFloat = 40
    @State private var inset: CGFloat = 12
    @State private var keepsMinimum = false

    var body: some View {
        ScrollView {
            VStack(spacing: 50) {
                comparisonSection
                mixedCornersSection
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }

    // MARK: - 1. Fixed vs Concentric

    private var comparisonSection: some View {
        VStack(spacing: 16) {
            sectionTitle("Fixed vs Concentric")

            HStack(spacing: 16) {
                comparisonTile(title: "Fixed radius") {
                    // Same radius as the container: the inner corners look too round.
                    RoundedRectangle(cornerRadius: outerRadius)
                        .fill(Color.mycolor.myRed.gradient)
                }
                comparisonTile(title: "Concentric") {
                    // Radius = container radius − inset, so both curves share one center.
                    ConcentricRectangle(corners: innerCorners)
                        .fill(Color.mycolor.myGreen.gradient)
                }
            }

            VStack(spacing: 8) {
                LabeledContent("Container radius") {
                    Slider(value: $outerRadius, in: 16...70)
                }
                LabeledContent("Inset") {
                    Slider(value: $inset, in: 4...40)
                }
                Toggle("Minimum radius 10", isOn: $keepsMinimum)
            }
            .font(.subheadline)
        }
    }

    /// Without a minimum, a large inset makes concentric corners shrink to square.
    private var innerCorners: Edge.Corner.Style {
        keepsMinimum ? .concentric(minimum: 10) : .concentric
    }

    /// A container with the given inner shape inset by the current padding.
    /// - Parameters:
    ///   - title: Caption below the tile.
    ///   - inner: The shape drawn inside the container.
    private func comparisonTile(title: String, @ViewBuilder inner: () -> some View) -> some View {
        VStack(spacing: 8) {
            inner()
                .padding(inset)
                // Concentric shapes inside read their corners from this container shape.
                .containerShape(RoundedRectangle(cornerRadius: outerRadius))
                .background(RoundedRectangle(cornerRadius: outerRadius).fill(.quaternary))
                .frame(height: 160)

            Text(title)
                .font(.caption)
        }
    }

    // MARK: - 2. Mixed corner styles

    private var mixedCornersSection: some View {
        VStack(spacing: 16) {
            sectionTitle("Mixed corner styles")

            VStack(spacing: 8) {
                // Top corners follow the card; bottom corners stay small, next to the buttons.
                ConcentricRectangle(uniformTopCorners: .concentric, uniformBottomCorners: .fixed(8))
                    .fill(
                        LinearGradient(
                            colors: [Color.mycolor.myBlue, Color.mycolor.myPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        Image("A_1024x1024_PhosphateInline_3477F5_text")
                            .resizable()
                            .frame(width: 96, height: 96)
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                            .shadow(radius: 10)
                    }
                    .frame(height: 180)

                HStack(spacing: 8) {
                    cardButton(
                        "Share",
                        systemImage: "square.and.arrow.up",
                        shape: ConcentricRectangle(
                            topLeadingCorner: .fixed(8),
                            topTrailingCorner: .fixed(8),
                            bottomLeadingCorner: .concentric,
                            bottomTrailingCorner: .fixed(8)
                        )
                    )
                    cardButton(
                        "Save",
                        systemImage: "heart",
                        shape: ConcentricRectangle(
                            topLeadingCorner: .fixed(8),
                            topTrailingCorner: .fixed(8),
                            bottomLeadingCorner: .fixed(8),
                            bottomTrailingCorner: .concentric
                        )
                    )
                }
            }
            .padding(8)
            .containerShape(RoundedRectangle(cornerRadius: 32))
            .background(RoundedRectangle(cornerRadius: 32).fill(.quaternary))
        }
    }

    /// A full-width button whose background uses the given concentric shape.
    /// - Parameters:
    ///   - title: Button title.
    ///   - systemImage: SF Symbol name.
    ///   - shape: Background shape; its outer corner follows the card.
    private func cardButton(_ title: String, systemImage: String, shape: ConcentricRectangle) -> some View {
        Button {} label: {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(shape.fill(.background))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .foregroundStyle(Color.mycolor.myAccent)
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        B010_ConcentricCornersDemo()
    }
}
