//
//  A002_TrimIndicator.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 09.03.2026.
//

import SwiftUI

// MARK: - Demo
struct A002_TrimIndicatorDemo: View {
    
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
        Button {
            if proportion != 0 && timer != nil {
                startProgressIndicator = false
                buttonCaption = buttonCaption == "Start" ? "Stop" : "Start"
            }
            proportion += 0.1
            proportion = min(proportion,1)
        } label: {
            Image(systemName: "plus")
                .font(.headline)
                .foregroundStyle(Color.mycolor.myBlue)
                .frame(width: 55, height: 55)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(Circle().stroke(Color.mycolor.myBlue, lineWidth: 1))
        }
    }
    
    private var minusButton: some View {
        Button {
            if proportion != 0 && timer != nil {
                startProgressIndicator = false
                buttonCaption = buttonCaption == "Start" ? "Stop" : "Start"
            }
            proportion -= 0.1
            proportion = max(self.proportion,0)
        } label: {
            Image(systemName: "minus")
                .font(.headline)
                .foregroundStyle(Color.mycolor.myBlue)
                .frame(width: 55, height: 55)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(Circle().stroke(Color.mycolor.myBlue, lineWidth: 1))
        }
    }
    
    private var actionButton: some View {
        Button {
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
        } label: {
            Text(buttonCaption)
                .font(.headline)
                .foregroundColor(startProgressIndicator ? Color.mycolor.myBlue : Color.mycolor.myGreen)
                .padding(.vertical, 8)
                .frame(height: 55)
                .frame(maxWidth: 150)
                .background(.thinMaterial)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.mycolor.myBlue, lineWidth: 1))
        }
    }
    
    private var resetButton: some View {
        Button {
            stopTimer()
            startProgressIndicator = false
            buttonCaption = "Start"
            proportion = 0.0
        } label: {
            Text("Reset")
                .font(.headline)
                .foregroundColor(Color.mycolor.myRed)
                .padding(.vertical, 8)
                .frame(height: 55)
                .frame(maxWidth: 150)
                .background(.thinMaterial)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.mycolor.myBlue, lineWidth: 1))
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        A002_TrimIndicatorDemo()
    }
}

// MARK: - Code Snippet
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


