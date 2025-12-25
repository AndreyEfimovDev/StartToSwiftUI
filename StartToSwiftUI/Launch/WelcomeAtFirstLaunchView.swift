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
    @State private var showTermsButton = false
    private var count: Int = 10
    
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
                                    coordinator.push(.termsOfUse)
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
                                CountdownView(initialSeconds: count)
                                    .padding()
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
                // Delayed appearance of the "Terms of Use" button with animation
                // Visual countdown of given in count seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(count)) {
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
