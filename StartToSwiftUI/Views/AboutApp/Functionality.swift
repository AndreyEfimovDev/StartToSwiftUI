//
//  Functionality.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 27.01.2026.
//

import SwiftUI

struct Functionality: View {
    
    // MARK: - Dependencies

    @EnvironmentObject private var coordinator: AppCoordinator
    
    // MARK: BODY

    var body: some View {
        FormCoordinatorToolbar(
            title: "Functionality",
            showHomeButton: true
        ) {
            descriptionText
        }
    }
    
    // MARK: Subviews
    
    private var descriptionText: some View {
        ScrollView {
            Text("""
               Here are some tips to help you easily navigate the app and explore its functionality.
               
               **Home View Navigation**
               From the main list of study materials:
               - Pull down to refresh the list of items
               - Tap on a material to open its Details view
               - Swipe right on an item to mark or unmark it as a Favourite
               - Swipe left on an item to Edit or Delete it
               - Press and hold on an item to update your Study Progress
               - Double-tap on an item to Rate the material
               
               **Add Materials**
               You have the ability to create your own study content:
               - Title
               - Intro description
               - Author's name of the material
               - Reference to the original source
               - Type of the source (Website, YouTube)
               - Publication date (if known)
               - Type of material (lesson, course, solution, etc.)
               - Difficulty level (Beginner, Intermediate, Advanced)
               - Your personal notes on the material
               
               **Widget**
               To add a widget to your iPhone or iPad Home Screen:
               - Touch and hold an empty area on your Home Screen until the apps jiggle
               - Tap the + (Add) button in the top-left corner
               - Search for "SwiftUI Study" in the widget gallery
               - Select your preferred widget size (Small, Medium, or Large)
               - Tap Add Widget, then tap Done

               The rest should be self-explanatory.
               """)
            
            .multilineTextAlignment(.leading)
            .textFormater()
            .padding()
        }
    }


}

#Preview {
    NavigationStack {
        Functionality()
            .environmentObject(AppCoordinator())
    }
}
