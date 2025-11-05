//
//  CopyrightPolicy.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 05.11.2025.
//

import SwiftUI

struct CopyrightPolicy: View {
    var body: some View {
        ScrollView {
            //                     COPYRIGHT/DMCA POLICY
            Text("""
                    **StartToSwiftUI** respects intellectual property rights and complies with copyright laws.
                    
                    **WHAT THE APPLICATION STORES:**
                    
                    The application provides users with ability to dowlonad a curated collection of SwiftUI learning links and stores only metadata (links, titles, author names) and does not copy, host, or distribute the content itself.
                    
                    **FOR CONTENT AUTHORS:**
                    
                    If you are the author of material linked within the application's curated collection and wish to have the link removed, please contact me at: andrey.efimov.dev@gmail.com.
                    
                    I commit to:
                    - Review your request within 24-48 hours
                    - Remove the link from the curated collection upon confirmation of authorship
                    - Confirm removal via email
                    
                    **REQUEST PROCEDURE:**
                    
                    Please include in your email:
                    - Link to the material in the original source
                    - Proof of authorship (link to your author profile)
                    - Reason for the removal request
                    
                    **FAIR USE:**
                    
                    The application is created in accordance with Fair Use principles for educational purposes and does not replace original sources.
                    """)
            
            .multilineTextAlignment(.leading)
            .managingPostsTextFormater()
            .padding(.horizontal)
        }
        .navigationTitle("Copyright/DMCA Policy")
    }
}

#Preview {
    CopyrightPolicy()
}
