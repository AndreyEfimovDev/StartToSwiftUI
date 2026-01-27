//
//  Intro.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 05.11.2025.
//

import SwiftUI

struct Introduction: View {
    
    // MARK: - Dependencies

    @EnvironmentObject private var coordinator: AppCoordinator
    
    // MARK: BODY

    var body: some View {
        FormCoordinatorToolbar(
            title: "Introduction",
            showHomeButton: true
        ) {
            ScrollView {
                VStack {
                    descriptionText
                    buttonFunctionality
                }
            }
        }
    }
    
    // MARK: Subviews
    
    private var descriptionText: some View {
        ScrollView {
            Text("""
               First of all, thank you for choosing this app.
               
               **StartToSwiftUI** is a personal learning management app for self-directed learners to help you organise study materials for SwiftUI.
               
               The app offers the following features:
                        
               **CONTENT CREATION**:
               - Users create their own study materials with full editing
               - Save drafts for later completion
               - Add personal notes to any material
               
               **LEARNING MANAGEMENT**:
               - Track progress: Added → Started → Learnt → Practiced
               - Rate materials: Good / Great / Excellent
               - Organise by difficulty level: Beginner / Middle / Advanced
               - Mark favourites for quick access
               - Voice Search
               
               **ANALYTICS & PROGRESS**:
               - Visual study progress dashboard
               - Statistics by difficulty level
               - Learning history with timestamps
               - Retrospective analysis in different time periods
               - Selection filtering for study progress review

               **CROSS-DEVICE**:
               - Full iCloud sync between iPhone and iPad devices
               - SwiftData + CloudKit integration

               **WIDGET SUPPORT**:
               - Home Screen widgets: Small, Medium, Large sizes
               - Lock Screen widgets: Circular, Rectangular, Inline
               - Real-time sync with main app
               
               **DATA MANAGEMENT**:
               - Share, backup, restore and delete materials as needed
               
               For detailed functionality information, please visit the Functionality section. 
               
               """)
            
            .multilineTextAlignment(.leading)
            .textFormater()
            .padding()
        }
    }
    
    private var buttonFunctionality: some View {
        
        CapsuleButtonView(
            primaryTitle: "Functionality"
        ){
            coordinator.pushModal(.functionality)
        }
        .padding(.horizontal, 60)
        .padding(15)
    }

}

#Preview {
    NavigationStack {
        Introduction()
            .environmentObject(AppCoordinator())
    }
}

