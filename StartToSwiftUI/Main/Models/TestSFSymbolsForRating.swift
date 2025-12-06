//
//  TestSFSymbolsForRating.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 06.12.2025.
//

import SwiftUI

struct TestSFSymbolsForRating: View {
    var body: some View {
        
        VStack(spacing: 20){
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle")
                Image(systemName: "star.circle")
                Image(systemName: "sparkles")
            }
            HStack(spacing: 10) {
                Image(systemName: "arrow.up.circle")
                Image(systemName: "arrow.up.circle.fill")
                Image(systemName: "chart.line.uptrend.xyaxis")
            }
            HStack(spacing: 10) {
                Image(systemName: "face.smiling")
                Image(systemName: "star.fill")
                Image(systemName: "crown.fill")
            }
            .foregroundStyle(Color.mycolor.myGreen)
            HStack(spacing: 10) {
                Image(systemName: "seal")
                Image(systemName: "rosette")
                Image(systemName: "trophy.fill")
            }
            HStack(spacing: 10) {
                Image(systemName: "circle")
                Image(systemName: "circle.inset.filled")
                Image(systemName: "diamond.fill")
            }
        }
        .font(.title)
    }
}

#Preview {
    TestSFSymbolsForRating()
}
