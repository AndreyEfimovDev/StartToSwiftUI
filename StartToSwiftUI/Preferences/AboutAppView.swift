//
//  AboutAppView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 19.09.2025.
//

import SwiftUI

struct AboutAppView: View {
    
    let frameHeight: CGFloat = 30
    let frameFontt: Font = .headline
    
    var body: some View {
        
        NavigationStack {
            ScrollView {
                VStack {
                    Divider()
                        .frame(height: 1)
                        .padding(.horizontal, 0)
                    
                    HStack {
                        Text("Name")
                        Spacer()
                        Text("Start To SwiftUI")
                    }
                    .padding(.horizontal)
                    .frame(height: frameHeight)
                    .frame(maxWidth: .infinity)
                    
                    Divider()
                        .frame(height: 1)
                        .padding(.horizontal, 0)
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("01.10")
                    }
                    .padding(.horizontal)
                    .frame(height: frameHeight)
                    .frame(maxWidth: .infinity)
                    Divider()
                        .frame(height: 1)
                        .padding(.horizontal, 0)
                    
                    HStack {
                        Text("Developed by")
                        Spacer()
                        Text("Andrey Efimov")
                    }
                    .padding(.horizontal)
                    .frame(height: frameHeight)
                    .frame(maxWidth: .infinity)
                    
                    Divider()
                        .frame(height: 1)
                        .padding(.horizontal, 0)
                        .padding(.bottom, 8)
                    
                }
                .padding(.horizontal)

                
                Text("""
            Dear fellow learner,
                        
            The StartToSwiftUI app is designed to help beginners learn SwiftUI from the ground up.
                        
            When I first started learning SwiftUI, I was overwhelmed by the variety of self-study options available. Gradually, I began collecting lessons and articles (let's name them posts) from open sources with high-quality explanations of SwiftUI functionality. Later, I realised that I needed to revisit these posts several times to gain a deeper understanding of particular topics. I found it helpful to store and organise them so I could quickly find and use the information. As a result, I decided to create an app for this purpose. Creating my own app also helped me to put my theoretical knowledge into practice, moving it from my head to my heart.
                        
            The app offers the following features:
            - You can load pre-loaded posts (collected from available open sources) and work with them as you wish. You will receive a notification when a new version of the pre-loaded content is ready to download, allowing you to access new material. I strive to keep the pre-loaded articles up to date, though this cannot be guaranteed at all times.
            - You can add your own posts to create a personal library for learning SwiftUI.
            - You can edit and delete posts.
            - You can share all posts stored in the app or save them for backup and recovery purposes.
                        
            If you find this app useful, I would be very happy to hear from you.
                        
            Good luck with mastering SwiftUI!
                        
            Warmly,
            Andrey
            
            """)
                .multilineTextAlignment(.leading)
                .managingPostsTextFormater()
                .padding(.horizontal)
                Spacer()
            }
            .foregroundStyle(Color.mycolor.myAccent)
            .navigationTitle("About App")
        }
    }
}

#Preview {
    AboutAppView()
}
