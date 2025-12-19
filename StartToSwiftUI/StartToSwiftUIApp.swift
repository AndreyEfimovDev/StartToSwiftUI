//
//  StartToSwiftUIApp.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.08.2025.
//


import SwiftUI
import SwiftData
import Speech
import CloudKit

@main
struct StartToSwiftUIApp: App {
    
    @Environment(\.dismiss) private var dismiss
    
    private let hapticManager = HapticService.shared
        
    // MARK: - SwiftData Container
    
    /// ModelContainer с поддержкой iCloud синхронизации
    let modelContainer: ModelContainer = {
        
        let schema = Schema([
            Post.self,
            Notice.self,
            AppState.self
        ])
        
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic // 🌥️ iCloud синхронизация
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
        
        // Set custom colour for NavigationStack titles
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground() // it also removes a dividing line
        
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
            ContentViewWrapper()
//                .onAppear {
                    // ОТЛАДКА: Проверяем статус CloudKit (опционально)
//                    checkCloudKitSetup()
//                    checkRuntimeEntitlements()
//                    quickCloudKitCheck()
//                }
        }
        .modelContainer(modelContainer)
    }
}


#Preview("Full App Preview") {
    // 1. Создаем in-memory контейнер
//    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    // 2. Получаем контекст
    let context = container.mainContext
    
    // 3. Вставляем ваши PreviewData в SwiftData
    for notice in PreviewData.sampleNotices {
        context.insert(notice)
    }
    
    for post in PreviewData.samplePosts {
        context.insert(post)
    }
    
    // 4. Пробуем сохранить
    do {
        try context.save()
        print("✅ Preview: Данные загружены в SwiftData")
    } catch {
        print("❌ Preview: Ошибка сохранения: \(error)")
    }
    
    // 5. Создаем ViewModels
    let vm = PostsViewModel(modelContext: context)
    let noticevm = NoticeViewModel(modelContext: context)
    
    // 7. Возвращаем ContentViewWrapper со всеми зависимостями
    return ContentViewWrapper()
        .environment(\.modelContext, context) // Ключевой момент!
        .environmentObject(vm)
        .environmentObject(noticevm)
        .modelContainer(container)
        .onAppear {
            print("📱 Preview запущен с \(PreviewData.samplePosts.count) постами")
        }
}
