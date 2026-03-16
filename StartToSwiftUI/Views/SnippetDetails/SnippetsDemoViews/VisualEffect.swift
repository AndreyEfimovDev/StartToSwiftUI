//
//  VisualEffect.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 15.03.2026.
//

import SwiftUI

struct VisualEffect: View {
    
    @State private var showSpacer: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                ForEach(0..<100) { index in
                    Rectangle()
                        .frame(width: 300, height: 200)
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .visualEffect { content, geometry in
                            content
                                .offset(x: geometry.frame(in: .global).minY * 0.5)
                        }
                }
            }
        }
        
        VStack {
            Text("Hello world!")
                .padding()
                .background(Color.red)
                .visualEffect { content, geometry in
                    content
                        .grayscale(geometry.frame(in: .global).minY < 300 ? 1 : 0)
                    //                    .grayscale(geometry.size.width >= 200 ? 1 : 0)
                }
            
            if showSpacer {
                Spacer()
            }
        }
        .animation(.easeIn, value: showSpacer)
        .onTapGesture {
            showSpacer.toggle()
        }
    }
}

#Preview {
    VisualEffect()
}
