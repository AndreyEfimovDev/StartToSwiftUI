//
//  LaunchView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 27.10.2025.
// #2A5FB4 #3765AF

import SwiftUI
import Combine

struct LaunchView: View {
    
    // MARK: - Dependencies
    private let hapticManager = HapticManager.shared
    
    // MARK: - Constants
    let completion: () -> ()
    
    // MARK: - States
    @State private var cancellable: AnyCancellable?
    @State private var showLoadingProgress: Bool = false
    @State private var counter: Int = 0
    @State private var loadingString: [String] = "........... loading ...........".map { String($0) }
    
    // MARK: BODY
    var body: some View {
        ZStack {
            Color.launch.background
                .ignoresSafeArea()
            
            Image("A_1024x1024_PhosphateInline_tr_text")
                .resizable()
                .font(.headline)
                .fontWeight(.heavy)
                .frame(width: 200, height: 200)
            
            if showLoadingProgress {
                HStack(spacing: 0) {
                    ForEach(loadingString.indices, id: \.self) { index in
                        Text(loadingString[index])
                            .offset(y: counter == index ? -11 : 0)
                    }
                }
                .font(.subheadline)
                .transition(.scale.animation(.easeIn))
                .offset(y: 135)
            }
        }
        .foregroundColor(Color.launch.accent)
        .onAppear {
            showLoadingProgress = true
            cancellable = Timer
                .publish(every: 0.1, on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    withAnimation {
                        if counter == loadingString.count - 1 {
                            cancellable?.cancel()  // ← cancel timer before completion()
                            cancellable = nil
                            completion()
                        } else {
                            counter += 1
                        }
                    }
                }
        }
        .onDisappear {
            cancellable?.cancel()  // ← cancel timer for su
            cancellable = nil
            hapticManager.impact(style: .light)
        }
    }
}

#Preview {
    LaunchView() {
    }
}
