//
//  SupportDeveloperView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.09.2026.
//

import SwiftUI

struct SupportDeveloperView: View {

    // MARK: - Dependencies
    @Environment(\.remoteConfigService) private var remoteConfigService

    // MARK: - Constants
    private let iconWidth: CGFloat = 18

    // MARK: - States
    // Стартуем с пустого списка: в момент инициализации @State окружение
    // ещё не резолвлено, и прочитать инжектированный remoteConfigService
    // нельзя. Реальные значения подставляются в .task.
    @State private var options: [SupportOption] = []

    // MARK: - Body
    var body: some View {
        FormCoordinatorToolbar(
            title: "Support the Developer",
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
        .task {
            // Сначала — без сети: Firebase отдаёт значения, активированные
            // в прошлый раз (кэш на диске), либо локальный fallback. Без этого
            // шага оффлайн экран был бы пустым до таймаута fetch (~60 с).
            options = SupportOption.all(remoteConfig: remoteConfigService)
            // Затем перечитываем, только если с сервера пришли свежие данные:
            // при троттлинге (повторный заход в течение часа) или ошибке сети
            // активный конфиг не менялся, и повторная сборка была бы лишней.
            if await remoteConfigService.activate() {
                options = SupportOption.all(remoteConfig: remoteConfigService)
            }
        }
    }

    // MARK: - Sections

    private var introSection: some View {
        Section {
            Text("StartToSwiftUI is free and always will be. If it's helped you, you're welcome to support my work — completely optional, nothing extra unlocked in return.")
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
            Text("Opens in Safari and is handled by the selected service outside of the app.")
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
