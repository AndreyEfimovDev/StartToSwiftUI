//
//  LaunchView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 27.10.2025.
// #2A5FB4 #3765AF

import SwiftUI

struct LaunchView: View {
    
    let completion: () -> ()
    
    @State private var showLoadingProgress: Bool = false
    @State private var counter: Int = 0
    @State private var loadingString: [String] = "................ loading ................".map { String($0) }
    
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.launch.background
                .ignoresSafeArea()
            
            Image("A_1024x1024_PhosphateInline_tr_text")
                .resizable()
                .font(.headline)
                .fontWeight(.heavy)
                .frame(width: 200, height: 200)
                .offset(y: 8)

            ZStack {
                if showLoadingProgress {
                    HStack(spacing: 0) {
                        ForEach(loadingString.indices, id: \.self) { index in
                            Text(loadingString[index])
                                .offset(y: counter == index ? -11 : 0)
                        } 
                    }
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .transition(AnyTransition.scale.animation(.easeIn))
                }
            }
            .offset(y: 135)
        }
        .foregroundColor(Color.launch.accent)
        .onAppear {
            showLoadingProgress.toggle()
        }
        .onReceive(timer) { _ in
            withAnimation() {
                let lastIndex = loadingString.count - 1
                if counter == lastIndex {
                        completion()
                } else {
                    counter += 1
                }
            }
        }
    }
}

#Preview {
    LaunchView() {}
}
