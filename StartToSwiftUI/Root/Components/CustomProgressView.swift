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
        
        ProgressView()
            .scaleEffect(scale)
//            .frame(minWidth: 80, idealWidth: 100, maxWidth: 120,
//                       minHeight: 80, idealHeight: 100, maxHeight: 120)
//            .progressViewStyle(.circular)
//            .padding()
    }
}

#Preview {
    CustomProgressView()
}
