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
                Text(title)
            }
            .font(.caption2)
            .foregroundStyle(color)

            Text(value)
                .font(.headline)
                .foregroundStyle(Color.mycolor.myAccent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(color.opacity(0.3))
        .clipShape(
            RoundedRectangle(cornerRadius: 15)
        )
    }
}
