//
//  TermsOfUse.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 05.11.2025.
//

import SwiftUI

struct TermsOfUse: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: PostsViewModel
    
    @State private var isAccepted: Bool = false
    
    let action: () -> ()
    
    init(
        action: @escaping () -> Void
    ) {
        self.action = action
    }
    var body: some View {
        
        ScrollView {
            VStack {
                //                     **TERMS OF USE FOR THE APPLICATION**
                Text("""
                        **Last Updated:** November 8, 2025
                        
                        Please read and accept these Terms of Use carefully before using the StartToSwiftUI application.
                        
                        
                        **1. ACCEPTANCE OF TERMS**
                        
                        By using the StartToSwiftUI application (the "App"), you agree to be bound by these Terms of Use. If you do not agree to any part of these terms, please do not use the App.
                        
                        
                        **2. DESCRIPTION OF SERVICE**
                        
                        StartToSwiftUI is a free educational application for:
                        - Creating personal collections of links to educational SwfitUI materials
                        - Organising learning resources
                        - Using a curated collection of links from the developer for learning SwiftUI
                        
                        **IMPORTANT:** The App stores only links to materials, NOT the content itself.
                        
                        
                        **3. LICENSE TO USE**
                        
                        We grant you a limited, non-exclusive, non-transferable licence to use the App for personal, non-commercial educational purposes.
                        
                        **YOU MAY:**
                        ✓ Use the App for personal learning  
                        ✓ Create and organise your own collections of links  
                        ✓ Download and use the provided collection of links for learning SwiftUI, compiled by the App's developer
                        
                        **YOU MAY NOT:**
                        ✗ Use the App for commercial purposes  
                        ✗ Resell or distribute the App's content  
                        ✗ Copy, modify, or decompile the App  
                        ✗ Publicly distribute the curated collection of links  
                        ✗ Use the App to infringe copyright
                        
                        
                        **4. USER CONTENT**
                        
                        **4.1. Your Responsibility:**
                        - You are solely responsible for the links you add to the App
                        - You agree to add links only to legal, publicly available materials
                        - You agree to respect copyright and attribute authorship
                        - You must not use the App to store links to illegal or malicious content
                        
                        **4.2. Local Storage:**
                        - All user content is stored locally on your device
                        - We do NOT have access to your link collections
                        - You are responsible for backing up your data
                        
                        
                        **5. CURATED LINK COLLECTION**
                        
                        **5.1. Provided Collection:**
                        - The curated collection of SwiftUI links has been created by the developer from public sources
                        - All rights to the materials linked to belong to their respective authors
                        - The collection is provided "as is" for educational purposes only
                        
                        **5.2. Terms for Using the Collection:**
                        By downloading the curated collection, you agree:
                        - To use it only for non-commercial educational purposes
                        - NOT to distribute the collection publicly or commercially
                        - To respect the copyright of all materials
                        - To access original sources via the provided links
                        
                        
                        **6. INTELLECTUAL PROPERTY**
                        
                        **6.1. App Rights:**
                        - All rights to the StartToSwiftUI App belong to the developer
                        - The interface, design, and functionality are protected by copyright
                        
                        **6.2. Content Rights:**
                        - The App does NOT claim rights over the materials linked to
                        - All rights to the content belong to its authors
                        - The App operates in accordance with Fair Use principles
                        
                        **6.3. For Content Authors:**
                        If you are the author of material linked within the curated collection and wish to have the link removed:
                        - Contact us email at: andrey.efimov.dev@gmail.com
                        - We will review the request within 24-48 hours
                        - We will remove the link upon confirmation of authorship
                        
                        
                        **7. DISCLAIMER**
                        
                        **7.1. "As Is":**
                        
                        The App is provided "as is" without any warranties:
                        - We do NOT guarantee uninterrupted operation of the App
                        - We do NOT guarantee the ongoing validity of links (external sites may change)
                        - We do NOT guarantee the quality or accuracy of the materials accessed via links
                        
                        **7.2. External Content:**
                        - We do NOT control the content of external websites
                        - We are NOT responsible for the content of materials accessed via links
                        - Users follow links at their own risk
                        
                        **7.3. Educational Purpose:**
                        - The App is created solely for educational purposes
                        - We do not encourage copyright infringement
                        - The user is responsible for complying with the laws of their jurisdiction
                                                
                        
                        **8. LIMITATION OF LIABILITY**
                        
                        To the maximum extent permitted by law:**
                        - We are NOT liable for any damages resulting from the use of the App
                        - We are NOT liable for data loss (please use backup methods)
                        - We are NOT liable for the actions of users or third parties
                        
                        
                        **9. CHANGES TO THE APP AND TERMS**
                        
                        - We may update the App and these Terms at any time
                        - We will notify you of significant changes via the App
                        - Continued use of the App after changes constitutes acceptance of the new Terms
                        
                        
                        **10. TERMINATION**
                        
                        Your access to the App might be terminated if:
                        - You violate these Terms
                        - You use the App for unlawful activities
                        - Required by law
                        
                        You may stop using the App at any time by uninstalling it.
                        
                        
                        **11. GOVERNING LAW**
                        
                        These Terms are governed by the laws of Russia. Any disputes shall be subject to the jurisdiction of the courts of the Russian Federation.
                        
                        
                        **12. SEVERABILITY**
                        
                        If any provision of these Terms is found to be invalid, the remaining provisions shall remain in full force and effect.
                        
                        
                        **13. CONTACT INFORMATION**
                        
                        For questions regarding these Terms, please contact us:
                        
                        **Email:** andrey.efimov.dev@gmail.com  
                        **Developer:** Andrey Efimov  
                        **App:** StartToSwiftUI
                        
                        
                        **14. AGREEMENT**
                        
                        By clicking "I Accept the Terms" or by using the App, you confirm that you:
                        - Have read and understood these Terms
                        - Agree to be bound by them
                        - Will use the App lawfully and ethically
                        
                        
                        **Effective Date:** November 8, 2025
                        
                        """)
                
                .multilineTextAlignment(.leading)
                .managingPostsTextFormater()
                .padding(.horizontal)
                
                CapsuleButtonView(
                    primaryTitle: "I have read and accept",
                    secondaryTitle: "Accepted",
                    isToChange: isAccepted || vm.isTermsOfUseAccepted) {
                        isAccepted = true
                        DispatchQueue.main.asyncAfter(deadline: vm.dispatchTime) {
                            vm.isTermsOfUseAccepted = true
                            dismiss()
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(30)
                    .disabled(vm.isTermsOfUseAccepted)
            }
        }
        .navigationTitle("Terms of Use")
    }
}

#Preview {
    NavigationStack {
        TermsOfUse() {}
            .environmentObject(PostsViewModel())
    }
}
