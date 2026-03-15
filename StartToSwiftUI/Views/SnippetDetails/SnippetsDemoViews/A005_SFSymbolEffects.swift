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
            Image(systemName: "sun.max.fill")
                .font(.system(size: 50, weight: .bold))
                .symbolEffect(.pulse, value: isAnimated)
                .padding()

            Image(systemName: "sun.max.fill")
                .font(.system(size: 50, weight: .bold))
                .symbolEffect(.bounce, value: isAnimated)
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
            .padding()

            Image(systemName: isAnimated ? "microphone.slash.fill" : "microphone.fill") // microphone.slash.fill
                .font(.system(size: 50, weight: .bold))
                .contentTransition(.symbolEffect(.replace))
                .padding()

            
            Button {
                isAnimated.toggle()
            }label: {
                Text("Animate")
                    .font(.headline)
                    .foregroundStyle(Color.mycolor.myButtonTextPrimary)
                    .padding()
                    .background(Color.mycolor.myBlue, in: .capsule)
            }
            .padding()

        }
    }
}

#Preview {
    A005_SFSymbolEffectsDemo()
}
