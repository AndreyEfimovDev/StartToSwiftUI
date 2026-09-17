//
//  DatabaseErrorView.swift
//  StartToSwiftUI
//

import SwiftUI

/// Показывается вместо `StartView`, если `ModelContainer` не удалось создать
/// в `StartToSwiftUIApp.init()` — раньше в этом случае был `fatalError`.
struct DatabaseErrorView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.red)
            Text("Failed to start the app")
                .font(.title2)
                .bold()
            Text("Could not load local storage. Please try restarting the app.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)
        }
    }
}

#Preview {
    DatabaseErrorView()
}
