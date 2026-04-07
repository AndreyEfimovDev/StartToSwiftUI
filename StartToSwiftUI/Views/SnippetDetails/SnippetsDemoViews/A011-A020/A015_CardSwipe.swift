//
//  A015_CardSwipTinder.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 07.04.2026.
//

import SwiftUI

// Swipe RIGHT  → hide card  (green overlay)
// Swipe LEFT   → active     (blue overlay)
// Swipe UP     → delete     (red overlay + trash icon)
// Tap card     → flip front / back
// [Reset]      → restore all 10 cards

// MARK: - Model

struct DemoCard: Identifiable {
    let id: Int
    var status: DemoStatus = .active
}

enum DemoStatus { case active, hidden, deleted }

// MARK: - ViewModel

@Observable
final class CardSwipeDemoViewModel {
    private(set) var cards: [DemoCard]
    private(set) var currentIndex: Int = 0
    var dragOffset: CGSize = .zero
    var isFlipped: Bool = false
    var isDragging: Bool = false

    init() {
        cards = (1...10).map { DemoCard(id: $0) }
    }

    var currentCard: DemoCard? {
        guard currentIndex < cards.count else { return nil }
        return cards[currentIndex]
    }

    var isDone: Bool { currentIndex >= cards.count }

    var swipeProgress: CGFloat {
        dragOffset.width / 110
    }

    func flipToggle() {
        isFlipped.toggle()
    }

    func advance() {
        isFlipped = false
        dragOffset = .zero
        isDragging = false
        currentIndex += 1
    }
    
    // hide
    func swipeRight() {
        cards[currentIndex].status = .hidden
        advance()
    }

    // keep active
    func swipeLeft() {
        cards[currentIndex].status = .active
        advance()
    }

    // delete
    func swipeUp() {
        cards[currentIndex].status = .deleted
        advance()
    }

    func reset() {
        cards = (1...10).map { DemoCard(id: $0) }
        currentIndex = 0
        dragOffset = .zero
        isFlipped = false
        isDragging = false
    }
}

// MARK: - Root View

struct A015_CardSwipeDemo: View {

    @State private var vm = CardSwipeDemoViewModel()
    @GestureState private var dragIsActive = false

    private let swipeThreshold:   CGFloat = 110
    private let upSwipeThreshold: CGFloat = 100

    // How far up the card has been dragged (0…1), only on front face.
    private var upSwipeProgress: Double {
        guard !vm.isFlipped,
              vm.dragOffset.height < -10,
              abs(vm.dragOffset.width) < 55 else { return 0 }
        return min(1.0, abs(Double(vm.dragOffset.height)) / Double(upSwipeThreshold))
    }

