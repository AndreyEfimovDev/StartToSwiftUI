//
//  Transition.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 15.03.2026.
//

import SwiftUI

struct A006_FrameTransitionDemo: View {
    
    @State private var selectedTab: FrameTab = .bottomBottom
    
    enum FrameTab: CaseIterable {
        case bottomBottom, bottomRight, rightRight, sliderStyle
    }

    var body: some View {
        GeometryReader { geo in
            
            let availableHeight = geo.size.height * 0.5
            let availableWidth = geo.size.width
            
            VStack(spacing: 0) {
                
                A006_SegmentedOneLinePickerNotOptional(
                    selection: $selectedTab,
                    allItems: FrameTab.allCases,
                    titleForCase: { tab in
                        switch tab {
                        case .bottomBottom: return "↑↓"
                        case .bottomRight: return "↑→"
                        case .rightRight: return "←→"
                        case .sliderStyle: return "←←"
                        }
                    }
                )
                .padding(.horizontal)
                .padding(.top, 8)
                
                switch selectedTab {
                    // bottom in, bottom out
                case .bottomBottom: A006_FrameBottomTransition(height: availableHeight)
                    // bottom in, right out
                case .bottomRight:  A006_FrameBottomRightTransition(height: availableHeight, width: availableWidth)
                    // right in, right out
                case .rightRight:   A006_FrameRightRightTransition(height: availableHeight)
                    // right in, left out (slider)
                case .sliderStyle:       A006_FrameSliderTransition(height: availableHeight, width: availableWidth)
                }
            }
        }
    }
}

#Preview {
    A006_FrameTransitionDemo()
}

struct A006_FrameBottomTransition: View {
    
    @State private var showView: Bool = false
    
