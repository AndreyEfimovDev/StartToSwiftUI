//
//  SnippetsRepository.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 09.03.2026.
//
//  Single source of truth for all code snippets.
//  To add a new snippet:
//  1. Create DemoView in SnippetsDemoViews/ (e.g. A003_...)
//  2. Add a case in SnippetViewRegistry
//  3. Add a CodeSnippet entry here

import Foundation

struct SnippetsRepository {

    static let all: [CodeSnippet] = [a001, a002]

    // MARK: - A001
    static let a001 = CodeSnippet(
        id: "A001",
        category: Constants.mainCategory,
        title: "Basic Progress Indicator",
        intro: "A circular progress indicator built with Circle().trim(). Shows how to animate a stroke along a circle arc using a CGFloat proportion from 0.0 to 1.0.",
        codeSnippet: """
        import SwiftUI

        struct A001_ProgressViewIndicators: View {
            
            @State var proportion: CGFloat = 0.0
            @State var startProgressIndicator2 = false
            @State var buttonCaption2 = "Start"
            
            var body: some View {
                VStack {
                    A001_ProgressIndicator(trim: self.$proportion)
                        .frame(width: 100.0, height: 100.0)
                        .padding(40.0)
                    
                    HStack {
                        Button(action: {
                            self.startProgressIndicator2 = false
                            self.buttonCaption2 = self.buttonCaption2 == "Start" ? "Stop" : "Start"
                            self.proportion += 0.1
                            self.proportion = min(self.proportion,1)
                        })
                        {
                            Text("+")
                                .padding()
                                .border(Color.black)
                        }
                        Button(action: {
                            self.startProgressIndicator2 = false
                            self.buttonCaption2 = self.buttonCaption2 == "Start" ? "Stop" : "Start"
                            self.proportion -= 0.1
                            self.proportion = max(self.proportion,0)
                        })
                        {
                            Text("-")
                                .padding()
                                .border(Color.black)
                        }
                    }
                    Button(action: {
                        switch buttonCaption2 {
                        case "Start":
                            self.startProgressIndicator2 = true
                        case "Stop" :
                            self.startProgressIndicator2 = false
                        default: break
                        }
                        
                        self.buttonCaption2 = self.buttonCaption2 == "Start" ? "Stop" : "Start"
                        
                        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true)
                        {timer in
                            self.proportion += 0.01
                            if self.proportion > 1 {self.proportion = 0}
                            if !self.startProgressIndicator2 {timer.invalidate()}
                        }})
                    {
                        Text(self.buttonCaption2)
                    }
                }
            }
        }

        struct A001_ProgressIndicator: View {
            
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

        #Preview {
            A001_ProgressViewIndicators()
        }
        """,
        thanks: nil,
        githubUrlString: nil,
        notes: "The key technique is Circle().trim(from:to:) combined with rotationEffect to start the arc from the top (−90°) instead of the right side (0°). lineCap: .round gives the smooth rounded ends.",
        date: Date.from(year: 2026, month: 3, day: 8) ?? Date()
    )

    // MARK: - A002
    static let a002 = CodeSnippet(
        id: "A002",
        category: Constants.mainCategory,
        title: "Trim Indicator with Controls",
        intro: "An enhanced circular progress indicator with manual +/− controls, an animated auto-increment timer, and a reset button. Demonstrates Timer integration within SwiftUI state.",
        codeSnippet: """
        import SwiftUI

        struct A002_TrimIndicator: View {
            
            @State private var proportion: CGFloat = 0.0
            @State private var startProgressIndicator = false
            @State private var buttonCaption = "Start"
            @State private var timer: Timer? = nil
            private let frameSize: CGFloat = 150.0
            
            var body: some View {
                VStack {
                    A002_ProgressIndicator(trim: $proportion)
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

        struct A002_ProgressIndicator: View {
            
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
                A002_TrimIndicator()
        }
        """,
        thanks: nil,
        githubUrlString: nil,
        notes: "Timer is stored as @State var timer: Timer? so it can be invalidated on .onDisappear — preventing memory leaks when the view leaves the screen. stopTimer() is always called before startTimer() to avoid running multiple timers simultaneously.",
        date: Date.from(year: 2026, month: 3, day: 9) ?? Date()
    )
}
