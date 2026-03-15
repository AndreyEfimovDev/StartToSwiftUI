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
            Image(systemName: "trash")
                .font(.system(size: 50, weight: .bold))
                .symbolEffect(.pulse, value: isAnimated)
                .padding()

            Image(systemName: "trash")
                .font(.system(size: 50, weight: .bold))
                .symbolEffect(.bounce, value: isAnimated)
                .padding()
                        
            HStack {
                Image(systemName: "wifi")
                    .font(.system(size: 50, weight: .bold))
                    .symbolEffect(.variableColor, value: isAnimated)
                Image(systemName: "wifi")
                    .font(.system(size: 50, weight: .bold))
                    .symbolEffect(.variableColor.iterative, value: isAnimated)
                
                Image(systemName: "wifi")
                    .font(.system(size: 50, weight: .bold))
                    .symbolEffect(.variableColor.hideInactiveLayers, value: isAnimated)
            }
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

            Image(systemName: isAnimated ? "trash.slash" : "trash")
                .font(.system(size: 50, weight: .bold))
                .contentTransition(.symbolEffect(.replace))
                .padding()
        }
    }
}

#Preview {
    A005_SFSymbolEffectsDemo()
}
