//
//  A002_TrimIndicator.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 09.03.2026.
//

import SwiftUI

struct A002_TrimIndicator: View {
    
    @State private var proportion: CGFloat = 0.0
    @State private var startProgressIndicator = false
    @State private var buttonCaption = "Start"
    @State private var timer: Timer? = nil
    private let frameSize: CGFloat = 150.0
    
    var body: some View {
        VStack {
            A002_ProgressIndicatorView(trim: $proportion)
                .frame(width: frameSize, height: frameSize)
                .padding()
            
            HStack {
                plusButton
                minusButton
            }.padding()
            
            actionButton
            resetButton
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func startTimer() {
        stopTimer()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            proportion += 0.01
            if proportion > 1 {
                proportion = 0
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private var plusButton: some View {
        Button("+") {
            if proportion != 0 && timer != nil {
                startProgressIndicator = false
                buttonCaption = buttonCaption == "Start" ? "Stop" : "Start"
            }
            proportion += 0.1
            proportion = min(proportion,1)
        }
        .padding()
        .background(.black.opacity(0.03))
        .clipShape(.circle)
    }
    
    private var minusButton: some View {
        Button("-") {
            if proportion != 0 && timer != nil {
                startProgressIndicator = false
                buttonCaption = buttonCaption == "Start" ? "Stop" : "Start"
            }
            proportion -= 0.1
            proportion = max(self.proportion,0)
        }
        .padding()
        .background(.black.opacity(0.03))
        .clipShape(.circle)
    }
    
    private var actionButton: some View {
        Button(buttonCaption) {
            switch buttonCaption {
            case "Start":
                startProgressIndicator = true
                startTimer()
            case "Stop" :
                startProgressIndicator = false
                stopTimer()
            default: break
            }
            buttonCaption = buttonCaption == "Start" ? "Stop" : "Start"
        }
        .padding()
        .frame(maxWidth: 150)
        .background(.black.opacity(0.03))
        .clipShape(.capsule)
    }
    
    private var resetButton: some View {
        Button("Reset") {
            stopTimer()
            startProgressIndicator = false
            buttonCaption = "Start"
            proportion = 0.0
        }
        .a002_formater(frameSize: frameSize)
    }
}

struct A002_ProgressIndicatorView: View {
    
    @Binding var trim: CGFloat
    let lineWidth: CGFloat = 15.0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: lineWidth)
                .opacity(0.3)
                .foregroundColor(Color.green)
            
            Circle()
                .trim(from: 0, to: self.trim)
                .stroke(style: StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: .round,
                    lineJoin: .round))
                .foregroundColor(Color.green)
                .rotationEffect(Angle(degrees: -90))
            HStack(alignment: .lastTextBaseline, spacing: 0) {
                Text(String(format: "%.0f", trim * 100))
                Text("%")
                    .font(.caption2)
            }
            .font(.headline)
            .foregroundColor(Color.red)
        }
    }
}

extension View {
    func a002_formater (frameSize: CGFloat) -> some View {
        self
            .padding()
            .frame(maxWidth: frameSize)
            .background(Color.mycolor.myButtonBGGray)
            .clipShape(.capsule)
    }
}


#Preview {
    NavigationStack {
        A002_TrimIndicator()
    }
}
