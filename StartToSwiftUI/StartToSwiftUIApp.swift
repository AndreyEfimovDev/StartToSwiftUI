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
    
    @Environment(\.dismiss) private var dismiss

    @StateObject private var vm = PostsViewModel()
    @StateObject private var noticevm = NoticeViewModel()

    private let hapticManager = HapticService.shared
    
    @State private var showLaunchView: Bool = true
    @State private var showTermsOfUse: Bool = false

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
                            hapticManager.impact(style: .light)
                            showLaunchView = false
                        }
                        .transition(.move(edge: .leading))
                    }
                }
                .zIndex(2)
                
                
                // Accept Terms of Use at the first launch
                ZStack {
                    if !vm.isTermsOfUseIsAccepted {
                        welcomeAtFirstLauch
                    }
                }
                .opacity(showLaunchView ? 0 : 1)
                .zIndex(1)
                
                
                if UIDevice.isiPad {
                    // iPad - NavigationSplitView
                    SidebarView()
                } else {
                    // iPhone - NavigationStack (portrait only)
                    NavigationStack{
//                        if let selectedCategory = vm.selectedCategory {
                        HomeView(selectedCategory: vm.selectedCategory)
//                        }
                    }
                }
            }
            .environmentObject(vm)
            .environmentObject(noticevm)
            .preferredColorScheme(vm.selectedTheme.colorScheme)
        }
    }
    
    private var welcomeAtFirstLauch: some View {
        ZStack {
            Color.mycolor.myBackground
                .ignoresSafeArea()
            NavigationStack {
                ScrollView {
                    VStack {
                        
                        Text("""
                    This application is created for educational purposes and helps organise links to learning SwiftUI materials.
                     
                    **It is importand to understand:**
                     
                    - The app stores only links to materials available from public sources.
                    - All content belongs to its respective authors.
                    - The app is free and intended for non-commercial use.
                    - Users are responsible for respecting copyright when using materials.
                     
                    **For each material, you have ability to save:**
                    
                    - Direct link to the original source.
                    - Author's name.
                    - Source (website, YouTube, etc.).
                    - Publication date (if known).
                                         
                    To use this application, you need to agree to **Terms of Use**.
                    """
                        )
                        .multilineTextAlignment(.leading)
                        .textFormater()
                        .padding(.horizontal)
                        
                        Button {
                            showTermsOfUse = true
                        } label: {
                            Text("Terms of Use")
                                .font(.title)
                        }
                        .tint(Color.mycolor.myBlue)
                        .padding()
                        .sheet(isPresented: $showTermsOfUse) {
                            NavigationStack {
                                TermsOfUse() {dismiss()}
                            }
                        }
                    } // VStack
                    .frame(maxWidth: 600)
                    .padding()
                } // ScrollView
                .navigationTitle("Affirmation")
                .navigationBarTitleDisplayMode(.inline)
            } // NavigationStack
        } // ZStack
    }

}

