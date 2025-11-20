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
    @StateObject private var noticevm = NoticeViewModel()
    private let hapticManager = HapticService.shared
    
    @State private var showLaunchView: Bool = true
    
    init() {
        
        // Set a custom colour for the magnifying class in the search bar
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor : UIColor(Color.mycolor.myAccent)]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor : UIColor(Color.mycolor.myAccent)]
        UINavigationBar.appearance().tintColor = UIColor(Color.mycolor.myAccent)
        UITableView.appearance().backgroundColor = UIColor.clear
        
        // Warm a keyboard at app launch
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = scene.windows.first else { return }
            let textField = UITextField()
            window.addSubview(textField)
            textField.becomeFirstResponder()
            textField.resignFirstResponder()
            textField.removeFromSuperview()
        }
        
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
                NavigationStack{
                    HomeView()
                }
            }
            .environmentObject(vm)
            .environmentObject(noticevm)
            .preferredColorScheme(vm.selectedTheme.colorScheme)
            
        }
    }
}

