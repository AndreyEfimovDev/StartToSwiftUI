//
//  TermsOfUse.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 05.11.2025.
//

import SwiftUI
import SwiftData

struct TermsOfUse: View {
    
    // MARK: - Dependencies
    
    @EnvironmentObject private var vm: PostsViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    private let hapticManager = HapticManager.shared
    
    // MARK: - States
    
    @State private var isAccepted: Bool = false
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack {
                descriptionText
            }
        }
        .navigationTitle("Terms of Use")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButtonView() {
                    // Check where the view is called from
                    if coordinator.modalPath.isEmpty {
                        // The stack is empty -> routed from StartView, just close it
                        coordinator.closeModal()
                    } else {
                        // The stack is not empty -> routed from LegalInformationView, go step back
                        coordinator.popModal()
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    coordinator.closeModal()
                } label: {
                    Image(systemName: "house")
                        .foregroundStyle(Color.mycolor.myAccent)
                }
            }
        }
    }
    
    private var descriptionText: some View {
        ScrollView {
            Text("""
                        **Last Updated:** January 28, 2026
                        
                        Please read these Terms of Use carefully before using the StartToSwiftUI application.
                        
                        
                        **1. ACCEPTANCE OF TERMS**
                        
                        By using the StartToSwiftUI application (the "App"), you agree to be bound by these Terms of Use. If you do not agree to any part of these terms, please do not use the App.
                        
                        
                        **2. DESCRIPTION OF SERVICE**
                        
                        StartToSwiftUI is a free educational application for:
                        - Content creation
                        - Learning management
                        - Analytics and study progress
                        
                        
                        **3. LICENSE TO USE**
                        
                        We grant you a limited, non-exclusive, non-transferable, revocable licence to use the App for personal, non-commercial educational purposes.
                        
                        **YOU MAY:**
                        ✓ Use the App for personal learning  
                        ✓ Create and organise your own collections of materials  
                        ✓ Download and use the curated starter content for learning SwiftUI, compiled by the App's developer
                        
                        **YOU MAY NOT:**
                        ✗ Use the App for commercial purposes  
                        ✗ Resell or distribute the App's content  
                        ✗ Copy, modify, decompile, or reverse-engineer the App  
                        ✗ Publicly distribute the curated starter content  
                        ✗ Use the App to infringe copyright or intellectual property rights
                        
                        
                        **4. USER CONTENT**
                        
                        **4.1. Your Responsibility:**
                        - You are solely responsible for any content you add to the App
                        - You agree to add content related only to legal, publicly available materials
                        - You agree to respect copyright and attribute authorship
                        - You must not use the App to store references to illegal or malicious content
                        
                        **4.2. Local Storage:**
                        - All user content is stored locally on your device
                        - We do not have access to your content collections
                        - You are solely responsible for backing up your data
                        
                        
                        **5. CURATED STARTER CONTENT**
                        
                        **5.1. Provided Content:**
                        - The curated starter content of SwiftUI has been compiled by the developer from public sources
                        - All rights to the materials linked to belong to their respective authors
                        - The collection is provided "as is" for educational purposes only
                        
                        **5.2. Terms for Using the Provided Content:**
                        By downloading the curated starter content, you agree:
                        - To use it only for non-commercial educational purposes
                        - Not to distribute the collection publicly or commercially
                        - To respect the copyright of all linked materials
                        - To access original sources via the provided references
                        
                        
                        **6. INTELLECTUAL PROPERTY**
                        
                        **6.1. App Rights:**
                        - All rights to the StartToSwiftUI App belong to the developer
                        - The interface, design, and functionality are protected by copyright
                        
                        **6.2. Content Rights:**
                        - The App does not claim rights over the materials linked to
                        - All rights to the external content belong to its respective authors
                        - The App operates in accordance with fair use principles
                        
                        **6.3. For Content Authors:**
                        If you are the author of material linked within the curated collection and wish to have the link removed:
                        - Contact by email at: andrey.efimov.dev@gmail.com
                        - We will review the request within 24-48 hours
                        - We will remove the link upon confirmation of authorship
                        
                        
                        **7. DISCLAIMER**
                        
                        **7.1. "As Is":**
                        
                        The App is provided "as is" without any warranties:
                        - We do not guarantee uninterrupted operation of the App
                        - We do not guarantee the ongoing validity of references (external sites may change)
                        - We do not guarantee the quality or accuracy of the materials accessed via references
                        
                        **7.2. External Content:**
                        - We do not control the content of external websites
                        - We are not responsible for the content of materials accessed via references
                        - Users follow references at their own risk
                        
                        **7.3. Educational Purpose:**
                        - The App is created solely for educational purposes
                        - We do not encourage copyright infringement
                        - The user is solely responsible for complying with the laws of their jurisdiction
                                                
                        
                        **8. LIMITATION OF LIABILITY**
                        
                        To the maximum extent permitted by applicable law:
                        - We are not liable for any damages resulting from the use of the App
                        - We are not liable for data loss (please ensure you use backup methods)
                        - We are not liable for the actions of users or third parties
                        
                        
                        **9. CHANGES TO THE APP AND TERMS**
                        
                        - We may update the App and these Terms at any time
                        - We will notify you of significant changes via the App
                        - Continued use of the App after changes constitutes acceptance of the new Terms
                        
                        
                        **10. TERMINATION**
                        
                        Your licence to use the App may be terminated if:
                        - You violate these Terms
                        - You use the App for unlawful activities
                        - We are required to do so by law
                        
                        You may stop using the App at any time by uninstalling it.
                        
                        
                        **11. GOVERNING LAW**
                        
                        These Terms are governed by and construed in accordance with the laws of the Russian Federation. Any disputes shall be subject to the exclusive jurisdiction of the courts of the Russian Federation.
                        
                        
                        **12. SEVERABILITY**
                        
                        If any provision of these Terms is found to be invalid or unenforceable, the remaining provisions shall remain in full force and effect.
                        
                        
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
                        """)
            .multilineTextAlignment(.leading)
            .textFormater()
            .padding()
        }
    }
    
}

#Preview {
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppSyncState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    
    let vm = PostsViewModel(modelContext: context)
    
    NavigationStack {
        TermsOfUse()
            .modelContainer(container)
            .environmentObject(vm)
            .environmentObject(AppCoordinator())
    }
}
