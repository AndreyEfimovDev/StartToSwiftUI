//
//  SupportDeveloperView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.09.2026.
//

import SwiftUI

struct SupportDeveloperView: View {

    // MARK: - Constants
    private let iconWidth: CGFloat = 18
    private let options = SupportOption.all

    // MARK: - Body
    var body: some View {
        FormCoordinatorToolbar(
            title: "Buy Me a Coffee",
            showHomeButton: true
        ) {
            Form {
                introSection
                optionsSection
            }
            .scrollContentBackground(.hidden)
            .listSectionSpacing(8)
        }
        .foregroundStyle(Color.mycolor.myAccent)
        .background(.thickMaterial)
    }

    // MARK: - Sections

    private var introSection: some View {
        Section {
            Text("StartToSwiftUI is free and always will be. If it's helped you, you're welcome to buy me a coffee — completely optional, nothing extra unlocked in return.")
                .font(.subheadline)
        }
        .listRowBackground(Color.clear)
    }

    private var optionsSection: some View {
        Section {
            ForEach(options) { option in
                Button {
                    open(option)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(option.title)
                            Text(option.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "arrow.up.forward")
                            .foregroundStyle(.secondary)
                    }
                }
                .customListRowStyle(iconName: option.icon, iconWidth: iconWidth)
            }
        } footer: {
            Text("Opens in Safari — payment is handled by the selected service, not inside the app.")
        }
    }

    // MARK: - Actions

    // Открываем во внешнем Safari, а не во встроенном WebView — платёж
    // полностью уходит из UI приложения (см. обсуждение фичи).
    private func open(_ option: SupportOption) {
        guard let url = URL(string: option.urlString) else { return }
        UIApplication.shared.open(url)
    }
}

#Preview {
    NavigationStack {
        SupportDeveloperView()
            .environmentObject(AppCoordinator())
    }
}