    let height: CGFloat
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Button {
                    showView.toggle()
                }
                label: {
                    Text("Animate Bottom-Bottom")
                        .font(.headline)
                        .foregroundStyle(Color.mycolor.myRed)
                        .padding()
                        .background(.ultraThinMaterial, in: .capsule)
                        .overlay(Capsule().stroke(Color.mycolor.myRed, lineWidth: 1))
                }
                Spacer()
            }
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.mycolor.myRed.A006_verticalGradient())
                .frame(height: height)
                .offset(y: showView ? 0 : height)
                .animation(.easeInOut(duration: 0.5), value: showView)
        }
        .clipped()
        .padding(.top)
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct A006_FrameBottomRightTransition: View {
    /*
     Logic:
     - Appearance: snap offset to (0, height) off-screen below, then animate to (0, 0)
     - Disappearance: animate to (width, 0) — no asyncAfter reset needed
     - Offset reset happens lazily on the next appearance tap, before the animation starts
     - This eliminates the asyncAfter race that caused flickering
     */
    @State private var showView: Bool = false
    @State private var offset: CGSize

    let height: CGFloat
    let width: CGFloat

    private let duration: Double = 0.5

    init(height: CGFloat, width: CGFloat) {
        self.height = height
        self.width = width
        _offset = State(initialValue: CGSize(width: 0, height: height))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Button {
                    if !showView {
                        // snap to start position (below screen, invisible), then animate up
                        showView = true
                        offset = CGSize(width: 0, height: height)
                        DispatchQueue.main.async {
                            withAnimation(.easeInOut(duration: duration)) {
                                offset = .zero
                            }
                        }
                    } else {
                        // animate exit to the right — offset stays there, reset on next show
                        showView = false
                        withAnimation(.easeInOut(duration: duration)) {
                            offset = CGSize(width: width, height: 0)
                        }
                    }
                } label: {
                    Text("Animate Bottom-Right")
                        .font(.headline)
                        .foregroundStyle(Color.mycolor.myGreen)
                        .padding()
                        .background(.ultraThinMaterial, in: .capsule)
                        .overlay(Capsule().stroke(Color.mycolor.myGreen, lineWidth: 1))
                }
                Spacer()
            }

            UnevenRoundedRectangle(cornerRadii: .init(
                topLeading: 30,
                topTrailing: 30
            ))
            .fill(Color.mycolor.myGreen.A006_verticalGradient())
            .frame(height: height)
            .offset(offset)
        }
        .clipped()
        .padding(.top)
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct A006_FrameRightRightTransition: View {
    
    @State private var showView: Bool = false
    
    let height: CGFloat

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Button {
                    showView.toggle()
                } label: {
                    Text("Animate Right-Right")
                        .foregroundStyle(Color.mycolor.myOrange)
                        .font(.headline)
                        .padding()
                        .background(.ultraThinMaterial, in: .capsule)
                        .overlay(Capsule().stroke(Color.mycolor.myOrange, lineWidth: 1))
                }
                Spacer()
            }
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.mycolor.myOrange.A006_verticalGradient())
                .frame(height: height)
                .offset(x: showView ? 0 : UIScreen.main.bounds.width) // from right to left
                .animation(.easeInOut(duration: 0.5), value: showView)
        }
        .clipped()
        .padding(.top)
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct A006_FrameSliderTransition: View {
    
    @State private var showView: Bool = false
    @State private var offset: CGSize

    let height: CGFloat
    let width: CGFloat
    
    private let duration: Double = 0.5
    
    init(height: CGFloat, width: CGFloat) {
            self.height = height
            self.width = width
            _offset = State(initialValue: CGSize(width: width, height: 0))
        }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Button {
                    if !showView {
                        // appearance from the right
                        showView = true
                        withAnimation(.easeInOut(duration: duration)) {
                            offset = .zero
                        }
                    } else {
                        // disappearance to the left
                        withAnimation(.easeInOut(duration: duration)) {
                            offset = CGSize(width: -width, height: 0)
                        }
                        // reset position back to the right after disappearing
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                            showView = false
                            offset = CGSize(width: width, height: 0)
                        }
                    }
                } label: {
                    Text("Animate Slider")
                        .foregroundStyle(Color.mycolor.myPurple)
                        .font(.headline)
                        .padding()
                        .background(.ultraThinMaterial, in: .capsule)
                        .overlay(Capsule().stroke(Color.mycolor.myPurple, lineWidth: 1))
                }
                Spacer()
            }
            
            if showView {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.mycolor.myPurple.A006_verticalGradient())
                    .frame(height: height)
                    .offset(offset)
            }
        }
        .clipped()
        .padding(.top)
        .edgesIgnoringSafeArea(.bottom)
    }
}

extension Color {
    func A006_verticalGradient() -> LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: self.opacity(0.1), location: 0.0),
                .init(color: self.opacity(0.3), location: 0.3),
                .init(color: self.opacity(0.7), location: 0.7),
                .init(color: self.opacity(1.0), location: 1.0)
            ]),
            startPoint: .bottom,
            endPoint: .top
        )
    }
}

struct A006_SegmentedOneLinePickerNotOptional<T: Hashable>: View {
    @Binding var selection: T
    let allItems: [T]
    let titleForCase: (T) -> String
    
    // Colors
    var selectedFont: Font = .footnote
    var selectedTextColor: Color = Color.mycolor.myBackground
    var unselectedTextColor: Color = Color.mycolor.myAccent
    var selectedBackground: Color = Color.mycolor.myButtonBGBlue
    var unselectedBackground: Color = .clear
    
    var body: some View {
        HStack(spacing: 0) {
            // Regular buttons for enum's values
            ForEach(allItems, id: \.self) { item in
                Button {
                    withAnimation(.easeInOut) {
                        selection = item
                    }
                } label: {
                    Text(titleForCase(item))
                        .font(selectedFont)
                        .foregroundColor(selection == item ? selectedTextColor : unselectedTextColor)
                        .frame(width: 60, height: 30)
                        .frame(maxWidth: .infinity)
                        .background(selection == item ? selectedBackground : unselectedBackground)
                }
            } //ForEach
        } // HStack
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(selectedBackground, lineWidth: 1)
        )
    }
}

