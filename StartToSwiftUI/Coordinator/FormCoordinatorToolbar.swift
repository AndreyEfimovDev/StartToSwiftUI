//
//  BaseNavigationView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 23.12.2025.
//

import SwiftUI

struct FormCoordinatorToolbar<Content: View>: View {
    
    @EnvironmentObject private var coordinator: AppCoordinator

    let title: String
    let showHomeButton: Bool
    let content: Content    
    
    init(title: String, showHomeButton: Bool = false, @ViewBuilder content: () -> Content) {
        self.title = title
        self.showHomeButton = showHomeButton
        self.content = content()
    }
    
    var body: some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButtonView() {
                        coordinator.popModal()
                    }
                }
                
                if showHomeButton {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            coordinator.closeModal()
                        } label: {
                            Image(systemName: "house")
                                .foregroundStyle(Color.mycolor.myAccent)
                        }
                    }
                }
            }
    }
}
