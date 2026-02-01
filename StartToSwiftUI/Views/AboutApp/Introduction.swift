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
               
               **StartToSwiftUI** is a personal learning management app for self-directed SwiftUI learners.
               
               The app offers the following features:
                        
               **CONTENT CREATION**:
               - Create your own study content with full editing capabilities
               - Save drafts for later completion
               - Add personal notes to the materials
               
               **LEARNING MANAGEMENT**:
               - Track progress: 'Added' → 'Started' → 'Learnt' → 'Practiced'
               - Rate materials: Good / Great / Excellent
               - Organise by difficulty level: Beginner / Intermediate / Advanced
               - Mark favourites for quick access
               - Voice search
               
               **ANALYTICS & PROGRESS**:
               - Visual study progress dashboard
               - Statistics by difficulty level
               - Learning history with timestamps
               - Retrospective analysis across different time periods
               - Selective filtering for study progress review
               
               **CROSS-DEVICE**:
               - Full iCloud sync between iPhone and iPad devices
               
               **WIDGET SUPPORT**:
               - Home Screen widgets: Small, Medium, and Large
               - Lock Screen widgets: Circular, Rectangular, and Inline
               - Real-time sync with main app

               **DATA MANAGEMENT**:
               - Share, backup, restore and delete materials as needed

               For detailed functionality information, please visit the 'Functionality' section. 
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

