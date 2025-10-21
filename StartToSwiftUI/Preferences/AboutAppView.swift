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
                .padding()
                
                Text("""
            You are about to restored posts from backup on the device.
            
            The posts from backup will replace
            all current posts in App.
            
            """)
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
