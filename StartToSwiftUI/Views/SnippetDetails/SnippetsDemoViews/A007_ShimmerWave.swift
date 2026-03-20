//
//  A007_Shimmer.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 19.03.2026.
//

import SwiftUI

struct A007_ShimmerWaveDemo: View {
    
    let rowSamples: [A007_RowModel] = [
        A007_RowModel(title: "Row Sample 1 (shimmered)", isShimmered: true),
        A007_RowModel(title: "Row Sample 2 (not shimmered)", isShimmered: false),
        A007_RowModel(title: "Row Sample 3 (shimmered)", isShimmered: true)
    ]
    
    var body: some View {
        List {
            ForEach(rowSamples) { row in
                A007_RowView(row: row)
                    .a007_shimmerWave(enabled: row.isShimmered)
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
        .listStyle(.plain)
    }
}

struct A007_RowModel: Identifiable {
    let id: String = UUID().uuidString
    let title: String
    let isShimmered: Bool
    
    init(title: String, isShimmered: Bool) {
        self.title = title
        self.isShimmered = isShimmered
    }
}

struct A007_RowView: View {
    
    let row: A007_RowModel

    var body: some View {
        HStack {
            Text(row.title)
                .padding(8)
                .padding(.horizontal, 8)
                .frame(height: 100)
            Spacer()
        }
    }
}


#Preview {
    A007_ShimmerWaveDemo()
}

struct A007_ShimmerWave: ViewModifier {
    
    let enabled: Bool
    
    @State private var phase: CGFloat = 0
    @State private var task: Task<Void, Never>?

    func body(content: Content) -> some View {
        if enabled {
            content
                .overlay(shimmerOverlay)
                .clipped()
                .task { await runLoop() }
        } else {
            content
        }
    }

    private var shimmerOverlay: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let bandWidth = w * 0.4

            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: Color.mycolor.myAccent.opacity(0.06), location: 0.25),
                    .init(color: Color.mycolor.myAccent.opacity(0.22), location: 0.5),
                    .init(color: Color.mycolor.myAccent.opacity(0.06), location: 0.75),
                    .init(color: .clear, location: 1),
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: bandWidth)
            .offset(x: phase * (w + bandWidth) - bandWidth)
            .allowsHitTesting(false)
        }
    }

    private func runLoop() async {
        /*
         How the cycle works:
         ```
         phase = 0 (the band goes beyond the left edge)
             │
             ▼ withAnimation(.linear(duration: 1.2))
         phase = 1 (the band goes beyond the right edge)  ← 1.2 sec
             │
             ▼ Task.sleep(1.2) — waiting for the end of the animation
         phase = 0 (instant reset, the strip behind the screen)
             │
             ▼ Task.sleep(3.0) — silent pause
             └── repeat
         */
        while !Task.isCancelled {
            withAnimation(.linear(duration: 1.2)) { phase = 1 }
            do {
                try await Task.sleep(for: .seconds(1.2)) // wait for the end of sweep
                phase = 0
                try await Task.sleep(for: .seconds(3.0)) // pause between animations
            } catch {
                break  // CancellationError → exit imideatelly
            }
        }
    }
}

extension View {
    func a007_shimmerWave(enabled: Bool = true) -> some View {
        modifier(A007_ShimmerWave(enabled: enabled))
    }
}
