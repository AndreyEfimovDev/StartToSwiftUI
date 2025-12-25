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
    
    @StateObject private var navigationCoordinator = NavigationCoordinator()
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
            print("✅ SwiftData контейнер создан успешно")
            return container
        } catch {
            fatalError("❌ Не удалось создать ModelContainer: \(error)")
        }
    }()
    
    init() {
        configureNavigationBarAppearance()
        warmUpKeyboardAndSpeech()
    }
    
    var body: some Scene {
        WindowGroup {
            StartView(modelContext: modelContainer.mainContext)
                .modelContainer(modelContainer)
                .environmentObject(navigationCoordinator)
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
            print("✅ Keyboard warmed up")
            
            // Warm Speech Recognition
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                SFSpeechRecognizer.requestAuthorization { _ in
                    print("✅ Speech recognizer warmed up")
                }
            }
        }
    }
}

//import SwiftUI
//import SwiftData
//import Speech
//import CloudKit
//
//@main
//struct StartToSwiftUIApp: App {
//    
//    @Environment(\.dismiss) private var dismiss
//    @StateObject private var navigationCoordinator = NavigationCoordinator()
//    
//    private let hapticManager = HapticService.shared
//        
//    // MARK: - SwiftData Container with sync via iCloud
//    let modelContainer: ModelContainer = {
//        
//        let schema = Schema([
//            Post.self,
//            Notice.self,
//            AppSyncState.self
//        ])
//        
//        let config = ModelConfiguration(
//            schema: schema,
//            isStoredInMemoryOnly: false,
//            cloudKitDatabase: .automatic //
//        )
//        
//        do {
//            let container = try ModelContainer(for: schema, configurations: [config])
//            print("✅ SwiftData контейнер создан успешно")
//            return container
//        } catch {
//            fatalError("❌ Не удалось создать ModelContainer: \(error)")
//        }
//    }()
//    
//    init() {
//        // Set custom colour for NavigationStack titles
//        let appearance = UINavigationBarAppearance()
//        appearance.configureWithTransparentBackground() // it also removes a dividing line
//        
//        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
//        
//        let accentColor = UIColor(Color.mycolor.myAccent)
//        appearance.largeTitleTextAttributes = [
//            .foregroundColor: accentColor,
//            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
//        ]
//        appearance.titleTextAttributes = [
//            .foregroundColor: accentColor,
//            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
//        ]
//        
//        UINavigationBar.appearance().standardAppearance = appearance
//        UINavigationBar.appearance().compactAppearance = appearance
//        UINavigationBar.appearance().scrollEdgeAppearance = appearance
//        UINavigationBar.appearance().compactScrollEdgeAppearance = appearance
//        UINavigationBar.appearance().tintColor = accentColor
//        UITableView.appearance().backgroundColor = UIColor.clear
//        
//        // Warm Keyboard
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//                  let window = scene.windows.first else { return }
//            let textField = UITextField()
//            window.addSubview(textField)
//            textField.becomeFirstResponder()
//            textField.resignFirstResponder()
//            textField.removeFromSuperview()
//            print("Keyboard warmed up")
//            
//            // Warm Speech Recognition
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                SFSpeechRecognizer.requestAuthorization { _ in
//                    print("Speech recognizer warmed up")
//                }
//            }
//        }
//    }
//    
//    var body: some Scene {
//        WindowGroup {
//            ContentViewWrapper()
//                .modelContainer(modelContainer)
//                .environmentObject(navigationCoordinator)
//        }
//    }
//}

//
//#Preview("Full App Preview") {
//    let container = try! ModelContainer(
//        for: Post.self, Notice.self, AppSyncState.self,
//        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
//    )
//
//    let context = container.mainContext
//    
//    for notice in PreviewData.sampleNotices {
//        context.insert(notice)
//    }
//    
//    for post in PreviewData.samplePosts {
//        context.insert(post)
//    }
//    
//    do {
//        try context.save()
//        print("✅ Preview: Данные загружены в SwiftData")
//    } catch {
//        print("❌ Preview: Ошибка сохранения: \(error)")
//    }
//    
//    let vm = PostsViewModel(modelContext: context)
//    let noticevm = NoticeViewModel(modelContext: context)
//    
//    return ContentViewWrapper()
//        .environment(\.modelContext, context)
//        .environmentObject(vm)
//        .environmentObject(noticevm)
//        .modelContainer(container)
//        .onAppear {
//            print("📱 Preview запущен с \(PreviewData.samplePosts.count) постами")
//        }
//}
