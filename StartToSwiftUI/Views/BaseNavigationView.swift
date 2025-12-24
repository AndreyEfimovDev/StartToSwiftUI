//
//  BaseNavigationView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 23.12.2025.
//

import SwiftUI

import SwiftUI

struct BaseNavigationView<Content: View>: View {
    let title: String
    let content: Content
    let showHomeButton: Bool
    
    @EnvironmentObject private var coordinator: NavigationCoordinator
    
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
                        coordinator.pop()
                    }
                }
                
                if showHomeButton {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            coordinator.popToRoot()
                        }) {
                            Image(systemName: "house.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
    }
}

//struct StudyProgressView: View {
//    var body: some View {
//        BaseNavigationView(title: "Study Progress", showHomeButton: true) {
//            // ... ваш контент ...
//        }
//    }
//}
//
//#Preview {
//    BaseNavigationView()
//}
