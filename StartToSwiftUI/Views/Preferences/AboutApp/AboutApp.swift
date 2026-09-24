//
//  AboutApp.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 05.11.2025.
//

import SwiftUI

struct AboutApp: View {
    
    // MARK: - Dependencies
    @EnvironmentObject private var coordinator: AppCoordinator
    @Environment(\.appStoreService) private var appStoreService
    
    // MARK: - States
    @State private var buttonTitleAppUpdate = "Check for App update"
    /// Идёт проверка версии в App Store — триггер `.task(id:)` и блокировка
    /// кнопки от двойного тапа.
    @State private var isCheckingAppUpdate = false
    
    // MARK: - Constants
    private let iconWidth: CGFloat = 18
    
    // MARK: - Body
    var body: some View {
        FormCoordinatorToolbar(
            title: "About App",
            showHomeButton: true
        ) {
            Form {
                appInfoSection
                navigationSection
            }
            .scrollContentBackground(.hidden)
            .listSectionSpacing(8)
        }
        .foregroundStyle(Color.mycolor.myAccent)
        .background(.thickMaterial)
    }
    
    // MARK: - Sections
    
    private var appInfoSection: some View {
        Section {
            HStack(spacing: 0) {
                appIcon
                appDetails
            }
        }
        .listRowBackground(Color.clear)
        .frame(maxWidth: .infinity)
    }
    
    private var navigationSection: some View {
        Section {
            Button("Welcome") {
                coordinator.pushModal(.welcome)
            }
            .customListRowStyle(iconName: "suit.heart", iconWidth: iconWidth)
            
            Button("Introduction") {
                coordinator.pushModal(.introduction)
            }
            .customListRowStyle(iconName: "textformat.size.larger", iconWidth: iconWidth)
            
            Button("Functionality") {
                coordinator.pushModal(.functionality)
            }
            .customListRowStyle(iconName: "f.cursive", iconWidth: iconWidth)

            // Link to the app's page in the App Store
            Button(isCheckingAppUpdate ? "Checking…" : buttonTitleAppUpdate) {
                isCheckingAppUpdate = true
            }
            .disabled(isCheckingAppUpdate)
            .customListRowStyle(iconName: "gear.badge", iconWidth: iconWidth)
            // Проверка привязана к жизни экрана: ушли раньше, чем пришёл
            // ответ (запрос может идти до таймаута) — задача отменяется, и
            // App Store не открывается сам собой на другом экране.
            .task(id: isCheckingAppUpdate) {
                guard isCheckingAppUpdate else { return }
                let hasUpdate = await appStoreService.isUpdateAvailable()
                guard !Task.isCancelled else { return }

                switch hasUpdate {
                case true?:
                    if let url = URL(string: Constants.appStoreURL) {
                        await UIApplication.shared.open(url)
                    }
                case false?:
                    buttonTitleAppUpdate = "The App is up to date"
                case nil:
                    buttonTitleAppUpdate = "Could not check for update"
                }
                isCheckingAppUpdate = false
            }
            
            Button("What's New") {
                coordinator.pushModal(.whatIsNew)
            }
            .customListRowStyle(iconName: "newspaper", iconWidth: iconWidth)
        }
    }
    
    // MARK: - Subviews
    
    private var appIcon: some View {
        Image("AppIcon_blue_3477F5")
            .resizable()
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .padding()
    }
    
    private var appDetails: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("StartToSwiftUI")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("SwiftUI Study")
                .font(.body)
            
            Group {
                Text("Version \(Bundle.main.versionBuild)")
                
                HStack(spacing: 3) {
                    Text("Support:")
                    Image(systemName: "iphone")
                    Image(systemName: "ipad")
                    Text("iOS: \(Bundle.main.minimumiOSVersion)+")
                }
            }
            .font(.caption2)
        }
    }
}


#Preview {
    NavigationStack{
        AboutApp()
            .environmentObject(AppCoordinator())
    }
}
