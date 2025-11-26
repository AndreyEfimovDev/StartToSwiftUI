//
//  RotatingRingProgressView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 09.11.2025.
//

import SwiftUI

struct CustomProgressView: View {
    
    private let scale: CGFloat
    
    init(scale: CGFloat = 1.5) {
        self.scale = scale
    }
    
    var body: some View {
        
        ProgressView("... loading ...")
            .scaleEffect(scale)
            .padding()
    }
}

#Preview {
    CustomProgressView()
}
