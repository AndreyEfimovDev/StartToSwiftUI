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
               - Create and manage your personal study library of SwiftUI materials matching your learning style
               - Categorise resources by topics, difficulty levels of study, etc.
               - Add personal notes to materials, save drafts, and organise everything exactly how you want
               
               **CODE SNIPPETS**:
               - Curated code snippets demonstrating advanced SwiftUI techniques — learn by example, copy and apply
               
               **LEARNING MANAGEMENT**:
               - Classify by type: Lesson, Course, Article, Bug, Other
               - Track progress: 'Added' → 'Started' → 'Learnt' → 'Practiced'
               - Rate materials: Good / Great / Excellent
               - Organise by difficulty level: Beginner / Intermediate / Advanced
               - Mark favourites for quick access
               
               **ANALYTICS & PROGRESS**:
               - Visual study progress dashboard
               - Review statistics by difficulty level
               - Learning history with timestamps
               - Retrospective analysis across different time periods
               - Selective filtering for study progress review
               
               **ALWAYS IN SYNC**:
               - Full iCloud sync between iPhone and iPad
               - Pick up right where you left off, on any device
               
               **WIDGET SUPPORT**:
               - Home Screen widgets: Small, Medium, and Large
               - Lock Screen widgets: Circular, Rectangular, and Inline
               - Real-time sync with main app

               **YOUR DATA, YOUR CONTROL**:
               - Move materials to Deleted, then erase them permanently or restore back to Active anytime
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

