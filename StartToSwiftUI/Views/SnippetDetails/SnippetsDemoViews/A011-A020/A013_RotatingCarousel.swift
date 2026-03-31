//
//  RotatingCarousel.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 15.03.2026.
//

import SwiftUI

struct A013_RotatingCarouselDemo: View {

    @State private var count: Int = 1
    @State private var swipeDirection: SwipeDirection = .right

    let colours: [Color] = [
        Color.mycolor.myRed,
        Color.mycolor.myBlue,
        Color.mycolor.myPurple,
        Color.mycolor.myGreen,
        Color.mycolor.myOrange,
        Color.mycolor.myYellow
    ]
    
    var body: some View {
        TabView(selection: $count) {
            ForEach(colours.indices, id: \.self) { index in
                Rectangle()
                    .foregroundStyle(colours[index])
                    .tag(index + 1)
            }
        }
        .frame(height: 250)
        .tabViewStyle(.page)
        .task {
            await runCarousel()
        }
    }

    private func runCarousel() async {
        while true {
            try? await Task.sleep(for: .seconds(1.2))

            withAnimation {
                switch swipeDirection {
                case .right:
                    count += 1
                    if count == colours.count { swipeDirection = .left }
                case .left:
                    count -= 1
                    if count == 1 { swipeDirection = .right }
                }
            }
        }
    }

    enum SwipeDirection { case left, right }
}

#Preview {
    A013_RotatingCarouselDemo()
}
