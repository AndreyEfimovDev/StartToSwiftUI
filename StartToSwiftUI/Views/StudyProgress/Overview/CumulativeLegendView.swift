//
//  LegendView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 13.01.2026.
//

import SwiftUI

// MARK: - Legend
struct CumulativeLegendView: View {
    
    var body: some View {
        VStack(spacing: 8) {
            
            Text("Cumulative progress")
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
                ForEach([StudyProgress.started, StudyProgress.studied, StudyProgress.practiced], id: \.self) { type in
                    
                    let UIDeviceLayout: AnyLayout = UIDevice.isiPad ? AnyLayout(VStackLayout(spacing: 6)) : AnyLayout(HStackLayout(spacing: 6))
                    UIDeviceLayout {
                        Capsule()
                            .fill(type.color)
                            .frame(width: 12, height: 8)
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
    CumulativeLegendView()
}
