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
        
        
        VStack(alignment: .leading, spacing: 8) {
            
            Text("Cumulative progress")
                .font(.caption)
                .bold()
            HStack(spacing: 20) {
                ForEach([StudyProgress.started, StudyProgress.studied, StudyProgress.practiced], id: \.self) { type in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(type.color)
                            .frame(width: 8, height: 8)
                        Text(type.displayName)
                            .font(.caption)
                    }
                }
            }
        }
        .foregroundStyle(Color.mycolor.myAccent)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.mycolor.myBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    CumulativeLegendView()
}
