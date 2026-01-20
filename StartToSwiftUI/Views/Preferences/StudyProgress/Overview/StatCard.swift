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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(Color.mycolor.myAccent)
            Text(value)
                .font(.headline)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(color.opacity(0.3))
        .clipShape(
            RoundedRectangle(cornerRadius: 15)
        )
    }
}
