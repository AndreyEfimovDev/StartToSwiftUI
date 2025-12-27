//
//  RotatingRingProgressView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 09.11.2025.
//

import SwiftUI

struct CustomProgressView: View {
    
    private let scale: CGFloat
    private let isNoText: Bool
    
    init(
        scale: CGFloat = 1.5,
        isNoText: Bool = false
    ) {
        self.scale = scale
        self.isNoText = isNoText
    }
    
    var body: some View {
        
        Group {
            if isNoText {
                ProgressView()
            } else {
                ProgressView("loading ...")
                    .font(.caption2)
                    .padding()
            }
        }
        .scaleEffect(scale < 1.5 ? scale : 1.5) // set scale the largest -> 1.5
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

#Preview {
    CustomProgressView()
}
