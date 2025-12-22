//
//  BrokenCircleProgressView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 20.12.2025.
//

import SwiftUI

struct BrokenCircleProgressView: View {
    @State private var rotationAngle: Double = 0
    @State private var isAnimating = false
    
    let strokeWidth: CGFloat = 12
    let circleSize: CGFloat = 200
    let gapAngle: Double = 30 // Угол разрыва в градусах
    let starPoints: Int = 5
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Прогрессивный индикатор")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .padding(.top, 40)
            
            ZStack {
                // Фоновый круг
                Circle()
                    .stroke(
                        Color.white.opacity(0.2),
                        style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                    )
                    .frame(width: circleSize, height: circleSize)
                
                // Вращающийся разорванный круг
                Circle()
                    .trim(from: 0, to: 1 - (gapAngle / 360))
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                Color.blue,
                                Color.purple,
                                Color.cyan,
                                Color.blue
                            ]),
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        ),
                        style: StrokeStyle(
                            lineWidth: strokeWidth,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .frame(width: circleSize, height: circleSize)
                    .rotationEffect(.degrees(rotationAngle))
                    .shadow(color: .blue.opacity(0.5), radius: 10, x: 0, y: 0)
                    .onAppear {
                        withAnimation(
                            Animation.linear(duration: 2)
                                .repeatForever(autoreverses: false)
                        ) {
                            rotationAngle = 360
                        }
                    }
                
                // Звезда в центре
                StarShape(points: starPoints, innerRadius: 0.4)
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [Color.yellow, Color.orange]),
                            center: .center,
                            startRadius: 1,
                            endRadius: circleSize * 0.1
                        )
                    )
                    .frame(width: circleSize * 0.3, height: circleSize * 0.3)
                    .shadow(color: .yellow, radius: 10, x: 0, y: 0)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .onAppear {
                        withAnimation(
                            Animation.linear(duration: 4)
                                .repeatForever(autoreverses: false)
                        ) {
                            isAnimating = true
                        }
                    }
            }
            .padding()
            
            // Информационная панель
            VStack(spacing: 15) {
                HStack(spacing: 20) {
                    InfoItem(title: "Скорость", value: "2 сек/об")
                    InfoItem(title: "Разрыв", value: "30°")
                }
                
                HStack(spacing: 20) {
                    InfoItem(title: "Звезда", value: "\(starPoints) лучей")
                    InfoItem(title: "Статус", value: "Активен")
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal, 30)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.1, green: 0.2, blue: 0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .ignoresSafeArea()
    }
}
#Preview {
    BrokenCircleProgressView()
}


// Предварительный просмотр
struct ContentView: View {
    var body: some View {
        BrokenCircleProgressViewWithControls()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// Кастомная форма звезды
struct StarShape: Shape {
    let points: Int
    let innerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * self.innerRadius
        
        let angleIncrement = .pi / CGFloat(points)
        
        for i in 0..<(points * 2) {
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let angle = angleIncrement * CGFloat(i)
            
            let point = CGPoint(
                x: center.x + radius * cos(angle - .pi / 2),
                y: center.y + radius * sin(angle - .pi / 2)
            )
            
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        path.closeSubpath()
        return path
    }
}

// Компонент для отображения информации
struct InfoItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .frame(width: 100)
    }
}

// Модифицированная версия с настройками
struct BrokenCircleProgressViewWithControls: View {
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
