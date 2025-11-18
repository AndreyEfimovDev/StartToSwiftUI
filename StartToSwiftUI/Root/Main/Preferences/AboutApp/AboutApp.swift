//
//  AboutApp.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 05.11.2025.
//

import SwiftUI

struct AboutApp: View {
    
    @Environment(\.dismiss) private var dismiss

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
                            .padding(.bottom)
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
            .offset(y: -40)
            .scrollContentBackground(.hidden)
            .listSectionSpacing(8)
            .background(.clear)
        } // ZStack
        .foregroundStyle(Color.mycolor.myAccent)
        .background(.thickMaterial)
        .navigationTitle("About App")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                CircleStrokeButtonView(iconName: "chevron.left", isShownCircle: false) {
                    dismiss()
                }
            }
        }
    }
}


#Preview {
    NavigationStack{
        AboutApp()
    }
    .environmentObject(PostsViewModel())
}
