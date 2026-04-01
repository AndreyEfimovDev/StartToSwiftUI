//
//  A005_SFSymbolEffects.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 15.03.2026.
//

import SwiftUI

struct A005_SFSymbolEffectsDemo: View {
    
    @State var isAnimated: Bool = false
    
    var body: some View {
        VStack {
            Group {
                Image(systemName: isAnimated ? "microphone.slash.fill" : "microphone.fill")
                    .font(.system(size: 50, weight: .bold))
                    .contentTransition(.symbolEffect(.replace))
                    .padding()
                
                HStack {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 50, weight: .bold))
                        .symbolEffect(.pulse, value: isAnimated)
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 50, weight: .bold))
                        .symbolEffect(.bounce, value: isAnimated)
                }
                .padding()
                
                HStack {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 50, weight: .bold))
                        .symbolEffect(.variableColor, value: isAnimated)
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 50, weight: .bold))
                        .symbolEffect(.variableColor.iterative, value: isAnimated)
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 50, weight: .bold))
                        .symbolEffect(.variableColor.hideInactiveLayers, value: isAnimated)
                }
            }
            .padding()
            
            Button {
                isAnimated.toggle()
            }label: {
                Text("Animate")
                    .font(.headline)
                    .foregroundStyle(Color.mycolor.myBlue)
                    .padding()
                    .background(.ultraThinMaterial, in: .capsule)
                    .overlay(Capsule().stroke(Color.mycolor.myBlue, lineWidth: 1))
            }
            .padding()
        }
    }
}

#Preview {
    A005_SFSymbolEffectsDemo()
}
