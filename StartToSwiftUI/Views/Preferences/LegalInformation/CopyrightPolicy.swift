//
//  CopyrightPolicy.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 05.11.2025.
//

import SwiftUI

struct CopyrightPolicy: View {
    
    @EnvironmentObject private var coordinator: AppCoordinator
    
    var body: some View {
        
        ViewWrapperWithCustomNavToolbar(
            title: "Copyright/DMCA Policy",
            showHomeButton: true
        ) {
            ScrollView {
                Text("""
                        **StartToSwiftUI** respects intellectual property rights and complies with copyright legislation.
                        
                        **WHAT THE APPLICATION STORES**
                        
                        The application allows users to download a curated collection of SwiftUI learning links. It stores only metadata such as titles, author names, direct URLs, etc. and does not copy, host, or distribute the actual content.
                        
                        **FOR CONTENT AUTHORS**
                        
                        If you are the author of material linked within the application's curated collection and would like the link removed, please contact me at: andrey.efimov.dev@gmail.com.
                        
                        We are committed to the following:
                        - Reviewing your request within 24–48 hours
                        - Removing the link from the curated collection upon confirmation of authorship
                        - Sending you confirmation of the removal via email
                        
                        **REQUEST PROCEDURE**
                        
                        Please include the following in your email:
                        - The link to the material on the original source
                        - Proof of authorship (e.g., a link to your author profile or website)
                        - Reason for the removal request
                        
                        **FAIR USE:**
                        
                        The application has been developed in accordance with Fair Use principles for educational, non-commercial purposes. It is designed to direct users to original sources and does not replace or replicate them.
                        """)
                
                .multilineTextAlignment(.leading)
                .textFormater()
                .padding()
            }
        }
    }
}

#Preview {
    CopyrightPolicy()
        .environmentObject(AppCoordinator())
}
