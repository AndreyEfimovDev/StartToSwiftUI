//
//  A018_MeshGradient.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 28.10.2026.
//

import SwiftUI

struct A018_MeshGradientDemo: View {

    private enum Palette: CaseIterable, Identifiable {
        case sunset
        case ocean
        case aurora

        var id: Self { self }

        var title: String {
            switch self {
            case .sunset: "Sunset"
            case .ocean: "Ocean"
            case .aurora: "Aurora"
            }
        }

        /// Nine colors for the 3×3 grid, row by row from the top-left corner.
        var colors: [Color] {
            switch self {
            case .sunset:
                [.purple, .pink, .orange,
                 .indigo, .red, .orange,
                 .purple, .pink, .yellow]
            case .ocean:
                [.indigo, .blue, .cyan,
                 .blue, .teal, .mint,
                 .indigo, .cyan, .teal]
            case .aurora:
                [.black, .indigo, .black,
                 .green, .mint, .purple,
                 .indigo, .teal, .black]
            }
        }
    }

    @State private var palette: Palette = .sunset
    @State private var smoothsColors = true
    @State private var showsPoints = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // TimelineView redraws every frame, so the mesh points follow the clock.
                TimelineView(.animation) { context in
                    let points = Self.points(at: context.date.timeIntervalSinceReferenceDate)

                    MeshGradient(
                        width: 3,
                        height: 3,
                        points: points,
                        colors: palette.colors,
                        smoothsColors: smoothsColors
                    )
                    .overlay {
                        if showsPoints {
                            controlPoints(points)
                        }
                    }
                }
                .frame(height: 360)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .overlay {
                    Text("Mesh Gradient")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                        .shadow(radius: 8)
                }

                Picker("Palette", selection: $palette.animation(.easeInOut(duration: 0.6))) {
                    ForEach(Palette.allCases) { Text($0.title).tag($0) }
                }
                .pickerStyle(.segmented)

                Toggle("Smooth colors", isOn: $smoothsColors)
                Toggle("Show control points", isOn: $showsPoints)
            }
            .font(.subheadline)
            .padding()
        }
    }

    // MARK: - Points

    /// Positions of the 3×3 mesh points at the given moment.
    ///
    /// Corners stay pinned and edge points only slide along their edge,
    /// so the gradient always covers the whole rectangle.
    /// - Parameter time: Seconds, usually the timeline's current date.
    /// - Returns: Nine points in unit coordinates, row by row from the top-left corner.
    private static func points(at time: Double) -> [SIMD2<Float>] {
        // Math stays in Double: the reference-date timestamp is too large for Float precision.
        let t = time
        func point(_ x: Double, _ y: Double) -> SIMD2<Float> { [Float(x), Float(y)] }
        return [
            point(0, 0), point(0.5 + 0.3 * sin(t * 0.8), 0), point(1, 0),
            point(0, 0.5 + 0.3 * sin(t * 0.9)), point(0.5 + 0.25 * sin(t * 1.3), 0.5 + 0.25 * cos(t)), point(1, 0.5 + 0.3 * cos(t * 1.1)),
            point(0, 1), point(0.5 + 0.3 * cos(t * 0.7), 1), point(1, 1)
        ]
    }

    /// Dots marking where each mesh point currently is.
    private func controlPoints(_ points: [SIMD2<Float>]) -> some View {
        GeometryReader { proxy in
            ForEach(points.indices, id: \.self) { index in
                Circle()
                    .fill(.white)
                    .stroke(.black.opacity(0.4), lineWidth: 1)
                    .frame(width: 12, height: 12)
                    .position(
                        x: CGFloat(points[index].x) * proxy.size.width,
                        y: CGFloat(points[index].y) * proxy.size.height
                    )
            }
        }
    }
}

#Preview {
    A018_MeshGradientDemo()
}
