//
//  FairUseNotice.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 05.11.2025.
//

import SwiftUI

struct FairUseNotice: View {
    
    // MARK: - Dependencies
    
    @EnvironmentObject private var coordinator: AppCoordinator
    
    // MARK: - Body

    var body: some View {
        FormCoordinatorToolbar(
            title: "Fair Use Notice",
            showHomeButton: true
        ) {
            descriptionText
            
        }
    }
    
    private var descriptionText: some View {
        ScrollView {
            Text("""
                    **StartToSwiftUI** operates in accordance with fair use principles for educational purposes. Our application is designed to be a legal and respectful tool for learners.
                    
                    **Why the Application is Legitimate:**
                    
                    **Educational Purpose**: The app is designed exclusively for non-commercial educational use, serving as a personal tool to help users organise and manage their learning materials.
                    
                    **References, Not Content**: Users may save only references to materials via references and metadata. The application does not copy, host, or distribute the actual content of the linked resources.
                    
                    **Author Attribution**: Complete authorship information, including author name, original source, and publication date (if available), may be stored and displayed for each resource.
                    
                    **Direct Source Access**: All references lead directly to the original sources. This ensures that content creators receive the proper traffic, recognition, and any associated benefits from user visits.
                    
                    In essence, the application functions as an organisational tool that respects intellectual property rights while supporting the educational community. We actively encourage users to access all materials through the original sources and to always respect the rights of creators.
                    """)
            .multilineTextAlignment(.leading)
            .textFormater()
            .padding()
        }
    }

}

#Preview {
    NavigationStack {
        FairUseNotice()
            .environmentObject(AppCoordinator())
    }
}
