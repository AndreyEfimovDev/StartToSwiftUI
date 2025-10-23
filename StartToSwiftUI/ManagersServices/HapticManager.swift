//
//  HapticManager.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 12.09.2025.
//

import SwiftUI


class HapticManager {
    
    static let shared = HapticManager()

    private var notificationGenerator: UINotificationFeedbackGenerator?
    private var impactGenerators: [UIImpactFeedbackGenerator.FeedbackStyle: UIImpactFeedbackGenerator] = [:]
    
    private init() {
        // Initialise the generators in advance
        prepareGenerators()
    }
    
    private func prepareGenerators() {
        
        notificationGenerator = UINotificationFeedbackGenerator()
        notificationGenerator?.prepare()
        
        let styles: [UIImpactFeedbackGenerator.FeedbackStyle] = [.light, .medium, .heavy, .rigid, .soft]
        for style in styles {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            impactGenerators[style] = generator
        }
    }
    
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        DispatchQueue.main.async {
            self.notificationGenerator?.notificationOccurred(type)
            // Preparing the generator for next use
            self.notificationGenerator?.prepare()
        }
    }
    
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        DispatchQueue.main.async {
            // Use a pre-prepared generator for this style.
            if let generator = self.impactGenerators[style] {
                generator.impactOccurred()
                // Re-preparing the generator for next use
                generator.prepare()
            } else {
                // Fallback: create a new generator if the style has not been prepared
                let generator = UIImpactFeedbackGenerator(style: style)
                generator.prepare()
                generator.impactOccurred()
            }
        }
    }
}


struct HapticManagerView: View {
    
    var body: some View {
        VStack(spacing: 20) {
            
            Button("success") { HapticManager.shared.notification(type: .success) }
            Button("warning") { HapticManager.shared.notification(type: .warning) }
            Button("error") { HapticManager.shared.notification(type: .error) }
            Divider()
            Button("soft") { HapticManager.shared.impact(style: .soft) }
            Button("light") { HapticManager.shared.impact(style: .light) }
            Button("medium") { HapticManager.shared.impact(style: .medium) }
            Button("rigid") { HapticManager.shared.impact(style: .rigid) }
            Button("heavy") { HapticManager.shared.impact(style: .heavy) }
        }
    }
}

#Preview {
    HapticManagerView()
}
