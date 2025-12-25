//
//  WelcomeAtFirstLaunchView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 24.12.2025.
//

import SwiftUI

struct WelcomeAtFirstLaunchView: View {
    
    @EnvironmentObject private var coordinator: NavigationCoordinator

    @State private var showTermsOfUse: Bool = false
    @State private var showTermsButton = false // Контролирует анимацию появления кнопки Terms of Use
    
    var body: some View {
        ZStack {
            Color.mycolor.myBackground
                .ignoresSafeArea()
                ScrollView {
                    VStack {
                        Text("""
                    This application is created for educational purposes and helps organise links to learning SwiftUI materials.
                     
                    **It is important to understand:**
                     
                    - The app stores only links to materials available from public sources.
                    - All content belongs to its respective authors.
                    - The app is free and intended for non-commercial use.
                    - Users are responsible for respecting copyright when using materials.
                     
                    **For each material, you have ability to save:**
                    
                    - Direct link to the original source.
                    - Author's name.
                    - Source (website, YouTube, etc.).
                    - Publication date (if known).
                                         
                    To use this application, you need to agree to **Terms of Use**.
                    """
                        )
                        .multilineTextAlignment(.leading)
                        .textFormater()
                        .padding(.top)
                        .padding(.horizontal)
                        
                        ZStack {
                            if showTermsButton {
                                Button {
#if DEBUG
                                    print("📱 Welcome: Terms button tapped")
                                    print("📱 Before push - path count: \(coordinator.path.count)")
#endif
                                    coordinator.push(.termsOfUse)
#if DEBUG
                                    print("📱 After push - path count: \(coordinator.path.count)")
#endif
                                } label: {
                                    Text("Terms of Use")
                                        .font(.title)
                                        .padding()
                                        .background(.ultraThinMaterial)
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .stroke(Color.mycolor.myBlue, lineWidth: 1)
                                        )
                                }
                                .tint(Color.mycolor.myBlue)
                                .padding()
                            }
                            
                            if !showTermsButton {
                                CustomProgressView()
                            }
                        }
                    } // VStack
                    .frame(maxWidth: 600)
                    .padding()
                } // ScrollView
                .navigationTitle("Affirmation")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
            .onAppear {
                // Задержка появдения кнопки "Terms of Use" с анимацией
                // Вместе с CustomProgressView()
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    withAnimation(.easeInOut(duration: 3)) {
                        showTermsButton = true
                    }
                }
            }
        }
    }
}

#Preview {
    WelcomeAtFirstLaunchView()
        .environmentObject(NavigationCoordinator())
}
