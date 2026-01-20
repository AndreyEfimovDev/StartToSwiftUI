//
//  ModalNavigationContainerWrapper.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 29.12.2025.
//

import SwiftUI

// MARK: - Обертка для ModalNavigationContainer
struct ModalNavigationContainerWrapper: View {
    let initialRoute: AppRoute
    @EnvironmentObject private var coordinator: AppCoordinator
    
    var body: some View {
        ModalNavigationContainer(initialRoute: initialRoute)
            .environmentObject(coordinator)
            .onAppear {
                // Reset the stack if not empty
                if !coordinator.modalPath.isEmpty && coordinator.modalPath.count == 1 {
                    // Leave it as is
                } else {
                    coordinator.modalPath = NavigationPath()
                }
            }
    }
}
