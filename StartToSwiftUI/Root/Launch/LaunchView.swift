//
//  LaunchView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 27.10.2025.
//

import SwiftUI

struct LaunchView: View {
    
    let action: () -> ()
    
    @State private var showLoadingText: Bool = false
    @State private var counter: Int = 0
    @State private var loops: Int = 0
    @State private var loadingText: [String] = "............. loading .............".map { String($0) }
    
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.launch.background
                .ignoresSafeArea()
            
            Image("StartToSwiftUI_icon_any_1024blue")
                .resizable()
                .font(.headline)
                .fontWeight(.heavy)
                .frame(width: 200, height: 200)

            ZStack {
                if showLoadingText {
                    HStack(spacing: 0) {
                        ForEach(loadingText.indices, id: \.self) { index in
                            Text(loadingText[index])
                                .offset(y: counter == index ? -11 : 0)
                        }
                    }
                    .font(.subheadline)
                    .transition(AnyTransition.scale.animation(.easeIn))
                }
            }
            .offset(y: 108)
        }
        .foregroundColor(Color.launch.accent)
        .onAppear {
            showLoadingText.toggle()
        }
        .onReceive(timer, perform: { _ in
            withAnimation(.spring()) {
                
                let lastIndex = loadingText.count - 1
                if counter == lastIndex {
                    counter = 0
                    loops += 1
                    if loops >= 1 {
                        action()
                    }
                } else {
                    counter += 1
                }
            }
        })
    }
}

#Preview {
    LaunchView() {}
}
