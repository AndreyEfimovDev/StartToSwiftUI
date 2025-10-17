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
    
    init() { // to set a colour for the magnifying class in the search bar
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor : UIColor(Color.mycolor.accent)]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor : UIColor(Color.mycolor.accent)]
        UINavigationBar.appearance().tintColor = UIColor(Color.mycolor.accent)
        UITableView.appearance().backgroundColor = UIColor.clear
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(vm)
        }
    }
}

