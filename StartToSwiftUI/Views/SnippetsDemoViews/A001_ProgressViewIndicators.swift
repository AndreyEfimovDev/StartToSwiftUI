//
//  A001_ProgressViewIndicators.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.03.2026.
//

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
