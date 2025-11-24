//
//  ThankfullnessView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 18.11.2025.
//

import SwiftUI

struct ThankfullnessView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            Text("""
            Nick Sarno with his project Swiftfull Thinking
            Alean Sean
            """)
 
            .multilineTextAlignment(.leading)
            .textFormater()
            .padding()
        }
        .navigationTitle("Thankfullness")
        .navigationBarBackButtonHidden(true)
//        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                CircleStrokeButtonView(iconName: "chevron.left", isShownCircle: false) {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ThankfullnessView()
    }
}
