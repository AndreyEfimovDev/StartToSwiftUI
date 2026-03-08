//
//  StatCard.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 13.01.2026.
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: Image
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 3){
                icon
                Spacer()
                Text(value)
                    .font(.headline)
                    .foregroundStyle(Color.mycolor.myAccent)
            }

            Text(title)
        }
        .font(.caption)
        .foregroundStyle(color)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(color.opacity(0.15))
        .clipShape(
            RoundedRectangle(cornerRadius: 15)
        )
    }
}

#Preview {
    StatCard(
        title: "Started",
        value: "12",
        color: .blue,
        icon: Image(systemName: "sunrise")
    )
    .padding()
    .frame(width: 150, height: 100)
}
