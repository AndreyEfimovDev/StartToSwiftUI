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
/// If route != nil (the is a modal view to show):
/// ┌────────────────────────────┐
/// │                    for iPhone (always fullscreen)                                  │
/// ├────────────────────────────┤
/// │ ✅ fullScreenCover (all modal views are fullscreen)                  │
/// └────────────────────────────┘
///
/// ┌────────────────────────────┐
/// │                    for iPad (separation)                                                │
/// ├────────────────────────────┤
/// │ ❓ Check: shouldBeFullScreen(route!) ?                                   │
/// │     ├─ YES (welcomeAtFirstLaunch) →  fullScreen                  │
/// │     └─ NO (preferences, notices, etc.) → sheet                        │
/// └────────────────────────────┘
///
struct AdaptiveModalModifier: ViewModifier {
    
    @Binding var route: AppRoute?
    @EnvironmentObject private var coordinator: AppCoordinator
    
    private var isFullScreenModalPresented: Binding<Bool> {
        Binding(
            get: { // Result: Determines whether to show the modal View
                route.map { shouldBeFullScreen($0) } ?? false            },
            set: {
                // Set: synchronise modal closing with app logic → when SwiftUI changes its value to false when closing
                // If the new value is !$0 (i.e., false) → call coordinator.closeModal()
                if !$0 {
                    coordinator.closeModal()
                }
            }
        )
    }
    
    private var isSheetModalPresented: Binding<Bool> {
        Binding(
            get: { //
                route.map { UIDevice.isiPad && !shouldBeFullScreen($0) } ?? false
            },
            set: {
                if !$0 {
                    coordinator.closeModal()
                }
            }

        )
    }


    func body(content: Content) -> some View {
        content
        // FullScreen for iPhone and for WelcomeAtFirstLaunchView on iPad
            .fullScreenCover(isPresented: isFullScreenModalPresented) {
                if let validRoute = route {
                    ModalNavigationContainerWrapper(initialRoute: validRoute)
                } else {
                    // Fallback view if route == nil
                    EmptyView()
                        .onAppear {
                            coordinator.closeModal()
                        }
                }
            }
        // Sheet for iPad only (except WelcomeAtFirstLaunchView)
            .sheet(isPresented: isSheetModalPresented){
                // Case when the iPad device and not fullscreen
                if let validRoute = route {
                    ModalNavigationContainerWrapper(initialRoute: validRoute)
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                } else {
                    // Fallback view if route == nil
                    EmptyView()
                        .onAppear {
                            coordinator.closeModal()
                        }
                }
            }
    }
    
    /// Determine which routes should be full-screen
    private func shouldBeFullScreen(_ route: AppRoute) -> Bool {
        
        // On iPhone all modal views are full-screen
        if UIDevice.isiPhone {
            return true
        }
        
//        // On iPad, only welcomeAtFirstLaunch is full-screen
//        switch route {
//        case .welcomeAtFirstLaunch:
//            return true
//        default:
            return false
//        }
    }
}

//            .tabViewStyle(.page(indexDisplayMode: .never))
