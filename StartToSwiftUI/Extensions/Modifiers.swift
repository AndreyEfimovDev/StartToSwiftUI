//
//  Modifiers.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 19.09.2025.
//

import SwiftUI

// MARK: - ShimmerWave ViewModifier

struct ShimmerWave: ViewModifier {
    
    let enabled: Bool
    
    @State private var phase: CGFloat = 0
    @State private var task: Task<Void, Never>?

    func body(content: Content) -> some View {
        if enabled {
            content
                .overlay(shimmerOverlay)
                .clipped()
                .task { await runLoop() }
        } else {
            content
        }
    }

    private var shimmerOverlay: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let bandWidth = w * 0.4

            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: Color.mycolor.myAccent.opacity(0.06), location: 0.25),
                    .init(color: Color.mycolor.myAccent.opacity(0.22), location: 0.5),
                    .init(color: Color.mycolor.myAccent.opacity(0.06), location: 0.75),
                    .init(color: .clear, location: 1),
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: bandWidth)
            .offset(x: phase * (w + bandWidth) - bandWidth)
            .allowsHitTesting(false)
        }
    }

    private func runLoop() async {
        /*
         Как работает цикл:
         ```
         phase = 0 (полоса за левым краем)
             │
             ▼ withAnimation(.linear(duration: 0.5))
         phase = 1 (полоса уходит за правый край)  ← 0.5 сек
             │
             ▼ Task.sleep(0.5) — ждём конца анимации
         phase = 0 (мгновенный сброс, полоса за кадром)
             │
             ▼ Task.sleep(3.0) — тихая пауза
             └── повтор
         */
        while !Task.isCancelled {
            withAnimation(.linear(duration: 1.2)) { phase = 1 }
            do {
                try await Task.sleep(for: .seconds(1.2)) // wait for the end of sweep
                phase = 0
                try await Task.sleep(for: .seconds(3.0)) // pause between animations
            } catch {
                break  // CancellationError → exit imideatelly
            }
        }
    }
}

extension View {
    func shimmerWave(enabled: Bool = true) -> some View {
        modifier(ShimmerWave(enabled: enabled))
    }
}


extension Color {
    func verticalGradient() -> LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: self.opacity(0.1), location: 0.0),
                .init(color: self.opacity(0.3), location: 0.3),
                .init(color: self.opacity(0.7), location: 0.7),
                .init(color: self.opacity(1.0), location: 1.0)
            ]),
            startPoint: .bottom,
            endPoint: .top
        )
    }
}


struct CrossedImage: ViewModifier {
    var color: Color = Color.mycolor.myBlue
    var lineWidth: CGFloat = 2
    var isCrossed: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .frame(height: lineWidth)
                    .foregroundColor(color)
                    .rotationEffect(.degrees(45))
                    .opacity(isCrossed ? 1 : 0)
                    .animation(.easeInOut(duration: 0.3), value: isCrossed)
            )
    }
}

extension View {
    func crossed(color: Color = Color.mycolor.myRed, lineWidth: CGFloat = 2, isCrossed: Bool) -> some View {
        modifier(CrossedImage(color: color, lineWidth: lineWidth, isCrossed: isCrossed))
    }
}


// MARK: Custom One/Two Taps for RowPost in MaterialsHomeView

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
            return false
    }
}

//            .tabViewStyle(.page(indexDisplayMode: .never))
