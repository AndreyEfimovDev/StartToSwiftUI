//
//  ModalNavigationContainerWrapper.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 29.12.2025.
//

import SwiftUI

// MARK: - Wrapper for ModalNavigationContainer

struct ModalNavigationContainerWrapper: View {
    let initialRoute: AppRoute
    @EnvironmentObject private var coordinator: AppCoordinator
    
    var body: some View {
        // Стек модалки здесь не сбрасывается: это уже делает coordinator.push()
        // перед показом модалки.
        ModalNavigationContainer(initialRoute: initialRoute)
            .environmentObject(coordinator)
    }
}
