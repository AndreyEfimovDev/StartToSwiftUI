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
                VStack(spacing: 0) {
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
                        Text("01.01.01")
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
                        .padding(.bottom, 0)
                    
                }
                .padding(.horizontal)

                
                Text("""
            Dear fellow learner,
                        
            The StartToSwiftUI app is my first application, designed to help beginners learn SwiftUI from the ground up.
                        
            The app offers the following features:
            - Load pre-loaded posts (collected from available open sources) and work with them as you wish.
            - Use the search and apply filters to easily work with a large number ofposts.
            - Add your own posts to create a personal library for learning SwiftUI.
            - Edit and delete posts.
            - Share all posts stored in the app or save them in JSON format for data backup and recovery purposes.
            
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
