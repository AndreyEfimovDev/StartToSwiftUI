//
//  AnimationTiming.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 15.03.2026.
//

import SwiftUI

struct AnimationTiming: View {
    @State var isAnimating: Bool = false
    let timing: Double = 3.0
    
    var body: some View {
        VStack(/*alignment: .leading*/) {
            Text("""
                Spring:
                - response = 3.0
                - dampingFraction = 0.5
                - blendDuration = 0.5
                """)
                .font(.caption)
            RoundedRectangle(cornerRadius: 20)
                .fill(.blue)
                .frame(width: isAnimating ? 250 : 50, height: 15)
                .animation(.spring(
                    response: 3.0,
                    dampingFraction: 0.5,
                    blendDuration: 0.5), value: isAnimating)
            
            Text("spring: response = 1.0, df = 0.2, bd = 0.5")
                .font(.caption)
                .padding(.top, 10)
            RoundedRectangle(cornerRadius: 20)
                .fill(.blue)
                .frame(width: isAnimating ? 250 : 50, height: 15)
                .animation(.spring(
                    response: 1.0,
                    dampingFraction: 0.2,
                    blendDuration: 0.5), value: isAnimating)
            
            Text("spring: response = 0.5, df = 0.7, bd = 0.5")
                .font(.caption)
                .padding(.top, 10)
            RoundedRectangle(cornerRadius: 20)
                .fill(.blue)
                .frame(width: isAnimating ? 250 : 50, height: 15)
                .animation(.spring(
                    response: 0.5,
                    dampingFraction: 0.7,
                    blendDuration: 0.5), value: isAnimating)
            
            Text("spring")
                .font(.caption)
                .padding(.top, 10)
            RoundedRectangle(cornerRadius: 20)
                .frame(width: isAnimating ? 250 : 50, height: 15)
                .animation(.spring(), value: isAnimating)
            Text("linear")
                .font(.caption)
                .padding(.top, 10)
            RoundedRectangle(cornerRadius: 20)
                .frame(width: isAnimating ? 250 : 50, height: 15)
                .animation(.linear(duration: timing), value: isAnimating)
            Text("easeInOut")
                .font(.caption)
                .padding(.top, 10)
            RoundedRectangle(cornerRadius: 20)
                .frame(width: isAnimating ? 250 : 50, height: 15)
                .animation(.easeInOut(duration: timing), value: isAnimating)
            Text("easeIn")
                .font(.caption)
                .padding(.top, 10)
            RoundedRectangle(cornerRadius: 20)
                .frame(width: isAnimating ? 250 : 50, height: 15)
                .animation(.easeIn(duration: timing), value: isAnimating)
            Text("easeOut")
                .font(.caption)
                .padding(.top, 10)
            RoundedRectangle(cornerRadius: 20)
                .frame(width: isAnimating ? 250 : 50, height: 15)
                .animation(.easeOut(duration: timing), value: isAnimating)
            Text("bouncy")
                .font(.caption)
                .padding(.top, 10)
            RoundedRectangle(cornerRadius: 20)
                .frame(width: isAnimating ? 250 : 50, height: 15)
                .animation(.bouncy(duration: timing), value: isAnimating)
            Text("snappy")
                .font(.caption)
                .padding(.top, 10)
            RoundedRectangle(cornerRadius: 20)
                .frame(width: isAnimating ? 250 : 50, height: 15)
                .animation(.snappy(duration: timing), value: isAnimating)
            
            Circle()
                .frame(width: 15, height: 15)
                .frame(maxWidth: .infinity, alignment: isAnimating ? .trailing : .leading)
                .animation(.spring(duration: timing), value: isAnimating)
            Circle()
                .frame(width: 15, height: 15)
                .frame(maxWidth: .infinity, alignment: isAnimating ? .trailing : .leading)
                .animation(.linear(duration: timing), value: isAnimating)
            Circle()
                .frame(width: 15, height: 15)
                .frame(maxWidth: .infinity, alignment: isAnimating ? .trailing : .leading)
                .animation(.easeInOut(duration: timing), value: isAnimating)
            Circle()
                .frame(width: 15, height: 15)
                .frame(maxWidth: .infinity, alignment: isAnimating ? .trailing : .leading)
                .animation(.easeIn(duration: timing), value: isAnimating)
            Circle()
                .frame(width: 15, height: 15)
                .frame(maxWidth: .infinity, alignment: isAnimating ? .trailing : .leading)
                .animation(.easeOut(duration: timing), value: isAnimating)
            Circle()
                .frame(width: 15, height: 15)
                .frame(maxWidth: .infinity, alignment: isAnimating ? .trailing : .leading)
                .animation(.bouncy(duration: timing), value: isAnimating)
            Circle()
                .frame(width: 15, height: 15)
                .frame(maxWidth: .infinity, alignment: isAnimating ? .trailing : .leading)
                .animation(.snappy(duration: timing), value: isAnimating)
        }
        .padding(.horizontal)
        
        Button("Button") {
            isAnimating.toggle()
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
    }
}

#Preview {
    AnimationTiming()
}
