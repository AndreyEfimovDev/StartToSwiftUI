//
//  WelcomeMessage.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 05.11.2025.
//

import SwiftUI

struct WelcomeMessage: View {

    // MARK: - Dependencies

    @EnvironmentObject private var coordinator: AppCoordinator

    // MARK: BODY

    var body: some View {
        FormCoordinatorToolbar(
            title: "Acknowledgements",
            showHomeButton: true
        ) {
            descriptionText
        }
    }
    
    // MARK: Subviews
    
    private var descriptionText: some View {
        ScrollView {
            Text("""
            Dear fellow learner,

            Welcome to **StartToSwiftUI**!
            
            This app is designed to help master SwiftUI quickly and with confidence from the ground up.

            When I first began learning SwiftUI, I was overwhelmed by the sheer variety of self-study options available. I gradually started collecting tutorials and articles from open sources that explained SwiftUI's functionality in a way that matched how I think.
            
            Later, I realised I needed to revisit these materials several times to gain a deeper understanding of particular topics. I found it helpful to store and organise them so I could quickly find and use the relevant information.
            
            As a result, I decided to create an app for this purpose. Creating my own app also helped me to put my theoretical knowledge into practice, moving it from my head to my heart.

            If you find this app useful, I would be very happy to hear from you.

            Good luck with mastering SwiftUI!

            Warmly,
            Andrey
            """)
 
            .multilineTextAlignment(.leading)
            .textFormater()
            .padding()
        }

    }

}

#Preview {
    NavigationStack {
        WelcomeMessage()
            .environmentObject(AppCoordinator())
    }
}
