//
//  StartToSwiftUIApp.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.08.2025.
//
// v01.14 StartToSwiftUI_Github_GitKraken

import SwiftUI

@main
struct StartToSwiftUIApp: App {
    
    @StateObject private var vm = PostsViewModel()
    @State private var showLaunchView: Bool = true
    
    private let hapticManager = HapticService.shared

    init() { // to set a custom colour for the magnifying class in the search bar
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor : UIColor(Color.mycolor.myAccent)]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor : UIColor(Color.mycolor.myAccent)]
        UINavigationBar.appearance().tintColor = UIColor(Color.mycolor.myAccent)
        UITableView.appearance().backgroundColor = UIColor.clear
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack{
                ZStack {
                    if showLaunchView {
                        LaunchView() {
                            showLaunchView = false
                            hapticManager.impact(style: .light)
                        }
                        .transition(.move(edge: .leading))
                    }
                }
                .zIndex(1)

                HomeView()
                
            }
            .environmentObject(vm)
        }
    }
}

