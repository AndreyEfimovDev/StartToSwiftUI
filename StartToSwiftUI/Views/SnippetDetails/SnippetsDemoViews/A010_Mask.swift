//
//  A010_Mask.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 20.03.2026.
//

import SwiftUI

// MARK: Mask Rating Example
/*
 How .mask works here — dual use of a single view:

 iconsView              ← base layer: gray stars
     .overlay(
         fillOverlay    ← yellow rectangle, width grows with selectedRating
             .mask(
                 iconsView  ← same stars used as alpha mask
             )
     )

 The yellow rectangle is visible only through the star shapes,
 creating a "fill" effect as the rating increases.
 Base stars remain visible underneath as a fallback (unselected state).
 */

struct A010_MaskDemo: View {
    
    @State private var selectedRating: StarRating? = nil
 
    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                label
                iconsView
                    .overlay(
                        fillOverlay
                            .mask(iconsView)   // ← the key line
                    )
                    .animation(.easeInOut(duration: 0.25), value: selectedRating)
            }
            resetButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
 
    // MARK: - Subviews
    
    private var iconsView: some View {
        HStack(spacing: 12) {
            ForEach(StarRating.allCases, id: \.self) { rating in
                rating.icon
                    .font(.system(size: 36))
                    .foregroundStyle(Color.mycolor.myButtonBGGray)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            selectedRating = rating
                        }
                    }
            }
        }
    }

    private var fillOverlay: some View {
        GeometryReader { geo in
            let total    = CGFloat(StarRating.allCases.count)
            let selected = CGFloat(selectedRating.flatMap {
                StarRating.allCases.firstIndex(of: $0)
            }.map { $0 + 1 } ?? 0)

            ZStack(alignment: .leading) {
                LinearGradient(
                    colors: [Color.mycolor.myYellow, Color.mycolor.myOrange],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: selected / total * geo.size.width)
            }
        }
        .allowsHitTesting(false) // .overlay will not intercept taps instead of icons below it
    }

    @ViewBuilder
    private var label: some View {
        Group {
            if let rating = selectedRating {
                Text(rating.label)
                    .transition(.scale.combined(with: .opacity))
            } else {
                Text("Tap a star")
            }
        }
        .font(.title)
        .foregroundStyle(Color.mycolor.myAccent)
    }
    
    private var resetButton: some View {
        Group {
            if selectedRating != nil {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        selectedRating = nil
                    }
                } label: {
                    Text("Reset")
                        .font(.title)
                        .foregroundStyle(Color.mycolor.myRed)
                        .padding(.horizontal)
                        .frame(height: 55)
                        .background(.ultraThinMaterial, in: .capsule)
                }
            }
        }
        .offset(y: 108)
    }

}

private enum StarRating: Int, CaseIterable {
    case good, great, excellent
 
    var icon: Image {
        Image(systemName: "star.fill")
    }

    var label: String {
        switch self {
        case .good: "Good"
        case .great: "Great"
        case .excellent: "Excellent"
        }
    }
}


#Preview {
    A010_MaskDemo()
}
