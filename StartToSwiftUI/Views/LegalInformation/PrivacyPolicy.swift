//
//  TermsOfUseView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 05.11.2025.
//

import SwiftUI
import SwiftData

struct PrivacyPolicy: View {
    
    // MARK: - Dependencies
    
    @EnvironmentObject private var coordinator: AppCoordinator
    
    // MARK: - Body

    var body: some View {
        FormCoordinatorToolbar(
            title: "Privacy Policy",
            showHomeButton: true
        ) {
            descriptionText
            
        }
    }
    
    private var descriptionText: some View {
        ScrollView {
            Text("""
                    **Last Updated:** January 28, 2026
                    
                    **INTRODUCTION**
                    
                    StartToSwiftUI (the "App", "we") respects your privacy. This policy explains how we handle information within our application.
                    
                    **SUMMARY:**
                    - We do not collect personal data
                    - All data is stored locally on your device
                    - We do not track your activity
                    - We do not share data with third parties
                    - We do not use analytics or advertising services
                    
                    **1. DATA WE HANDLE**
                    
                    The App does not collect, store, or transmit any user personal data to external servers.
                    
                    **Data you create within the App:**
                    - Collections of links to educational materials
                    - Collection titles and short descriptions (preview information)
                    - Link metadata (e.g., author, source, date)
                    
                    All this data is stored exclusively on your device using built-in iOS data persistence mechanisms (SwiftData, CloudKit, FileManager and UserDefaults).
                    
                    
                    **2. WHERE DATA IS STORED**
                    
                    - All data is stored locally on your iPhone or iPad
                    - We do not have access to your data
                    - Data is not transmitted to our servers or third-party servers
                    
                    
                    **3. CURATED COLLECTION DOWNLOAD**
                    
                    When downloading the pre-built collection of SwiftUI links:
                    - The collection is downloaded into the App from a cloud service only at your explicit request
                    - The data then resides solely on your device
                    - We do not track which collections you download
                    - We do not know which links you view
                    
                    
                    **4. EXTERNAL LINKS**
                    
                    The App may contain links to external educational resources (e.g., YouTube, developer blogs).
                    
                    **Important:** When following links, you leave our App. External sites have their own privacy policies and practices, over which we have no control and for which we accept no responsibility. We recommend reviewing the privacy policy of any external site you visit.
                    
                    
                    **5. YOUR RIGHTS AND MANAGEMENT**
                    
                    You have full control over your data:
                    
                    - **Data Deletion:** Uninstalling the App will remove all locally stored data
                    - **Data Export:** You can export your content from within the App
                    - **Control:** You decide which content to add, edit, or remove
                    
                    
                    **6. DATA SECURITY**
                    
                    Your data is protected by the built-in security and encryption mechanisms of the iOS operating system. Access to the data is restricted to users of the device on which the App is installed.
                    
                    
                    **7. CHILDREN**
                    
                    The App is intended for general educational use and is suitable for all ages. As we do not collect any data from users, we consequently do not collect any data from children.
                    
                    
                    **8. CHANGES TO THE POLICY**
                    
                    We may update this Privacy Policy. We will notify you of significant changes via:
                    - Updating the "Last Updated" date at the top of this document
                    - Providing a notification within the App upon your next launch
                    
                    Your continued use of the App after any such changes constitutes your acceptance of the revised policy.
                    
                    
                    **9. CONTACT US**
                    
                    If you have any questions about the Privacy Policy, please contact us:
                    
                    **Email:** andrey.efimov.dev@gmail.com  
                    **Developer:** Andrey Efimov
                    
                    
                    **10. CONSENT**
                    
                    By using the App, you signify your consent to the terms of this Privacy Policy.
                    """)
            
            .multilineTextAlignment(.leading)
            .textFormater()
            .padding()
        }
    }

}

#Preview {
    NavigationStack {
        PrivacyPolicy()
            .environmentObject(AppCoordinator())
    }

}
