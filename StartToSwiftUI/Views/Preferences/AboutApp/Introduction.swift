//
//  Intro.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 05.11.2025.
//

import SwiftUI

struct Introduction: View {
    
    @EnvironmentObject private var coordinator: NavigationCoordinator
    
    var body: some View {
        ViewWrapperWithCustomNavToolbar(
            title: "Introduction",
            showHomeButton: true
        ) {
            ScrollView {
                Text("""
                   **StartToSwiftUI** is a specialised learning environment for iOS developers designed to help you organise learning materials for SwiftUI.
                   
                   The app offers the following features:
                            
                   **Curated Collection**: Jumpstart your learning with a curated collection of SwiftUI tutorials and articles compiled from open sources. You'll receive a notification when a new version of the collection is available for download. The developer strives to keep this collection up to date, though this cannot be guaranteed at all times.
                   
                   **Personal Library**: Create and manage your own collection of links to learning materials.
                   
                   **Smart Organisation**: Organise learning resources by category such as level of study, year of materials, type of source/media, etc, create a collection of favourite materials.
                   
                   **Full Control**: Edit and delete your materials as needed, save drafts for further processing.
                   
                   **Efficient Search & Filter**: Quickly find what you need using search and filtering tools.
                   
                   **Data Management**: Backup, restore, share, or delete materials as needed.
                   """)
                
                .multilineTextAlignment(.leading)
                .textFormater()
                .padding()
            }
        }
    }
}

#Preview {
    NavigationStack {
        Introduction()
            .environmentObject(NavigationCoordinator())
    }
}

