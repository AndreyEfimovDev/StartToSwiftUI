//
//  A004_StaticBrokenCircleProgress.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 10.03.2026.
//

import SwiftUI

struct A004_StaticBrokenCircleProgressWithControls: View {
    @State private var rotationSpeed: Double = 2.0
    @State private var gapSize: Double = 30.0
    @State private var starPoints: Int = 5
    @State private var showControls = false
    
    var body: some View {
        ZStack {
            // Основной вид
            BrokenCircleProgressViewCustom(
                rotationSpeed: rotationSpeed,
                gapAngle: gapSize,
                starPoints: starPoints
            )
            
            // Кнопка управления
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring()) {
                            showControls.toggle()
                        }
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                            )
                            .shadow(radius: 5)
                    }
                    .padding()
                }
                Spacer()
            }
            
            // Панель управления
            if showControls {
                ControlsPanel(
                    rotationSpeed: $rotationSpeed,
                    gapSize: $gapSize,
                    starPoints: $starPoints,
                    showControls: $showControls
                )
            }
        }
    }
}

// Кастомная версия с параметрами
struct BrokenCircleProgressViewCustom: View {
    @State private var rotationAngle: Double = 0
    @State private var starRotation: Double = 0
    
    let rotationSpeed: Double
    let gapAngle: Double
    let starPoints: Int
    let circleSize: CGFloat = 200
    
    var body: some View {
        ZStack {
            // Вращающийся разорванный круг
            Circle()
                .trim(from: 0, to: 1 - (gapAngle / 360))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            .blue,
                            .purple,
                            .cyan,
                            .blue
                        ]),
                        center: .center
                    ),
                    style: StrokeStyle(
                        lineWidth: 12,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .frame(width: circleSize, height: circleSize)
                .rotationEffect(.degrees(rotationAngle))
                .onAppear {
                    withAnimation(
                        Animation.linear(duration: rotationSpeed)
                            .repeatForever(autoreverses: false)
                    ) {
                        rotationAngle = 360
                    }
                }
                .onChange(of: rotationSpeed) { _, _ in
                    withAnimation(
                        Animation.linear(duration: rotationSpeed)
                            .repeatForever(autoreverses: false)
                    ) {
                        rotationAngle = 360
                    }
                }
            
            // Вращающаяся звезда
            StarShape(points: starPoints, innerRadius: 0.4)
                .fill(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: circleSize * 0.3, height: circleSize * 0.3)
                .rotationEffect(.degrees(starRotation))
                .onAppear {
                    withAnimation(
                        Animation.linear(duration: rotationSpeed * 2)
                            .repeatForever(autoreverses: false)
                    ) {
                        starRotation = 360
                    }
                }
                .onChange(of: rotationSpeed) { _, _ in
                    withAnimation(
                        Animation.linear(duration: rotationSpeed * 2)
                            .repeatForever(autoreverses: false)
                    ) {
                        starRotation = 360
                    }
                }
        }
    }
}

// Панель управления
struct ControlsPanel: View {
    @Binding var rotationSpeed: Double
    @Binding var gapSize: Double
    @Binding var starPoints: Int
    @Binding var showControls: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 20) {
                Text("Настройки")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.accentColor)
                
                VStack(alignment: .leading, spacing: 15) {
                    SliderControl(
                        title: "Скорость вращения",
                        value: $rotationSpeed,
                        range: 0.5...5.0,
                        format: "%.1f сек"
                    )
                    
                    SliderControl(
                        title: "Размер разрыва",
                        value: $gapSize,
                        range: 10...120,
                        format: "%.0f°"
                    )
                    
                    StepperControl(
                        title: "Лучей звезды",
                        value: $starPoints,
                        range: 3...10
                    )
                }
                
                Button("Готово") {
                    withAnimation(.spring()) {
                        showControls = false
                    }
                }
                .font(.headline)
                .foregroundColor(.accentColor)
                .padding(.horizontal, 30)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color.blue)
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.3), radius: 20)
            )
            .padding()
        }
        .transition(.move(edge: .bottom))
    }
}

// Компонент слайдера
struct SliderControl: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let format: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.accentColor)
                
                Spacer()
                
                Text(String(format: format, value))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.accentColor.opacity(0.8))
            }
            
            Slider(value: $value, in: range)
                .accentColor(.blue)
        }
    }
}

// Компонент степпера
struct StepperControl: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.accentColor)
            
            Spacer()
            
            HStack(spacing: 15) {
                Button(action: {
                    if value > range.lowerBound {
                        value -= 1
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.blue)
                }
                .disabled(value <= range.lowerBound)
                
                Text("\(value)")
                    .font(.headline)
                    .frame(width: 30)
                    .foregroundColor(.accentColor)
                
                Button(action: {
                    if value < range.upperBound {
                        value += 1
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
                .disabled(value >= range.upperBound)
            }
        }
    }
}

#Preview {
    A004_StaticBrokenCircleProgressWithControls()
}
