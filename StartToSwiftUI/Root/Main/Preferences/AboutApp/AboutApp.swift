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
        
        Form {
            Section {
                HStack {
                    Text("Name")
                    Spacer()
                    Text("StartToSwiftUI")
                }
                HStack {
                    Text("Version")
                    Spacer()
                    Text("01.01.01")
                }
                HStack {
                    Text("Developed by")
                    Spacer()
                    Text("Andrey Efimov")
                }
            }
            .foregroundStyle(Color.mycolor.myAccent)
            .padding(.horizontal)
            .frame(maxWidth: .infinity)

            NavigationLink("Welcome") {
                WelcomeMessage()
            }
            .customPreferencesListRowStyle(
                iconName: "suit.heart",
                iconWidth: iconWidth
            )
            NavigationLink("Introduction") {
                Introduction()
            }
            .customPreferencesListRowStyle(
                iconName: "textformat.size.larger",
                iconWidth: iconWidth
            )
            NavigationLink("What's New") { //  list.bullet list.bullet.circle square.fill.text.grid.1x2
                WhatsNew()
            }
            .customPreferencesListRowStyle(
                iconName: "newspaper",
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
