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
        
        ZStack {
            VStack{
                HStack (spacing: 0) {
                    Image(systemName: "pencil.and.outline")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundStyle(Color.mycolor.myBlue)
                        .padding()
                    VStack (alignment: .leading) {
                        Text("StartToSwiftUI")
                            .font(.headline)
                        Text("SwiftUI Hub Study")
                            .font(.caption)
                    }
                }
                
                Form {
                    Section {
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
                .navigationTitle("About App")
                .scrollContentBackground(.hidden)
                .background(.clear)
            }
        } // ZStack
        .foregroundStyle(Color.mycolor.myAccent)
        .background(.thickMaterial)
    }
}


#Preview {
    NavigationStack{
        AboutApp()
    }
    .environmentObject(PostsViewModel())
}
