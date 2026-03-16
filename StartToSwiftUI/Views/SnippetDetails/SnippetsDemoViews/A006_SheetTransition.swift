//
//  Transition.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 15.03.2026.
//

import SwiftUI

import SwiftUI

struct SheetTransitionDemo: View {
        
    var body: some View {
        TabView {
            Tab("", systemImage: "1.circle") {
                SheetBottomTransition()
            }

            Tab("", systemImage: "2.circle") {
                SheetBottomRightTransition()
            }
            Tab("", systemImage: "3.circle") {
                SheetSliderTransition()
            }
        }
    }
}

struct TransitionBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        SheetTransitionDemo()
    }
}

struct SheetBottomRightTransition: View {
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
                        // появление снизу
                        showView = true
                        withAnimation(.easeInOut(duration: duration)) {
                            offset = .zero
                        }
                    } else {
                        // исчезновение вправо
                        withAnimation(.easeInOut(duration: duration)) {
                            offset = CGSize(width: width, height: 0)
                        }
                        // сброс позиции обратно вниз после исчезновения
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                            showView = false
                            offset = CGSize(width: 0, height: height)
                        }
                    }
                } label: {
                    Text("ANIMATE SHEET")
                        .font(.headline)
                        .padding()
                }
                Spacer()
            }
            
            if showView {
                UnevenRoundedRectangle(cornerRadii: .init(
                    topLeading: 30,
                    topTrailing: 30
                ))
                .frame(height: height)
                .offset(offset)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }

}

struct SheetSliderTransition: View {
    @State var showView: Bool = false
    
    let height = UIScreen.main.bounds.height * 0.5
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            VStack {
                Button {
                    showView.toggle()
                } label: {
                    Text("ANIMATE SHEET")
                        .font(.headline)
                        .padding()
                }
                Spacer()
            }
            
            RoundedRectangle(cornerRadius: 30)
                .frame(height: height)
                .offset(x: showView ? 0 : UIScreen.main.bounds.width) // справа налево
                .animation(.easeInOut(duration: 0.5), value: showView)
            
            
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct SheetBottomTransition: View {
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
                        .padding()
                }
                Spacer()
            }
            
            RoundedRectangle(cornerRadius: 30)
                .frame(height: height)
                .offset(y: showView ? 0 : height)
                .animation(.easeInOut(duration: 0.5), value: showView)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}
