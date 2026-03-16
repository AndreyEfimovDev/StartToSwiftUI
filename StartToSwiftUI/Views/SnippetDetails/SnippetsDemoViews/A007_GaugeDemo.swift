//
//  A007_GaugeDemo.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 16.03.2026.
//

import SwiftUI

struct A007_GaugeDemo: View {
    
    private let minValue: Double = 50
    private let maxValue: Double = 170
    @State private var current: Double = 67
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                
                gaugeSection("Linear Capacity") {
                    Gauge(value: current, in: minValue...maxValue) {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                    } currentValueLabel: {
                        Text("\(Int(current))")
                            .foregroundStyle(.green)
                    } minimumValueLabel: {
                        Text("\(Int(minValue))")
                            .foregroundStyle(.green)
                    } maximumValueLabel: {
                        Text("\(Int(maxValue))")
                            .foregroundStyle(.red)
                    }
                    .gaugeStyle(.linearCapacity)
                }
                
                Divider()
                
                gaugeSection("Accessory Circular") {
                    Gauge(value: current, in: minValue...maxValue) {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                    } currentValueLabel: {
                        Text("\(Int(current))")
                            .foregroundStyle(.green)
                    } minimumValueLabel: {
                        Text("\(Int(minValue))")
                            .foregroundStyle(.green)
                    } maximumValueLabel: {
                        Text("\(Int(maxValue))")
                            .foregroundStyle(.red)
                    }
                    .gaugeStyle(.accessoryCircular)
                }
                
                Divider()
                
                gaugeSection("Accessory Linear") {
                    Gauge(value: current, in: minValue...maxValue) {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                    } currentValueLabel: {
                        Text("\(Int(current))")
                            .foregroundStyle(.green)
                    } minimumValueLabel: {
                        Text("\(Int(minValue))")
                            .foregroundStyle(.green)
                    } maximumValueLabel: {
                        Text("\(Int(maxValue))")
                            .foregroundStyle(.red)
                    }
                    .gaugeStyle(.accessoryLinear)
                }
                
                Divider()
                
                gaugeSection("Accessory Circular Capacity") {
                    Gauge(value: current, in: minValue...maxValue) {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                    } currentValueLabel: {
                        Text("\(Int(current))")
                            .foregroundStyle(.green)
                    } minimumValueLabel: {
                        Text("\(Int(minValue))")
                            .foregroundStyle(.green)
                    } maximumValueLabel: {
                        Text("\(Int(maxValue))")
                            .foregroundStyle(.red)
                    }
                    .gaugeStyle(.accessoryCircularCapacity)
                }
                
                Divider()
                
                gaugeSection("Accessory Linear Capacity") {
                    Gauge(value: current, in: minValue...maxValue) {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                    } currentValueLabel: {
                        Text("\(Int(current))")
                            .foregroundStyle(.green)
                    } minimumValueLabel: {
                        Text("\(Int(minValue))")
                            .foregroundStyle(.green)
                    } maximumValueLabel: {
                        Text("\(Int(maxValue))")
                            .foregroundStyle(.red)
                    }
                    .gaugeStyle(.accessoryLinearCapacity)
                }
                
                Divider()
                
                // Slider to control current value
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current: \(Int(current))")
                        .font(.subheadline)
                        .foregroundStyle(Color.mycolor.myAccent)
                    Slider(value: $current, in: minValue...maxValue)
                        .tint(Color.mycolor.myBlue)
                }
            }
            .padding()
        }
        .tint(Color.mycolor.myBlue)
    }
    
    // MARK: - Helper
    
    @ViewBuilder
    private func gaugeSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            content()
        }
    }
}

#Preview {
    A007_GaugeDemo()
}
