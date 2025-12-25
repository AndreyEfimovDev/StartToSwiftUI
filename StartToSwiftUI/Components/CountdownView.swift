//
//  CountdownView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.12.2025.
//

import SwiftUI

struct CountdownView: View {
    
    let initialSeconds: Int
    @State private var secondsRemaining: Int
    
    init(initialSeconds: Int) {
        self.initialSeconds = initialSeconds
        self._secondsRemaining = State(initialValue: initialSeconds)
    }
    
    var body: some View {
            Text("\(secondsRemaining)")
                .font(.title)
                .foregroundColor(Color.mycolor.myAccent).opacity(0.5)
                .frame(width: 155)
                .padding()
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                    if secondsRemaining > 1 {
                        secondsRemaining -= 1
                    } else {
                        timer.invalidate()
                    }
                }
            }
    }
}


#Preview {
    CountdownView(initialSeconds: 10)
}
