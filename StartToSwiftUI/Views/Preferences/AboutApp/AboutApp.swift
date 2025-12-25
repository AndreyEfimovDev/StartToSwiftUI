//
//  AboutApp.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 05.11.2025.
//

import SwiftUI

struct AboutApp: View {
    
    @EnvironmentObject private var coordinator: NavigationCoordinator

    let iconWidth: CGFloat = 18
    let frameHeight: CGFloat = 30
    
    var body: some View {
        ViewWrapperWithCustomNavToolbar(
            title: "About App",
            showHomeButton: true
        ) {
            ZStack {
                Form {
                    Section {
                        HStack (spacing: 0) {
                            Image("AppIcon_blue_3477F5")
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
                                        Image(systemName: "ipad")
                                        Text("iOS: \(Bundle.main.minimumiOSVersion)+")
                                    }
                                }
                                .font(.caption2)
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                    .frame(maxWidth: .infinity)
                    
                    Section {
                        Button("Welcome") {
                            coordinator.push(.welcome)
                        }
                        .customListRowStyle(
                            iconName: "suit.heart",
                            iconWidth: iconWidth
                        )
                        Button("Introduction") {
                            coordinator.push(.introduction)
                        }
                        .customListRowStyle(
                            iconName: "textformat.size.larger",
                            iconWidth: iconWidth
                        )
                        Button("What's New") {
                            coordinator.push(.whatIsNew)
                        }
                        .customListRowStyle(
                            iconName: "newspaper",
                            iconWidth: iconWidth
                        )
                    }
                }
                .scrollContentBackground(.hidden)
                .listSectionSpacing(8)
                .background(.clear)
            }
        }
        .foregroundStyle(Color.mycolor.myAccent)
        .background(.thickMaterial)
    }
}


#Preview {
    NavigationStack{
        AboutApp()
            .environmentObject(NavigationCoordinator())
    }
}
