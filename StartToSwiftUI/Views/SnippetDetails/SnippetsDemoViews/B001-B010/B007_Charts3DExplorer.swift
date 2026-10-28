//
//  B007_Charts3DExplorer.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 28.10.2026.
//

import SwiftUI
import Charts
import Spatial

// MARK: - Model

/// The mathematical surfaces SurfacePlot can draw — each one is just a (x, z) -> y function.
/// nonisolated + Sendable: SurfacePlot calls the function from a @Sendable closure off the main actor.
nonisolated enum B007_SurfaceShape: CaseIterable, Identifiable, Sendable {
    case ripple
    case saddle
    case waves

    var id: Self { self }

    var title: String {
        switch self {
        case .ripple: "Ripple"
        case .saddle: "Saddle"
        case .waves: "Waves"
        }
    }

    /// Height of the surface at the given (x, z) point.
    func height(x: Double, z: Double) -> Double {
        switch self {
        case .ripple:
            let r = (x * x + z * z).squareRoot()
            return cos(r * 2) / (1 + r * 0.6)
        case .saddle:
            return (x * x - z * z) / 9
        case .waves:
            return sin(x * 1.5) * cos(z * 1.5)
        }
    }
}

/// A single point of the 3D scatter plot.
struct B007_Point: Identifiable {
    let id: Int
    let x: Double
    let y: Double
    let z: Double
    let cluster: String

    /// Three deterministic clusters, so the chart looks the same on every launch.
    static let samples: [B007_Point] = {
        let centers: [(name: String, x: Double, y: Double, z: Double)] = [
            ("Alpha", -1.5, 0.6, -1.0),
            ("Beta", 1.4, -0.4, 0.8),
            ("Gamma", 0.2, 0.9, 1.8)
        ]
        var points: [B007_Point] = []
        for (c, center) in centers.enumerated() {
            for i in 0..<40 {
                let t = Double(i * 7 + c * 13)
                points.append(B007_Point(
                    id: c * 100 + i,
                    x: center.x + sin(t * 1.3) * 0.9,
                    y: center.y + cos(t * 0.7) * 0.5,
                    z: center.z + sin(t * 2.1) * 0.9,
                    cluster: center.name
                ))
            }
        }
        return points
    }()
}

// MARK: - Demo

@available(iOS 26.0, *)
struct B007_Charts3DExplorerDemo: View {

    private enum Mode: CaseIterable, Identifiable {
        case surface
        case points
        var id: Self { self }

        var title: String {
            switch self {
            case .surface: "Surface"
            case .points: "Points"
            }
        }
    }

    private enum Projection: CaseIterable, Identifiable {
        case perspective
        case orthographic
        var id: Self { self }

        var title: String {
            switch self {
            case .perspective: "Perspective"
            case .orthographic: "Orthographic"
            }
        }

        var value: Chart3DCameraProjection {
            switch self {
            case .perspective: .perspective
            case .orthographic: .orthographic
            }
        }
    }

    private static let poses: [(title: String, pose: Chart3DPose)] = [
        ("Default", .default),
        ("Front", .front),
        ("Top", .top),
        ("Hero", Chart3DPose(azimuth: .degrees(-40), inclination: .degrees(25)))
    ]

    @State private var mode: Mode = .surface
    @State private var shape: B007_SurfaceShape = .ripple
    @State private var heightColored = true
    @State private var projection: Projection = .perspective
    // Bound with .chart3DPose — dragging the chart rotates it and writes the new pose back here.
    @State private var pose: Chart3DPose = .default

    var body: some View {
        VStack(spacing: 16) {
            Picker("Mode", selection: $mode) {
                ForEach(Mode.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.segmented)

            chart
                .frame(maxWidth: .infinity, minHeight: 320, maxHeight: .infinity)

            poseButtons
            controls
        }
        .padding(.vertical)
    }

    // MARK: - Chart

    @ViewBuilder
    private var chart: some View {
        Group {
            switch mode {
            case .surface: surfaceChart
            case .points: pointsChart
            }
        }
        .chart3DPose($pose)
        .chart3DCameraProjection(projection.value)
        .chartXScale(domain: -3...3)
        .chartZScale(domain: -3...3)
    }

    private var surfaceChart: some View {
        // SurfacePlot samples the function over the X/Z scale domains.
        let shape = shape
        return Chart3D {
            SurfacePlot(x: "X", y: "Y", z: "Z") { x, z in
                shape.height(x: x, z: z)
            }
            .foregroundStyle(surfaceStyle)
            .roughness(0.3)
        }
        .chartYScale(domain: -1.5...1.5)
    }

    private var surfaceStyle: BasicChart3DSurfaceStyle {
        heightColored
            ? .heightBased(
                Gradient(colors: [Color.mycolor.myBlue, Color.mycolor.myPurple, Color.mycolor.myOrange]),
                yRange: -1...1
            )
            : .normalBased
    }

    private var pointsChart: some View {
        Chart3D(B007_Point.samples) { point in
            PointMark(
                x: .value("X", point.x),
                y: .value("Y", point.y),
                z: .value("Z", point.z)
            )
            .foregroundStyle(by: .value("Cluster", point.cluster))
        }
        .chartYScale(domain: -1.5...2.5)
        .chartForegroundStyleScale([
            "Alpha": Color.mycolor.myBlue,
            "Beta": Color.mycolor.myOrange,
            "Gamma": Color.mycolor.myGreen
        ])
    }

    // MARK: - Controls

    private var poseButtons: some View {
        HStack(spacing: 8) {
            ForEach(Self.poses, id: \.title) { item in
                Button(item.title) {
                    withAnimation(.smooth) { pose = item.pose }
                }
                .buttonStyle(.glass)
                .font(.footnote)
            }
        }
    }

    private var controls: some View {
        VStack(spacing: 12) {
            Picker("Projection", selection: $projection) {
                ForEach(Projection.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.segmented)

            if mode == .surface {
                Picker("Shape", selection: $shape) {
                    ForEach(B007_SurfaceShape.allCases) { Text($0.title).tag($0) }
                }
                .pickerStyle(.segmented)

                Toggle("Height-based gradient", isOn: $heightColored)
                    .font(.subheadline)
            }
        }
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        B007_Charts3DExplorerDemo()
            .padding(.horizontal)
    }
}
