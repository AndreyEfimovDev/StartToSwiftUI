//
//  Transition.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 15.03.2026.
//

import SwiftUI

struct A006_SheetTransitionDemo: View {
    
    var body: some View {
        TabView {
            // bottom in, bottom out
            Tab("Bottom-Bottom", systemImage: "1.circle") {
                A006_SheetBottomTransition()
            }
            // bottom in, right out
            Tab("Bottom-Right", systemImage: "2.circle") {
                A006_SheetBottomRightTransition()
            }
            // right in, right out
            Tab("Right-Right", systemImage: "3.circle") {
                A006_SheetRightRightTransition()
            }
            // right in, left out (slider)
            Tab("Slider", systemImage: "4.circle") {
                A006_SheetSliderTransition()
            }
        }
    }
}

#Preview {
    A006_SheetTransitionDemo()
}

struct A006_SheetBottomTransition: View {
    
    @State var showView: Bool = false
    
    let height = UIScreen.main.bounds.height * 0.5
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Button {
                    showView.toggle()
                }
                label: {
                    Text("ANIMATE SHEET")
                        .font(.headline)
                        .foregroundStyle(Color.mycolor.myRed)
                        .padding()
                        .background(.ultraThinMaterial, in: .capsule)
                }
                Spacer()
            }
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.mycolor.myRed.opacity(0.1))
                .frame(height: height)
                .offset(y: showView ? 0 : height)
                .animation(.easeInOut(duration: 0.5), value: showView)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct A006_SheetBottomRightTransition: View {
    /*
     Logic:
     - Initial offset = width — hidden behind the right edge
     - Appearance → offset = 0 (moves from right to left)
     - Disappearance → offset = -width (moves left)
     - asyncAfter resets the offset back to width while the view is hidden
     */
    @State var showView: Bool = false
    @State var offset: CGSize = CGSize(width: 0, height: UIScreen.main.bounds.height * 0.5)
    
    let height = UIScreen.main.bounds.height * 0.5
    let width = UIScreen.main.bounds.width
    let duration: Double = 0.5
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Button {
                    if !showView {
                        // appearance from the bottom
                        showView = true
                        withAnimation(.easeInOut(duration: duration)) {
                            offset = .zero
                        }
                    } else {
                        // disappearance to the right
                        withAnimation(.easeInOut(duration: duration)) {
                            offset = CGSize(width: width, height: 0)
                        }
                        // resetting the position back down after disappearing
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                            showView = false
                            offset = CGSize(width: 0, height: height)
                        }
                    }
                } label: {
                    Text("ANIMATE SHEET")
                        .font(.headline)
                        .foregroundStyle(Color.mycolor.myGreen)
                        .padding()
                        .background(.ultraThinMaterial, in: .capsule)
                }
                Spacer()
            }
            
            if showView {
                UnevenRoundedRectangle(cornerRadii: .init(
                    topLeading: 30,
                    topTrailing: 30
                ))
                .fill(Color.mycolor.myGreen.opacity(0.1))
                .frame(height: height)
                .offset(offset)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
}

struct A006_SheetRightRightTransition: View {
    @State var showView: Bool = false
    
    let height = UIScreen.main.bounds.height * 0.5
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Button {
                    showView.toggle()
                } label: {
                    Text("ANIMATE SHEET")
                        .foregroundStyle(Color.mycolor.myOrange)
                        .font(.headline)
                        .padding()
                        .background(.ultraThinMaterial, in: .capsule)
                }
                Spacer()
            }
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.mycolor.myOrange.opacity(0.1))
                .frame(height: height)
                .offset(x: showView ? 0 : UIScreen.main.bounds.width) // from right to left
                .animation(.easeInOut(duration: 0.5), value: showView)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct A006_SheetSliderTransition: View {
    @State var showView: Bool = false
    @State var offset: CGFloat = UIScreen.main.bounds.width // старт справа
    
    let height = UIScreen.main.bounds.height * 0.5
    let width = UIScreen.main.bounds.width
    let duration: Double = 0.5
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Button {
                    if !showView {
                        // appearance from the right
                        showView = true
                        withAnimation(.easeInOut(duration: duration)) {
                            offset = 0
                        }
                    } else {
                        // disappearance to the left
                        withAnimation(.easeInOut(duration: duration)) {
                            offset = -width
                        }
                        // reset position back to the right after disappearing
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                            showView = false
                            offset = width
                        }
                    }
                } label: {
                    Text("ANIMATE SHEET")
                        .foregroundStyle(Color.mycolor.myPurple)
                        .font(.headline)
                        .padding()
                        .background(.ultraThinMaterial, in: .capsule)
                }
                Spacer()
            }
            
            if showView {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.mycolor.myPurple.opacity(0.1))
                    .frame(height: height)
                    .offset(x: offset)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}


