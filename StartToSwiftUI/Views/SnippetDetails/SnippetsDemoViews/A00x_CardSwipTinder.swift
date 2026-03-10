//
//  A00x_CardSwipTinder.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 10.03.2026.
//

import SwiftUI

struct A00x_CardSwipTinder: View {
    @State var cards: [ExampleCardView]
    
    var body: some View {
        VStack {
            Text("Swipe Cards")
                .font(.title)
                .foregroundColor(.gray)
            Button {
                print("Resetting...")
                loadCards()
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise.circle.fill")
                    Text("Reset Cards")
                }
            }
            
            // Cards
            CardSwiperView(cards: self.$cards , onCardSwiped: { swipeDirection, index in
                
                switch swipeDirection {
                case .left:
                    print("Card swiped Left direction at index \(index)")
                case .right:
                    print("Card swiped Right direction at index \(index)")
                case .top:
                    print("Card swiped Top direction at index \(index)")
                case .bottom:
                    print("Card swiped Bottom direction at index \(index)")
                }
            }, onCardDragged: { swipeDirection, index, offset in
                print("Card dragged \(swipeDirection) direction at index \(index) with offset \(offset)")
            })
            .padding(.vertical, 20)
        }
        .onAppear {
            loadCards()
        }
    }
    
    private func loadCards() {
        let newCards = [
            ExampleCardView(index: 0),
            ExampleCardView(index: 1),
            ExampleCardView(index: 2),
            ExampleCardView(index: 3),
            ExampleCardView(index: 5),
            ExampleCardView(index: 6),
            ExampleCardView(index: 7),
            ExampleCardView(index: 8)
        ]
        // Assigning a new array instance to the @State variable
        cards = newCards
    }

}

#Preview {
    A00x_CardSwipTinder(cards: [])
}


enum SwipeDirection {
    case left, right, top, bottom
}

struct ExampleCardView: View {
    var index: Int
    var tagId: UUID = UUID()

    var body: some View {

        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white)
            .overlay(
                VStack(spacing: 10) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.pink)
                    Text("Example Card \(index)")
                        .font(.title)
                        .bold()
                    Text("This is an example card with some beautiful UI.")
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .foregroundColor(.gray)
                }
                .padding()
            )
            .shadow(color: .gray, radius: 5)
    }
}

public struct CardSwiperView<Content: View>: View {
    
    @Binding var cards: [Content]
    
    var onCardSwiped: ((SwipeDirection, Int) -> Void)?
    var onCardDragged: ((SwipeDirection, Int, CGSize) -> Void)? // New callback
    var initialOffsetY: CGFloat = 5
    var initialRotationAngle: Double = 0.5
    
    init(
        cards: Binding<[Content]>,
        onCardSwiped: ((SwipeDirection, Int) -> Void)? = nil,
        onCardDragged: ((SwipeDirection, Int, CGSize) -> Void)? = nil, // Initialize new callback
        initialOffsetY: CGFloat = 5,
        initialRotationAngle: Double = 0.5
    ) {
        self._cards = cards
        self.onCardSwiped = onCardSwiped
        self.onCardDragged = onCardDragged // Set the new callback
        self.initialOffsetY = initialOffsetY
        self.initialRotationAngle = initialRotationAngle
    }
    
    public var body: some View {
        ZStack {
            ForEach(cards.indices, id: \.self) { index in
                CardView(
                    index: index,
                    onCardSwiped: { swipeDirection in
                        onCardSwiped?(swipeDirection, index)
                    },
                    onCardDragged: { direction, index, offset in // Pass the drag details to the callback
                        onCardDragged?(direction, index, offset)
                    },
                    content: {
                        cards[index]
                    },
                    initialOffsetY: initialOffsetY,
                    initialRotationAngle: initialRotationAngle,
                    zIndex: Double(cards.count - index)
                )
                .id(UUID())
            }
        }
    }
    
    private struct CardView: View {
        var index: Int
        var onCardSwiped: ((SwipeDirection) -> Void)?
        var onCardDragged: ((SwipeDirection, Int, CGSize) -> Void)? // New callback
        var content: () -> Content
        var initialOffsetY: CGFloat
        var initialRotationAngle: Double
        var zIndex: Double
        
        @State private var offset = CGSize.zero
        @State private var overlayColor: Color = .clear
        @State private var isRemoved = false
        @State private var activeCardIndex: Int?
        
        var body: some View {
            ZStack {
                content()
                    .frame(width: 320, height: 420)
                    .offset(x: offset.width * 1, y: offset.height * 0.4)
                    .rotationEffect(.degrees(Double(offset.width / 40)))
                    .zIndex(zIndex)
                
                Rectangle()
                    .foregroundColor(overlayColor)
                    .opacity(isRemoved ? 0 : (activeCardIndex == index ? 1 : 0))
                    .frame(width: 320, height: 420)
                    .cornerRadius(10)
                    .blendMode(.overlay)
            }
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation
                        activeCardIndex = index
                        withAnimation {
                            handleCardDragging(offset) // Handle card dragging
                        }
                    }
                    .onEnded { gesture in
                        withAnimation {
                            handleSwipe(offsetWidth: offset.width, offsetHeight: offset.height)
                        }
                    }
            )
            .opacity(isRemoved ? 0 : 1)
        }
        
        func handleCardDragging(_ offset: CGSize) {
            var swipeDirection: SwipeDirection = .left
            
            switch (offset.width, offset.height) {
            case (-500...(-150), _):
                swipeDirection = .left
            case (150...500, _):
                swipeDirection = .right
            case (_, -500...(-150)):
                swipeDirection = .top
            case (_, 150...500):
                swipeDirection = .bottom
            default:
                break
            }
            
            onCardDragged?(swipeDirection, index, offset) // Trigger the new callback
        }
        
        func handleSwipe(offsetWidth: CGFloat, offsetHeight: CGFloat) {
            var swipeDirection: SwipeDirection = .left
            
            switch (offsetWidth, offsetHeight) {
            case (-500...(-150), _):
                swipeDirection = .left
                offset = CGSize(width: -500, height: 0)
                isRemoved = true
                onCardSwiped?(swipeDirection)
            case (150...500, _):
                swipeDirection = .right
                offset = CGSize(width: 500, height: 0)
                isRemoved = true
                onCardSwiped?(swipeDirection)
            case (_, -500...(-150)):
                swipeDirection = .top
                offset = CGSize(width: 0, height: -500)
                isRemoved = true
                onCardSwiped?(swipeDirection)
            case (_, 150...500):
                swipeDirection = .bottom
                offset = CGSize(width: 0, height: 500)
                isRemoved = true
                onCardSwiped?(swipeDirection)
            default:
                offset = .zero
                overlayColor = .clear // If not completely removed, change overlay color to clear
            }
        }
    }
}
