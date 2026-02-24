//
//  FBPerformanceManager.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.02.2026.
//

import SwiftUI
import FirebasePerformance

final class FBPerformanceManager {
    
    static let shared = FBPerformanceManager()
    private init() { }
    
    private var traces: [String:Trace] = [:]
    
    func startTrace(name: String) {
        let trace = Performance.startTrace(name: name)
        traces[name] = trace
    }
    
    func setValue(name: String, value: String, forAttribute: String) {
        guard let trace = traces[name] else { return }
        trace.setValue(value, forAttribute: forAttribute)
    }
    
    func stopTrace(name: String) {
        guard let trace = traces[name] else { return }
        trace.stop()
        traces.removeValue(forKey: name)
    }
}

