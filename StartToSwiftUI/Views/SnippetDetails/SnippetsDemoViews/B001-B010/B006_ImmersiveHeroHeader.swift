//
//  B006_ImmersiveHeroHeader.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 21.09.2026.
//

import SwiftUI

@available(iOS 26.0, *)
struct B006_ImmersiveHeroHeaderDemo: View {
    var body: some View {
        ScrollView {
            hero
        }
    }

    // MARK: - Hero

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [Color.mycolor.myBlue, Color.mycolor.myPurple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: "mountain.2.fill")
                .font(.system(size: 160))
                .foregroundStyle(.white.opacity(0.25))
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            caption
        }
        .frame(height: 520)
        .frame(maxWidth: .infinity)
        // Mirrors and blurs this view into the safe area around it, so the
        // hero appears to continue behind the glass toolbar/sidebar instead
        // of stopping at a hard edge.
        .backgroundExtensionEffect()
    }

    // MARK: - Caption

    private var caption: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Glacier Bay")
                .font(.title.bold())
            Text("Tidewater glaciers calve into the sea here — home to humpback whales, sea otters, and nesting bald eagles.")
                .font(.subheadline)
                .lineLimit(2)
        }
        .foregroundStyle(.white)
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [.clear, .black.opacity(0.65)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        B006_ImmersiveHeroHeaderDemo()
    }
}
