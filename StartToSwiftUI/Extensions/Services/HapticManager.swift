//
//  HapticManager.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 12.09.2025.
//

import SwiftUI


class HapticService {
    
    static let shared = HapticService()

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
            
            Button("success") { HapticService.shared.notification(type: .success) }
            Button("warning") { HapticService.shared.notification(type: .warning) }
            Button("error") { HapticService.shared.notification(type: .error) }
            Divider()
            Button("soft") { HapticService.shared.impact(style: .soft) }
            Button("light") { HapticService.shared.impact(style: .light) }
            Button("medium") { HapticService.shared.impact(style: .medium) }
            Button("rigid") { HapticService.shared.impact(style: .rigid) }
            Button("heavy") { HapticService.shared.impact(style: .heavy) }
        }
    }
}

#Preview {
    HapticManagerView()
}
