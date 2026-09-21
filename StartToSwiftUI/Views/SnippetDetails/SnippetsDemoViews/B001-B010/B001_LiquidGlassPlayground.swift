//
//  B001_LiquidGlassPlayground.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 19.09.2026.
//

import SwiftUI

private enum GlassStatus: CaseIterable {
    case idle, success, error

    var label: String {
        switch self {
        case .idle: "Idle"
        case .success: "Success"
        case .error: "Error"
        }
    }

    var icon: String {
        switch self {
        case .idle: "circle"
        case .success: "checkmark.circle.fill"
        case .error: "exclamationmark.triangle.fill"
        }
    }

    var tint: Color {
        switch self {
        case .idle: Color.mycolor.myBlue
        case .success: Color.mycolor.myGreen
        case .error: Color.mycolor.myRed
        }
    }

    var next: GlassStatus {
        switch self {
        case .idle: .success
        case .success: .error
        case .error: .idle
        }
    }
}

@available(iOS 26.0, *)
struct B001_LiquidGlassPlaygroundDemo: View {
    // MARK: - Merge state
    @State private var isMerged = false

    // MARK: - Morph disclosure state
    @Namespace private var glassNamespace
    @State private var isExpanded = false

    // MARK: - Tinted status state
    @State private var status: GlassStatus = .idle
    
    var body: some View {
        ScrollView {
            VStack(spacing: 50) {
                dragToMergeSection
                morphDisclosureSection
                tintedGlassSection
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }

    // MARK: - 1. Tap to merge/split two bubbles
    private var dragToMergeSection: some View {
        VStack(spacing: 12) {
            Text("GlassEffectContainer")
                .font(.headline)
                .foregroundStyle(Color.mycolor.myAccent)

            Text("combines multiple glass shapes into a single")
                .font(.subheadline)
                .foregroundStyle(Color.mycolor.myAccent)
                .multilineTextAlignment(.center)

            Text("shape when they're close enough together")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            GlassEffectContainer(spacing: 40) {
                HStack(spacing: 40) {
                    glassBubble(icon: "heart.fill", pullTogether: isMerged ? 35 : 0)
                    glassBubble(icon: "star.fill", pullTogether: isMerged ? -35 : 0)
                }
            }
            .frame(height: 100)

            Text(isMerged ? "Split" : "Merge")
                .font(.subheadline)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .glassEffect(.regular.interactive(), in: Capsule())
                .onTapGesture {
                    withAnimation(
                        .spring(
                            response: 1.0,
                            dampingFraction: 0.85
                        )
                    ) {
                        isMerged.toggle()
                    }
                }
        }
    }

    private func glassBubble(icon: String, pullTogether: CGFloat) -> some View {
        Image(systemName: icon)
            .font(.title2)
            .frame(width: 70, height: 70)
            .glassEffect(.regular.interactive(), in: Circle())
            .offset(x: pullTogether)
    }

    // MARK: - 2. Morph a small button into a wider control panel
    private var morphDisclosureSection: some View {
        
        VStack(spacing: 12) {
            Text(".glassEffectID")
                .font(.headline)
                .foregroundStyle(Color.mycolor.myAccent)

            Text("separate glass shapes merge into and split from a shared control")
                .font(.subheadline)
                .foregroundStyle(Color.mycolor.myAccent)
                .multilineTextAlignment(.center)

            Text("Tap to expand")
                .font(.caption)
                .foregroundStyle(.secondary)

            GlassEffectContainer(spacing: 20) {
                HStack(spacing: 20) {
                    Image(systemName: isExpanded ? "xmark" : "plus")
                        .font(.title2)
                        .frame(width: 56, height: 56)
                        .glassEffect(.regular.interactive(), in: Circle())
                        .glassEffectID("toggle", in: glassNamespace)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isExpanded.toggle()
                            }
                        }

                    if isExpanded {
                        controlButton(icon: "backward.fill", id: "backward")
                        controlButton(icon: "pause.fill", id: "pause")
                        controlButton(icon: "forward.fill", id: "forward")
                    }
                }
            }
        }
    }

    private func controlButton(icon: String, id: String) -> some View {
        Image(systemName: icon)
            .font(.title2)
            .frame(width: 56, height: 56)
            .glassEffect(.regular.interactive(), in: Circle())
            .glassEffectID(id, in: glassNamespace)
    }

    // MARK: - 3. Tinted glass communicates state at a glance
    private var tintedGlassSection: some View {
        VStack(spacing: 12) {
            Text(".tint(_:)")
                .font(.headline)
                .foregroundStyle(Color.mycolor.myAccent)

            Text("recolors the glass to communicate state at a glance")
                .font(.subheadline)
                .foregroundStyle(Color.mycolor.myAccent)
                .multilineTextAlignment(.center)

            Text("Tap to cycle the status")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                Image(systemName: status.icon)
                Text(status.label)
            }
            .font(.headline)
            .foregroundStyle(Color.mycolor.myButtonTextPrimary)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .glassEffect(.regular.tint(status.tint).interactive(), in: Capsule())
            .onTapGesture {
                withAnimation(.bouncy(duration: 0.3)) {
                    status = status.next
                }
            }
        }
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        B001_LiquidGlassPlaygroundDemo()
    }
}
