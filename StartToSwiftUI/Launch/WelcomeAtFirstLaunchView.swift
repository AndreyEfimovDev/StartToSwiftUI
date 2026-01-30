//
//  WelcomeAtFirstLaunchView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 24.12.2025.
//

import SwiftUI

struct WelcomeAtFirstLaunchView: View {
    
    // MARK: - Dependencies
    @EnvironmentObject private var coordinator: AppCoordinator
    private let hapticManager = HapticService.shared

    // MARK: - States
    @State private var showTermsButton = false
        
    // MARK: BODY
    var body: some View {
        ZStack {
            Color.mycolor.myBackground
                .ignoresSafeArea()
            ScrollView {
                VStack {
                    descriptionText
                    buttonTermsOfUse
                        .opacity(showTermsButton ? 1 : 0)
                }
                .frame(maxWidth: 600)
                .padding()
            }
            .navigationTitle("Affirmation")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                withAnimation(.easeInOut(duration: 3)) {
                    showTermsButton = true
                }
            }
        }
    }
    
    // MARK: Subviews
    
    private var descriptionText: some View {
        Text("""
        This app is designed for educational purposes and helps self-paced learners effectively manage SwiftUI learning materials.
                  
        **For each material, you have the ability to create and save:**
        
        - Title and a preview information
        - The author's name
        - A direct link to a respective original source
        - The type of the source (Website, YouTube)
        - The publication date (if known)
        - The type of material (single tutorial, course, solution, etc.)
        - The difficulty level (Beginner, Intermediate, Advanced)
        - Your personal notes on the material
                             
        To use this app, you need to agree to the **Terms of Use**.
        """
        )
        .multilineTextAlignment(.leading)
        .textFormater()
        .padding(.top)
        .padding(.horizontal)
    }
    
    private var buttonTermsOfUse: some View {
        Button {
            coordinator.pushModal(.termsOfUse)
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
}

#Preview {
    WelcomeAtFirstLaunchView()
        .environmentObject(AppCoordinator())
}
