//
//  AboutApp.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 05.11.2025.
//

import SwiftUI

struct AboutApp: View {
    
    // MARK: - Dependencies
    
    @EnvironmentObject private var coordinator: AppCoordinator
    
    // MARK: - Constants
    
    private let iconWidth: CGFloat = 18
    
    // MARK: - Body
    
    var body: some View {
        FormCoordinatorToolbar(
            title: "About App",
            showHomeButton: true
        ) {
            Form {
                appInfoSection
                navigationSection
            }
            .scrollContentBackground(.hidden)
            .listSectionSpacing(8)
        }
        .foregroundStyle(Color.mycolor.myAccent)
        .background(.thickMaterial)
    }
    
    // MARK: - Sections
    
    private var appInfoSection: some View {
        Section {
            HStack(spacing: 0) {
                appIcon
                appDetails
            }
        }
        .listRowBackground(Color.clear)
        .frame(maxWidth: .infinity)
    }
    
    private var navigationSection: some View {
        Section {
            Button("Welcome") {
                coordinator.pushModal(.welcome)
            }
            .customListRowStyle(iconName: "suit.heart", iconWidth: iconWidth)
            
            Button("Introduction") {
                coordinator.pushModal(.introduction)
            }
            .customListRowStyle(iconName: "textformat.size.larger", iconWidth: iconWidth)
            
            Button("Functionality") {                coordinator.pushModal(.functionality)
            }
            .customListRowStyle(iconName: "f.cursive", iconWidth: iconWidth)

            
            Button("What's New") {
                coordinator.pushModal(.whatIsNew)
            }
            .customListRowStyle(iconName: "newspaper", iconWidth: iconWidth)
        }
    }
    
    // MARK: - Subviews
    
    private var appIcon: some View {
        Image("AppIcon_blue_3477F5")
            .resizable()
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .padding()
    }
    
    private var appDetails: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("StartToSwiftUI")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("SwiftUI Study")
                .font(.body)
            
            Group {
                Text("Version \(Bundle.main.versionBuild)")
                
                HStack(spacing: 3) {
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


#Preview {
    NavigationStack{
        AboutApp()
            .environmentObject(AppCoordinator())
    }
}
