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
    
    @StateObject private var postsViewModel: PostsViewModel
    @StateObject private var noticeViewModel: NoticeViewModel
    @StateObject private var coordinator = AppCoordinator()
    @Environment(\.scenePhase) private var scenePhase

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
        
        // Sync dates from SwiftData to UserDefaults
        // so BackgroundRefreshService can access them without ModelContext
        if let appStateManager = postsViewModel.appStateManager {
            if let launchDate = appStateManager.getAppFirstLaunchDate() {
                UserDefaults.standard.set(launchDate, forKey: "appFirstLaunchDate")
            }
            if let noticeDate = appStateManager.getLastNoticeDate() {
                UserDefaults.standard.set(noticeDate, forKey: "lastNoticeDate")
            }
        }


        // Register background refresh task
        BackgroundRefreshService.shared.registerBackgroundTask()
    }
    
    var body: some Scene {
        WindowGroup {
            StartView()
                .modelContainer(modelContainer)
                .environmentObject(coordinator)
                .environmentObject(postsViewModel)
                .environmentObject(noticeViewModel)
                .onAppear {
                    // Request notification permission on first launch
                    LocalNotificationService.shared.requestPermission()
                }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background {
                /* Update cached lastNoticeDate before scheduling,because
                   while the application was running,
                   importNoticesFromCloud() could update this date in SwiftData
                 */
                if let noticeDate = postsViewModel.appStateManager?.getLastNoticeDate() {
                    UserDefaults.standard.set(noticeDate, forKey: "lastNoticeDate")
                }
                BackgroundRefreshService.shared.scheduleBackgroundRefresh()
                log("🔄 App moved to background, refresh scheduled", level: .info)
            }
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
