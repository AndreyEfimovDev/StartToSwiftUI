//
//  LegendView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 13.01.2026.
//

import SwiftUI

// MARK: - Legend
// Маркер — цветная плашка, как закрашенные области (AreaMark) на графике
// накопительного прогресса.
struct CumulativeLegendView: View {

    var body: some View {
        ChartLegendView(title: "Cumulative progress") { type in
            Capsule()
                .fill(type.color)
                .frame(width: 12, height: 8)
        }
    }
}

#Preview {
    CumulativeLegendView()
}
