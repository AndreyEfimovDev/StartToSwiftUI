//
//  StartToSwiftUIApp.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.08.2025.
//
// v01.14 StartToSwiftUI_Github_GitKraken

import SwiftUI
import Speech

@main
struct StartToSwiftUIApp: App {
    
    @StateObject private var vm = PostsViewModel()
    @StateObject private var noticevm = NoticeViewModel()
    @StateObject private var speechRecogniser = SpeechRecogniser()

    private let hapticManager = HapticService.shared
    
    @State private var showLaunchView: Bool = true
    
    init() {
        
        // Set a custom colour titles for NavigationStack and the magnifying class in the search bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground() // it also removes a dividing line
                
        // Explicitly setting the background colour
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        
        // Setting colour for titles using NSAttributedString
        let accentColor = UIColor(Color.mycolor.myAccent)
        appearance.largeTitleTextAttributes = [
            .foregroundColor: accentColor,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        appearance.titleTextAttributes = [
            .foregroundColor: accentColor,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        
        // Apply to all possible states
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactScrollEdgeAppearance = appearance
        
        // Buttons colour
        UINavigationBar.appearance().tintColor = accentColor
        
        // For UITableView
        UITableView.appearance().backgroundColor = UIColor.clear
        
        // Warm Keyboard
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = scene.windows.first else { return }
            let textField = UITextField()
            window.addSubview(textField)
            textField.becomeFirstResponder()
            textField.resignFirstResponder()
            textField.removeFromSuperview()
            print("Keyboard warmed up")
            
            // Warm Speech Recognition
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                SFSpeechRecognizer.requestAuthorization { _ in
                    print("Speech recognizer warmed up")
                }
            }

        }
    } // init()
    
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
                
                RootView()
                
            }
            .environmentObject(vm)
            .environmentObject(noticevm)
            .environmentObject(speechRecogniser)
            .preferredColorScheme(vm.selectedTheme.colorScheme)
        }
    }
}

