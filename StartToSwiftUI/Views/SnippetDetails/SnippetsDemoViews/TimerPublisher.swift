//
//  Timer.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 15.03.2026.
//

import SwiftUI
import Combine

struct TimerPublisherDemo: View {
    
    @State private var cancellable: AnyCancellable? = nil
    // Animation counter
    @State var count: Int = 1
    
    var body: some View {
        ZStack {
            RadialGradient(
                gradient: Gradient(colors: [Color(#colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)), Color(#colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1))]),
                center: .center,
                startRadius: 5,
                endRadius: 500)
                .ignoresSafeArea()
            
            TabView(selection: $count,
                    content:  {
                        Rectangle()
                            .foregroundColor(.red)
                            .tag(1)
                        Rectangle()
                            .foregroundColor(.blue)
                            .tag(2)
                        Rectangle()
                            .foregroundColor(.green)
                            .tag(3)
                        Rectangle()
                            .foregroundColor(.orange)
                            .tag(4)
                        Rectangle()
                            .foregroundColor(.pink)
                            .tag(5)
                    })
                .frame(height: 200)
                .tabViewStyle(PageTabViewStyle())
        }
        .onAppear {
            cancellable = Timer // save the link to the timer publisher
                .publish(every: 0.4, on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    count = count == 5 ? 1 : count + 1
                }
        }
        .onDisappear {
            // cancel the timer publisher to prevent memory leak
            cancellable?.cancel()
            cancellable = nil
        }

    }
}

#Preview {
    TimerPublisherDemo()
}
