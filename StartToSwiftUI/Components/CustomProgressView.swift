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
        isNoText: Bool = true
    ) {
        self.scale = scale
        self.isNoText = isNoText
    }
    
    var body: some View {
        
        Group {
            if isNoText {
                ProgressView()
            } else {
                ProgressView("... loading ...")
            }
        }
        .scaleEffect(scale)
        .padding()
    }
}

#Preview {
    CustomProgressView()
}
