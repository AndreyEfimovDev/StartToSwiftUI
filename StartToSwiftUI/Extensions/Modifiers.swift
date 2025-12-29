//
//  Modifiers.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 19.09.2025.
//

import SwiftUI

// MARK: Custom One/Two Taps for RoawPost in HomeView

struct TapAndDoubleTapModifier: ViewModifier {
    let singleTap: () -> Void
    let doubleTap: () -> Void
    
    @State private var tapCount = 0
    
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                tapCount += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                    if tapCount == 1 {
                        singleTap()
                    } else if tapCount == 2 {
                        doubleTap()
                    }
                    tapCount = 0
                }
            }
    }
}

// MARK: Adaptaion StudyProgressView for iPad

struct AdaptiveTabViewStyle: ViewModifier {
    func body(content: Content) -> some View {
        if UIDevice.isiPad {
            // for iPad
            content
                .tabViewStyle(.page(indexDisplayMode: .never))
                .disabled(true)
        } else {
            // for iPhone
            content
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
    }
}

// MARK: Adaptive Modal Modifier

struct AdaptiveModalModifier: ViewModifier {
    @Binding var route: AppRoute?
    @EnvironmentObject private var coordinator: AppCoordinator
    
    func body(content: Content) -> some View {
        content
        // FullScreen for iPhone and for WelcomeAtFirstLaunchView on iPad
            .fullScreenCover(isPresented: Binding(
                get: {
                    route != nil && shouldBeFullScreen(route!)
                },
                set: {
                    if !$0 {
                        coordinator.closeModal()
                    }
                }
            )) {
                if let route = route {
                    ModalNavigationContainerWrapper(initialRoute: route)
                }
            }
        // Sheet for iPad only (кроме welcome)
            .sheet(isPresented: Binding(
                get: {
                    route != nil && UIDevice.isiPad && !shouldBeFullScreen(route!)
                },
                set: {
                    if !$0 {
                        coordinator.closeModal()
                    }
                }
            )) {
                if let route = route {
                    ModalNavigationContainerWrapper(initialRoute: route)
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                }
            }
    }
    
    /// Determine which routes should be full-screen
    private func shouldBeFullScreen(_ route: AppRoute) -> Bool {
        
        // On iPhone all modal views are full-screen
        if UIDevice.isiPhone {
            return true
        }
        
        // On iPad, only welcomeAtFirstLaunch is full-screen
        switch route {
        case .welcomeAtFirstLaunch:
            return true
        default:
            return false
        }
    }
}

//            .tabViewStyle(.page(indexDisplayMode: .never))
