//
//  LineMarkLegendView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 13.01.2026.
//

import SwiftUI

struct LineMarkLegendView: View {
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Dynamics by month")
                .font(.caption2)
                .bold()
                .padding(4)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.mycolor.mySecondary.opacity(0.5), lineWidth: 1)
                )


            HStack(spacing: 20) {
                ForEach([StudyProgress.started, StudyProgress.studied, StudyProgress.practiced], id: \.self) { type in
                    
                    let UIDeviceLayout: AnyLayout = UIDevice.isiPad ? AnyLayout(VStackLayout(spacing: 6)) : AnyLayout(HStackLayout(spacing: 6))
                    
                    UIDeviceLayout {
                        HStack(spacing: 6) {
                            // Line as in the graph
                            Rectangle()
                                .fill(type.color)
                                .frame(width: 20, height: 2)
                            
                            // Symbol depending on type
                            Group {
                                switch type {
                                case .started:
                                    Circle()
                                        .fill(type.color)
                                        .frame(width: 8, height: 8)
                                case .studied:
                                    Rectangle()
                                        .fill(type.color)
                                        .frame(width: 8, height: 8)
                                case .practiced:
                                    Triangle()
                                        .fill(type.color)
                                        .frame(width: 9, height: 9)
                                default:
                                    Circle()
                                        .fill(type.color)
                                        .frame(width: 6, height: 6)
                                }
                            }
                        }
                        
                        Text(type.displayName)
                            .font(.caption2)
                    }
                }
            }
        }
        
        .foregroundStyle(Color.mycolor.myAccent)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 8)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}


#Preview {
    LineMarkLegendView()
}
