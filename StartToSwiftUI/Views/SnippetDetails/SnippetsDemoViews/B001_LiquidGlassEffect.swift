//
//  B001_GlassEffect.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.03.2026.
//

import SwiftUI

@available(iOS 26, *)
struct B001_LiquidGlassEffectDemo: View {
    
    @State private var phase: Float = 0
    @State private var selectedCard: String? = nil
    @State private var isExpanded = false
    
    private let cards = ["swift", "swift.fill", "cpu", "network", "waveform", "sparkles"]
    
    var body: some View {
        ZStack {
            animatedBackground
            content
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: true)) {
                phase = 1
            }
        }
    }
    
    // MARK: - Animated Mesh Background
    
    private var animatedBackground: some View {
        MeshGradient(
            width: 3, height: 3,
            points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.5], [0.3 + 0.4 * phase, 0.5 + 0.2 * sin(phase * .pi)], [1.0, 0.5],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
            ],
            colors: [
                .purple, .indigo, .blue,
                .pink,   .cyan,   .teal,
                .orange, .purple, .mint
            ]
        )
        .animation(.linear(duration: 4).repeatForever(autoreverses: true), value: phase)
    }
    
    // MARK: - Content
    
    private var content: some View {
        VStack(spacing: 24) {
            headerCard
            iconsGrid
            actionButton
        }
        .padding(24)
    }
    
    // MARK: - Header Card
    
    private var headerCard: some View {
        VStack(spacing: 8) {
            Image(systemName: "apple.logo")
                .font(.system(size: 44))
                .symbolEffect(.pulse, isActive: true)
            Text("Liquid Glass")
                .font(.title2.bold())
            Text("iOS 26 · .glassEffect()")
                .font(.caption)
                .opacity(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .glassEffect()                    // ← основной модификатор
    }
    
    // MARK: - Icons Grid
    
    private var iconsGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
            ForEach(cards, id: \.self) { icon in
                iconCard(icon)
            }
        }
    }
    
    private func iconCard(_ icon: String) -> some View {
        let isSelected = selectedCard == icon
        return VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .symbolEffect(.bounce, value: isSelected)
            Text(icon.components(separatedBy: ".").first ?? icon)
                .font(.caption2)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 72)
        .glassEffect(                      // ← с параметрами
            .regular.interactive(),        // реагирует на нажатие
            in: .rect(cornerRadius: 16)
        )
        .scaleEffect(isSelected ? 1.08 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        .onTapGesture {
            selectedCard = (selectedCard == icon) ? nil : icon
        }
    }
    
    // MARK: - Action Button
    
    private var actionButton: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isExpanded.toggle()
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: isExpanded ? "minus.circle" : "plus.circle")
                    .contentTransition(.symbolEffect(.replace))
                Text(isExpanded ? "Collapse" : "Expand")
                    .font(.headline)
            }
            .frame(maxWidth: isExpanded ? .infinity : 160)
            .frame(height: 50)
            .glassEffect(.regular.interactive(), in: .capsule)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    if #available(iOS 26, *) {
        B001_LiquidGlassEffectDemo()
    }
}
