//
//  CopyrightPolicy.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 05.11.2025.
//

import SwiftUI

struct CopyrightPolicy: View {
    
    // MARK: - Dependencies
    
    @EnvironmentObject private var coordinator: AppCoordinator
    
    // MARK: - Body

    var body: some View {
        
        FormCoordinatorToolbar(
            title: "Copyright/DMCA Policy",
            showHomeButton: true
        ) {
            descriptionText
        }
    }
    
    private var descriptionText: some View {
        ScrollView {
            Text("""
                **StartToSwiftUI** respects intellectual property rights and operates in compliance with applicable copyright legislation.
                
                **WHAT THE APPLICATION STORES**
                
                The application enables users to download a curated collection of SwiftUI learning materials. It allows users to save only metadata (such as titles, author names, and direct URLs) and does not copy, host, or distribute the actual content of the linked materials.
                
                **FOR CONTENT AUTHORS**
                
                If you are the author of material linked within the application's curated collection and wish to have the material removed, please contact us at: andrey.efimov.dev@gmail.com.
                
                We are committed to:
                - Reviewing your request within 24–48 hours
                - Removing the material from the curated collection upon confirmation of authorship
                - Sending you email confirmation once the material has been removed
                
                **REQUEST PROCEDURE**
                
                To facilitate a swift resolution, please include the following in your email:
                - The specific URL of the material in the original source
                - Proof of authorship (e.g., a link to your verified author profile or official website)
                - Reason for the removal request
                
                **FAIR USE:**
                
                This application is developed in accordance with the principles of fair use for educational, non-commercial purposes. Use of the curated collection directs users to the original sources for study and is not intended to replace or replicate those sources.
                """)
            
            .multilineTextAlignment(.leading)
            .textFormater()
            .padding()
        }
    }

}

#Preview {
    NavigationStack {
        CopyrightPolicy()
            .environmentObject(AppCoordinator())
    }
}
