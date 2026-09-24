//
//  ChartLegendView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 24.09.2026.
//

import SwiftUI

/// Легенда графика прогресса: бейдж-заголовок и ряд типов `StudyProgress`,
/// каждый со своим маркером и подписью.
///
/// Общая вёрстка для `LineMarkLegendView` и `CumulativeLegendView` — они
/// отличаются только заголовком и тем, как нарисован маркер (он повторяет
/// вид серии на своём графике), поэтому маркер передаётся замыканием.
struct ChartLegendView<Marker: View>: View {

    /// Заголовок легенды. `LocalizedStringKey`, а не `String`, — чтобы
    /// `Text` по-прежнему искал перевод, как для строкового литерала.
    let title: LocalizedStringKey
    /// Маркер для конкретного типа прогресса.
    @ViewBuilder let marker: (StudyProgress) -> Marker

    private let types: [StudyProgress] = [.started, .studied, .practiced]

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption2)
                .bold()
                .padding(4)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.mycolor.mySecondary.opacity(0.5), lineWidth: 1)
                )

            HStack(spacing: 20) {
                ForEach(types, id: \.self) { type in
                    // iPad: маркер над подписью, iPhone: в строку.
                    let UIDeviceLayout: AnyLayout = UIDevice.isiPad ? AnyLayout(VStackLayout(spacing: 6)) : AnyLayout(HStackLayout(spacing: 6))

                    UIDeviceLayout {
                        marker(type)
                        Text(type.displayName)
                            .font(.caption2)
                    }
                }
            }
        }
        .foregroundStyle(Color.mycolor.myAccent)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 8)
    }
}

#Preview {
    ChartLegendView(title: "Preview legend") { type in
        Circle()
            .fill(type.color)
            .frame(width: 8, height: 8)
    }
}