    var body: some View {
        VStack(spacing: 0) {

            // Header
            headerRow
                .padding(16)
                .padding(.bottom, 8)
            
            // Card area
            ZStack {
                if vm.isDone {
                    doneCard
                } else {
                    cardStack
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 16)
            .padding(.top, 8)

            // Reset button
            Button {
                withAnimation(.spring(duration: 0.4, bounce: 0.2)) { vm.reset() }
            } label: {
                Label("Reset", systemImage: "arrow.counterclockwise")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.mycolor.myAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.mycolor.mySecondary.opacity(0.5), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.bottom, 28)
            .padding(.top, 12)
        }
        .background(.clear)
        .animation(.spring(duration: 0.3), value: vm.currentIndex)
        .animation(.spring(duration: 0.3), value: vm.isFlipped)
        .animation(.spring(duration: 0.4), value: vm.isDone)
    }

    // MARK: Header

    private var headerRow: some View {
        let total   = vm.cards.count
        let done    = vm.currentIndex
        let remaining = total - done
        let progress  = total > 0 ? CGFloat(done) / CGFloat(total) : 0

        return VStack(spacing: 6) {
            HStack {
                Text("Cards left: \(max(remaining, 0))")
                Spacer()
                Text("\(done) / \(total)")
                    .font(.caption.weight(.semibold))
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(Color.mycolor.myAccent)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.mycolor.mySecondary.opacity(0.5))
                        .frame(height: 4)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.mycolor.myAccent)
                        .frame(width: geo.size.width * progress, height: 4)
                        .animation(.spring(duration: 0.4), value: progress)
                }
            }
            .frame(height: 4)
        }
    }

    // MARK: Card Stack

    private var cardStack: some View {
        ZStack {
            let dragProgress = min(1.0, abs(vm.dragOffset.width) / swipeThreshold)

            // Background ghost cards
            ForEach([2, 1], id: \.self) { offset in
                let idx = vm.currentIndex + offset
                if idx < vm.cards.count {
                    let step:       CGFloat = 0.06
                    let yStep:      CGFloat = -28.0
                    let baseScale   = 1.0 - CGFloat(offset) * step
                    let targetScale = 1.0 - CGFloat(offset - 1) * step
                    let scale       = baseScale + (targetScale - baseScale) * dragProgress
                    let baseY       = CGFloat(offset) * yStep
                    let targetY     = CGFloat(offset - 1) * yStep
                    let yOffset     = baseY + (targetY - baseY) * dragProgress

                    ghostCard(vm.cards[idx])
                        .scaleEffect(scale)
                        .offset(y: yOffset)
                        .shadow(color: Color.mycolor.myButtonTextSecondary.opacity(0.08), radius: 12, x: 0, y: 4)
                }
            }

            // Top card
            if let card = vm.currentCard {
                topCard(card)
                    .id(vm.currentIndex)
                    .transition(.asymmetric(insertion: .scale(scale: 0.96), removal: .identity))
                    .zIndex(1)
            }

            // Trash icon on upward drag
            if upSwipeProgress > 0 {
                VStack {
                    ZStack {
                        Circle()
                            .fill(Color.mycolor.myRed.opacity(0.12 * upSwipeProgress))
                            .frame(width: 72, height: 72)
                        Image(systemName: "trash.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.mycolor.myRed)
                            .scaleEffect(0.7 + 0.5 * upSwipeProgress)
                    }
                    .opacity(upSwipeProgress)
                    .padding(.top, 12)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(false)
                .zIndex(2)
            }
        }
    }

    // MARK: Top Card

    private func topCard(_ card: DemoCard) -> some View {
        let yOffset: CGFloat = vm.isFlipped ? 0 :
            (vm.dragOffset.height < -5 ? vm.dragOffset.height : vm.dragOffset.height * 0.15)
        let scale = max(0.3, 1.0 - 0.5 * upSwipeProgress)

        return cardContainer(card)
            .overlay(swipeOverlay)
            .offset(x: vm.dragOffset.width, y: yOffset)
            .rotationEffect(.degrees(Double(vm.dragOffset.width) / 18))
            .scaleEffect(scale)
            .shadow(color: Color.mycolor.myButtonTextSecondary.opacity(0.25), radius: 12, x: 0, y: -6)
            .simultaneousGesture(dragGesture)
            .onTapGesture {
                guard !dragIsActive, !vm.isDragging else { return }
                withAnimation(.spring(duration: 0.5, bounce: 0.15)) { vm.flipToggle() }
            }
            .onChange(of: dragIsActive) { _, isActive in
                guard !isActive else { return }
                let isFlying = abs(vm.dragOffset.width) > 400 || vm.dragOffset.height < -400
                if !isFlying {
                    withAnimation(.spring(duration: 0.4, bounce: 0.4)) { vm.dragOffset = .zero }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { vm.isDragging = false }
            }
    }

    // MARK: Card Container

    private func cardContainer(_ card: DemoCard) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24).fill(Color.mycolor.myBackground)
            flipContent(card)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    // MARK: Flip Content

    private func flipContent(_ card: DemoCard) -> some View {
        ZStack {
            // Front
            frontFace(card)
                .rotation3DEffect(.degrees(vm.isFlipped ? 180 : 0), axis: (0, 1, 0), perspective: 0.5)
                .opacity(vm.isFlipped ? 0 : 1)
                .allowsHitTesting(!vm.isFlipped)

            // Back
            backFace(card)
                .rotation3DEffect(.degrees(vm.isFlipped ? 0 : -180), axis: (0, 1, 0), perspective: 0.5)
                .opacity(vm.isFlipped ? 1 : 0)
                .allowsHitTesting(vm.isFlipped)
        }
        .animation(.spring(duration: 0.5, bounce: 0.15), value: vm.isFlipped)
    }

    // MARK: Front Face

    private func frontFace(_ card: DemoCard) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Text("Front side")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.mycolor.mySecondary)
                .textCase(.uppercase)
                .tracking(1.5)
            Text("\(card.id)")
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .foregroundStyle(Color.mycolor.myAccent)
            Spacer()
            // Swipe hints
            HStack(spacing: 0) {
                hintLabel("← Active", color: Color.mycolor.myBlue)
                Spacer()
                hintLabel("Hide →", color: Color.mycolor.myGreen)
            }
            .padding(.horizontal, 24)
            hintLabel("↑ Delete", color: Color.mycolor.myRed)
            Text("Tap to flip")
                .font(.caption2)
                .foregroundStyle(Color.mycolor.mySecondary)
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: Back Face

    private func backFace(_ card: DemoCard) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Text("Back side")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.mycolor.mySecondary)
                .textCase(.uppercase)
                .tracking(1.5)
            Text("\(card.id)")
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .foregroundStyle(Color.mycolor.myOrange)
            Text("Card \(card.id) of \(vm.cards.count)")
                .font(.subheadline)
                .foregroundStyle(Color.mycolor.mySecondary)
            Spacer()
            Text("Tap to flip back")
                .font(.caption2)
                .foregroundStyle(Color.mycolor.mySecondary)
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: Ghost Card (background stack)

    private func ghostCard(_ card: DemoCard) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24).fill(Color(.systemBackground))
            Text("\(card.id)")
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .foregroundStyle(Color.mycolor.myAccent.opacity(0.25))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    // MARK: Swipe Colour Overlay

    private var swipeOverlay: some View {
        let color: Color
        let opacity: Double
        if upSwipeProgress > 0 {
            color = Color.mycolor.myRed; opacity = upSwipeProgress * 0.4
        } else {
            let p = vm.swipeProgress
            color = p > 0 ? Color.mycolor.myGreen : Color.mycolor.myBlue
            opacity = abs(p) * 0.40
        }
        return RoundedRectangle(cornerRadius: 24)
            .fill(color.opacity(opacity))
            .allowsHitTesting(false)
    }

    // MARK: Drag Gesture

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 15)
            .updating($dragIsActive) { _, state, _ in state = true }
            .onChanged { value in
                guard !vm.isFlipped else { return }
                vm.isDragging = true
                vm.dragOffset = value.translation
            }
            .onEnded { value in
                guard !vm.isFlipped else { return }
                let dx = value.translation.width
                let dy = value.translation.height

                if dx > swipeThreshold {
                    withAnimation(.spring(duration: 0.35)) {
                        vm.dragOffset = CGSize(width: 650, height: dy * 0.3)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { vm.swipeRight() }

                } else if dx < -swipeThreshold {
                    withAnimation(.spring(duration: 0.35)) {
                        vm.dragOffset = CGSize(width: -650, height: dy * 0.3)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { vm.swipeLeft() }

                } else if dy < -upSwipeThreshold && abs(dx) < 55 {
                    withAnimation(.spring(duration: 0.4)) {
                        vm.dragOffset = CGSize(width: 0, height: -850)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { vm.swipeUp() }
                }
                // Return-to-centre handled by onChange(of: dragIsActive)
            }
    }

    // MARK: Done Card

    private var doneCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24).fill(Color(.systemBackground))
            VStack(spacing: 20) {
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.mycolor.myGreen)
                Text("All done!")
                    .font(.title.bold())
                Text("Tap Reset to start over.")
                    .font(.subheadline)
                    .foregroundStyle(Color.mycolor.mySecondary)
                Text("All done!")

                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.mycolor.myButtonTextSecondary.opacity(0.09), radius: 16, x: 0, y: 6)
        .transition(.scale(scale: 0.95).combined(with: .opacity))
    }

    // MARK: Helpers

    private func hintLabel(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(color.opacity(0.55))
    }
}

// MARK: - Preview

#Preview {
    A015_CardSwipeDemo()
}

