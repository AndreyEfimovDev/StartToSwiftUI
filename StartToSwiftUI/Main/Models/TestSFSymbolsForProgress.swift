//
//  TestSFSymbolsForProgress.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 06.12.2025.
//

import SwiftUI

struct TestSFSymbolsForProgress: View {
    var body: some View {
        VStack(spacing: 20){
            HStack(spacing: 10) {
                Image(systemName: "doc")
                Image(systemName: "book")
                Image(systemName: "checklist")
                Image(systemName: "hammer.fill")
            }
            HStack(spacing: 10) {
                Image(systemName: "lightbulb")
                Image(systemName: "graduationcap")
                Image(systemName: "brain.head.profile")
                Image(systemName: "hand.raised")
                Image(systemName: "hand.raised.fill")
                Image(systemName: "hand.raised.fingers.spread.fill")
                Image(systemName: "hand.raised.fingers.spread")
            }
            HStack(spacing: 10) {
                Image(systemName: "signpost.right")
                Image(systemName: "figure.walk")
                Image(systemName: "flag.checkered")
                Image(systemName: "mountain.2.fill")
            }
            .foregroundStyle(Color.mycolor.myGreen)
            HStack(spacing: 10) {
                Image(systemName: "circle")
                Image(systemName: "circle.dotted")
                Image(systemName: "circle.inset.filled")
                Image(systemName: "burst.fill")
            }
            HStack(spacing: 10) {
                Image(systemName: "tag")
                Image(systemName: "bolt.horizontal.circle")
                Image(systemName: "checkmark.circle.fill")
                Image(systemName: "gearshape.2.fill")
            }
        }
        .font(.title)

    }
}

#Preview {
    TestSFSymbolsForProgress()
}
