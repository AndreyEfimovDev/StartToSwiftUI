//
//  A016_IndeterminateProgressBar.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 07.04.2026.
//

import SwiftUI

struct A016_IndeterminateProgressBarDemo: View {
    
    @State private var offset: CGFloat = 0
    @State private var flipped = false

    private let ratio:    CGFloat = 0.65
    private let duration: Double  = 1.3

    var body: some View {
        GeometryReader { geo in
            let block = geo.size.width * ratio

            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(.systemGray5))
                    .frame(height: 6)

                // Thumb + trace (single block with gradient)
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.00),
                        .init(color: Color.mycolor.myBlue.opacity(0.25), location: 0.38),
                        .init(color: Color.mycolor.myBlue, location: 1.00),
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: block, height: 6)
                .clipShape(RoundedRectangle(cornerRadius: 3))
                // Flip mirrors the gradient: trace is always behind
                .scaleEffect(x: flipped ? -1 : 1, anchor: .center)
                .offset(x: offset)
            }
            .clipped()
            .task {
                offset = -block // start behind the left edge

                while !Task.isCancelled {
                    // ── right: trace on the left, thumb on the right ──
                    flipped = false
                    withAnimation(.easeInOut(duration: duration)) {
                        offset = geo.size.width // уезжает за правый край
                    }
                    try? await Task.sleep(
                        nanoseconds: UInt64(duration * 1_000_000_000)
                    )

                    // the block is completely behind the screen → the flip is not visible
                    flipped = true

                    // ── left: thumb left, trace right ───
                    withAnimation(.easeInOut(duration: duration)) {
                        offset = -block // goes beyond the left edge
                    }
                    try? await Task.sleep(
                        nanoseconds: UInt64(duration * 1_000_000_000)
                    )
                }
            }
        }
        .frame(height: 6)
    }
}

#Preview {
    A016_IndeterminateProgressBarDemo()
}
