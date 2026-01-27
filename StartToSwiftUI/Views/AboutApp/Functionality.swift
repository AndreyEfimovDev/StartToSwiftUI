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
               
               **Home View**
               In the app:
               - Tap a material -> Material Details
               - Swipe right -> Mark/Unmark a material as a Favorite
               - Swipe left -> Edit or Delete a material
               - Press and hold -> Update your study progress
               - Double-tap -> Rate a material
               
               **Widget**
               On iPhone/iPad devices:
               - Press and hold on the Home Screen
               - Tap +/Edit in the upper left corner
               - Find "SwiftUI Study"
               - Select a size (Small / Medium / Large)
               - Tap Add Widget

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
