//
//  A009_OnToButton.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 19.03.2026.
//

import SwiftUI

struct A009_OnToButtonDemo: View {
    
    @State private var showOnTopButton = false
    
    // the threshold is 100pt, you can adjust it to your row height
    private let threshold: CGFloat = 100
    
    var body: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .bottom) {
                ScrollView {
                    ForEach(0..<30) { index in
                        Text("Row \(index)")
                            .font(.headline)
                            .foregroundStyle(Color.mycolor.myAccent)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(
                                .ultraThinMaterial,
                                in: RoundedRectangle(cornerRadius: 8)
                            )
                            .padding(.horizontal)
                            .id(index)
                    }
                }
                .onScrollGeometryChange(for: CGFloat.self) { geometry in
                    geometry.contentOffset.y
                } action: { _, newOffset in
                    showOnTopButton = newOffset > threshold
                }
                
                if showOnTopButton {
                    Button {
                        withAnimation {
                            proxy.scrollTo(0, anchor: .top)
                        }
                    } label: {
                        Image(systemName: "control")
                            .font(.title)
                            .foregroundStyle(Color.mycolor.myBlue)
                            .frame(width: 55, height: 55)
                            .background(.clear, in: .circle)
                            .overlay(
                                Circle()
                                    .stroke(Color.mycolor.myBlue, lineWidth: 1)
                            )
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.5)))
                    .padding(.bottom, 16)
                }
            }
        }
    }
}

#Preview {
    A009_OnToButtonDemo()
}
