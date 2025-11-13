//
//  WelcomeMessage.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 05.11.2025.
//

import SwiftUI

struct WelcomeMessage: View {
    var body: some View {
        ScrollView {
            Text("""
            Dear fellow learner,

            Welcome to **StartToSwiftUI**!
            
            This app is designed to help beginners learn SwiftUI from the ground up.

            When I first began learning SwiftUI, I was overwhelmed by the sheer variety of self-study options available. I gradually started collecting tutorials and articles from open sources that explained SwiftUI's functionality in a way that matched how I think. Later, I realised I needed to revisit these posts several times to gain a deeper understanding of particular topics. I found it helpful to store and organise them so I could quickly find and use the relevant information. As a result, I decided to create an app for this purpose. Creating my own app also helped me to put my theoretical knowledge into practice, moving it from my head to my heart.

            The app offers the following features:

            **Pre-loaded Collection**: Access a curated collection of SwiftUI tutorials and articles compiled from open sources. You'll receive a notification when a new version of the collection is available for download. I strive to keep this collection up to date, though this cannot be guaranteed at all times.

            **Personal Library**: Add your own posts to create a personal collection for learning SwiftUI.

            **Full Control**: Edit and delete your posts as needed.

            **Data Management**: Share all posts stored in the app or save them for backup and recovery purposes.
            
            If you find this app useful, I would be very happy to hear from you.

            Good luck with mastering SwiftUI!

            Warmly,
            Andrey
            """)
 
            .multilineTextAlignment(.leading)
            .managingPostsTextFormater()
            .padding(.horizontal)
        }
        .foregroundStyle(Color.mycolor.myAccent)
        .navigationTitle("Welcome")
    }
}

#Preview {
    WelcomeMessage()
}
