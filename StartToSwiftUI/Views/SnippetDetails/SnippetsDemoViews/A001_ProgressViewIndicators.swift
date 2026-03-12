//
//  A001_ProgressViewIndicators.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.03.2026.
//

import SwiftUI

struct A001_ProgressViewIndicators: View {
    
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 30) {
            A001_Wave()
            A001_PulsingCircle()
            A001_JumpingDots()
            A001_JumpingLetters()
            A001_RotatingRingWithTrace()
        }
    }
}

struct A001_Wave: View {
    
    @State private var scales: [CGFloat] = [0.5, 0.5, 0.5, 0.5, 0.5]
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<5, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.mycolor.myBlue)
                    .frame(width: 3, height: 12 * scales[index])
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.1), value: scales[index])
            }
        }
        .onAppear {
            for i in 0..<scales.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                    scales[i] = 1.0
                }
            }
        }
    }
}

struct A001_PulsingCircle: View {
    @State private var scale: CGFloat = 0.5
    
    var body: some View {
        Circle()
            .fill(Color.mycolor.myBlue)
            .frame(width: 16, height: 16)
            .scaleEffect(scale)
            .opacity((1.4 - min(scale, 1)))
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    scale = 1.5
                }
            }
    }
}

struct A001_JumpingDots: View {
    @State private var scale: [Bool] = [false, false, false]
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.mycolor.myBlue)
                    .frame(width: 6, height: 6)
                    .scaleEffect(scale[index] ? 1.0 : 0.5)
            }
        }
        .frame(width: 8, height: 8)
        .onAppear { startDotAnimation() }
    }
    
    private func startDotAnimation() {
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    scale[i] = true
                }
            }
        }
    }
}

import Combine

struct A001_JumpingLetters: View {
    
    @State private var counter: Int = 0
    @State private var cancellable: AnyCancellable?

    private let loadingString: [String] = "........... loading ...........".map { String($0) }
    
    // MARK: BODY
    var body: some View {
        ZStack {
                HStack(spacing: 0) {
                    ForEach(loadingString.indices, id: \.self) { index in
                        Text(loadingString[index])
                            .offset(y: counter == index ? -11 : 0)
                    }
                }
                .font(.subheadline)
        }
        .foregroundColor(Color.mycolor.myBlue)
        .onAppear {
            cancellable = Timer
                .publish(every: 0.1, on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    withAnimation {
                        counter = (counter + 1) % loadingString.count
                    }
                }
        }
        .onDisappear {
            cancellable?.cancel()
            cancellable = nil
        }
    }
}

struct A001_RotatingRingWithTrace: View {
    @State private var isRotating = false
    
    var body: some View {
        Circle()
            .trim(from: 0.0, to: 0.7)
            .stroke(
                AngularGradient(
                    stops: [
                        .init(color: .clear, location: 0.0),  // tail
                        .init(color: Color.mycolor.myBlue.opacity(0.3), location: 0.3),  // trace
                        .init(color: Color.mycolor.myBlue, location: 0.7),  // head
                        .init(color: .clear, location: 1.0),  // remove a dot
                    ],
                    center: .center,
                    startAngle: .degrees(0),
                    endAngle: .degrees(360)
                ),
                style: StrokeStyle(lineWidth: 3, lineCap: .round)
            )

            .frame(width: 20, height: 20)
            .rotationEffect(Angle(degrees: isRotating ? 360 : 0))
            .animation(
                .linear(duration: 1.0)
                .repeatForever(autoreverses: false),
                value: isRotating
            )
            .onAppear { isRotating = true }
    }
}

#Preview {
    NavigationStack {
        A001_ProgressViewIndicators()
    }
}
