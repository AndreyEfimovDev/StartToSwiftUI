//
//  AboutApp.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 05.11.2025.
//

import SwiftUI

struct AboutApp: View {
    
    let iconWidth: CGFloat = 18
    let frameHeight: CGFloat = 30
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .frame(height: 1)
                .padding(.horizontal, 0)
            
            HStack {
                Text("Name")
                Spacer()
                Text("StartToSwiftUI")
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
        .foregroundStyle(Color.mycolor.myAccent)
        .padding(.horizontal)
        
        Form {
            NavigationLink("Welcome") {
                WelcomeMessage()
            }
            .customPreferencesListRowStyle(
                iconName: "apple.books.pages",
                iconWidth: iconWidth
            )
            NavigationLink("Introduction") {
                Intro()
            }
            .customPreferencesListRowStyle(
                iconName: "character.text.justify",
                iconWidth: iconWidth
            )
            NavigationLink("Functionality") { //  list.bullet list.bullet.circle square.fill.text.grid.1x2
                Functionality()
            }
            .customPreferencesListRowStyle(
                iconName: "helm",
                iconWidth: iconWidth
            )
        } // Form
        .foregroundStyle(Color.mycolor.myAccent)
        .navigationTitle("About App")
    }
}


#Preview {
    NavigationStack{
        AboutApp()
    }
    .environmentObject(PostsViewModel())
}
