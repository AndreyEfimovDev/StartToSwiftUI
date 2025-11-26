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
                        Image("swift_logo_blue_3477F5_icon")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .padding()
                        VStack (alignment: .leading, spacing: 0) {
                            Text("StartToSwiftUI")
                                .font(.title2)
                                .fontWeight(.semibold)
                                Text("SwiftUI Study Hub")
                                    .font(.body)
                            Group{
                                Text("Version \(Bundle.main.versionBuild)")
                                HStack (spacing: 3) {
                                    Text("Support:")
                                    Image(systemName: "iphone")
                                    Text("iOS min: \(Bundle.main.minimumiOSVersion)")
                                }
                            }
                            .font(.caption2)
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
                    NavigationLink("What's New") {
                        WhatsNewView()
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
        .foregroundStyle(Color.mycolor.myAccent)
        .background(.thickMaterial)
        .navigationTitle("About App")
        .navigationBarBackButtonHidden(true)
//        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
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
}
