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
                Form {
                    Section {
                        HStack (spacing: 0) {
                            Image(systemName: "pencil.and.outline")
                                .resizable()
                                .bold()
                                .frame(width: 80, height: 80)
                                .foregroundStyle(Color.mycolor.myBlue)
                                .padding()
                            VStack (alignment: .leading) {
                                Text("StartToSwiftUI")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    Text("SwiftUI Study Hub")
                                        .font(.subheadline)
                                Group {
                                    HStack {
                                        Text("Version")
                                        Text("01.01.01")
                                    }
                                    Text("Developed by Andrey Efimov")
                                }
                                .font(.caption)
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                    .frame(maxWidth: .infinity)
                    
                    Section {
                        NavigationLink("Welcome") {
                            WelcomeMessage()
                        }
                        .customListRowStyle(
                            iconName: "suit.heart",
                            iconWidth: iconWidth
                        )
                        NavigationLink("Introduction") {
                            Introduction()
                        }
                        .customListRowStyle(
                            iconName: "textformat.size.larger",
                            iconWidth: iconWidth
                        )
                        NavigationLink("What's New") { //  list.bullet list.bullet.circle square.fill.text.grid.1x2
                            WhatsNew()
                        }
                        .customListRowStyle(
                            iconName: "newspaper",
                            iconWidth: iconWidth
                        )
                    }
                } // Form
                .scrollContentBackground(.hidden)
                .listSectionSpacing(8)
                .background(.clear)
        } // ZStack
        .navigationTitle("About App")
        .navigationBarTitleDisplayMode(.large)
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
