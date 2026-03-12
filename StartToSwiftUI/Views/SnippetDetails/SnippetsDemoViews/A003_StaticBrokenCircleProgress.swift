//
//  A003_StaticBrokenCircleProgress.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 10.03.2026.
//

import SwiftUI

struct A003_StaticBrokenCircleProgress: View {
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
    A003_StaticBrokenCircleProgress()
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
