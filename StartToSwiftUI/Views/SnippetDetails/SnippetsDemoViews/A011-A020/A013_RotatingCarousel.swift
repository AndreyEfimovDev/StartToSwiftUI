//
//  RotatingCarousel.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 15.03.2026.
//

import SwiftUI
import Combine

struct A013_RotatingCarouselDemo: View {
    
    @State private var cancellable: AnyCancellable? = nil
    @State var count: Int = 1
    
    let coloursArray: [Color] = [
        Color.mycolor.myRed,
        Color.mycolor.myBlue,
        Color.mycolor.myPurple,
        Color.mycolor.myGreen,
        Color.mycolor.myOrange,
        Color.mycolor.myYellow
    ]
    
    var body: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea()
            
            TabView(selection: $count) {
                Rectangle()
                    .foregroundColor(coloursArray[0])
                    .tag(1)
                Rectangle()
                    .foregroundColor(coloursArray[1])
                    .tag(2)
                Rectangle()
                    .foregroundColor(coloursArray[2])
                    .tag(3)
                Rectangle()
                    .foregroundColor(coloursArray[3])
                    .tag(4)
                Rectangle()
                    .foregroundColor(coloursArray[4])
                    .tag(5)
                Rectangle()
                    .foregroundColor(coloursArray[5])
                    .tag(6)
            }
            .frame(height: 250)
            .tabViewStyle(.page)
        }
        .onAppear {
            cancellable = Timer
                .publish(every: 1.2, on: .main, in: .common).autoconnect()
                .sink { _ in
                    count = count == coloursArray.count ? 1 : count + 1
                }
        }
        .onDisappear {
            cancellable?.cancel()
            cancellable = nil
        }
        
    }
}

#Preview {
    A013_RotatingCarouselDemo()
}
