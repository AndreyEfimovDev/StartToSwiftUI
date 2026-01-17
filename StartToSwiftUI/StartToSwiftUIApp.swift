//
//  StartToSwiftUIApp.swift
//  StartToSwiftUI App for study practicing
//
//  Created by Andrey Efimov on 25.08.2025.
//

import SwiftUI
import SwiftData
import Speech
import CloudKit

@main
struct StartToSwiftUIApp: App {
    
    @StateObject private var navigationCoordinator = AppCoordinator()
    @StateObject private var postsViewModel: PostsViewModel
    @StateObject private var noticeViewModel: NoticeViewModel

    private let hapticManager = HapticService.shared
    
    // MARK: - SwiftData Container with sync via iCloud
    let modelContainer: ModelContainer = {
        let schema = Schema([
            Post.self,
            Notice.self,
            AppSyncState.self
        ])
        
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        
        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            log("✅ SwiftData container created successfully", level: .info)
            return container
        } catch {
            fatalError("❌ Failed to create ModelContainer: \(error)")
        }
    }()
    
    init() {
        
        let context = modelContainer.mainContext
        _postsViewModel = StateObject(wrappedValue: PostsViewModel(modelContext: context))
        _noticeViewModel = StateObject(wrappedValue: NoticeViewModel(modelContext: context))

        configureNavigationBarAppearance()
        warmUpKeyboardAndSpeech()
    }
    
    var body: some Scene {
        WindowGroup {
            StartView()
                .modelContainer(modelContainer)
                .environmentObject(navigationCoordinator)
                .environmentObject(postsViewModel)
                .environmentObject(noticeViewModel)

        }
    }
    
    // MARK: - Configuration Methods
    
    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        
        let accentColor = UIColor(Color.mycolor.myAccent)
        appearance.largeTitleTextAttributes = [
            .foregroundColor: accentColor,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        appearance.titleTextAttributes = [
            .foregroundColor: accentColor,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactScrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = accentColor
        UITableView.appearance().backgroundColor = UIColor.clear
    }
    
    private func warmUpKeyboardAndSpeech() {
        // Warm Keyboard
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = scene.windows.first else { return }
            let textField = UITextField()
            window.addSubview(textField)
            textField.becomeFirstResponder()
            textField.resignFirstResponder()
            textField.removeFromSuperview()
            log("✅ Keyboard warmed up", level: .info)

            // Warm Speech Recognition
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                SFSpeechRecognizer.requestAuthorization { _ in
                    log("✅ Speech recognizer warmed up", level: .info)
                }
            }
        }
    }
}
