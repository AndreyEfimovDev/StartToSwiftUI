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
            
            Along the way, I realised I needed to revisit these materials several times to gain a deeper understanding of particular topics. I found it helpful to create a personal library of SwiftUI learning materials, organised in a way that let me quickly find and use the relevant information.
            
            As a result, I decided to build an app for this very purpose. It will allow you to create your own personal library of learning materials, complete with useful features like tracking your progress and sharing your library with other SwiftUI beginners.

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
