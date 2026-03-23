//
//  StartToSwiftUIApp.swift
//  StartToSwiftUI App for study practicing
//
//  Created by Andrey Efimov on 25.08.2025.
//

import SwiftUI
import SwiftData
import CloudKit
import Firebase
import FirebaseAnalytics
import FirebaseMessaging

@main
struct StartToSwiftUIApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // MARK: - Dependencies
    @StateObject private var postsViewModel: PostsViewModel
    @StateObject private var noticesViewModel: NoticesViewModel
    @StateObject private var snippetsViewModel: SnippetsViewModel
    @StateObject private var coordinator = AppCoordinator()

    private let appStateManager: AppSyncStateManager
    private let hapticManager = HapticManager.shared
    
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
        let stateManager = AppSyncStateManager(modelContext: context)
        
        self.appStateManager = stateManager
        
        // Initialisation of AppState — once at startup
        /* 
        Ensure AppState exists (creates with appFirstLaunchDate if first launch).
        Search for AppSyncState in SwiftData - it guarantees the existence of the AppState:
        - The first launch will not find it, it will create a new one with appFirstLaunchDate = Date() and save it to the database.
        - Restart — it will find an existing one and return it.
        */
        _ = appStateManager.getOrCreateAppState()

        _postsViewModel = StateObject(wrappedValue: PostsViewModel(
            modelContext: context,
            appStateManager: stateManager
        ))
        _noticesViewModel = StateObject(wrappedValue: NoticesViewModel(
            modelContext: context,
            appStateManager: stateManager
        ))
        _snippetsViewModel = StateObject(wrappedValue: SnippetsViewModel(
            appStateManager: stateManager
        ))

#if DEBUG
        Analytics.setAnalyticsCollectionEnabled(false)
#endif
        configureNavigationBarAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            StartView()
                .modelContainer(modelContainer)
                .environmentObject(coordinator)
                .environmentObject(postsViewModel)
                .environmentObject(noticesViewModel)
                .environmentObject(snippetsViewModel)
                .task {
                    postsViewModel.start()
                    noticesViewModel.start()
                    clearBadge()
                }
                .onReceive(NotificationCenter.default.publisher(
                    for: UIApplication.willEnterForegroundNotification)
                ) { _ in
                    clearBadge()
                }
        }
    }
    
    private func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
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
}

// MARK: - Connect Firebase
class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // FCM delegate
        Messaging.messaging().delegate = self
        
        // Request push notification permission
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            log("🔔 Push notification permission: \(granted)", level: .info)
        }
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        log("🔔 APNs token received", level: .info)
    }

    func application(_ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error) {
        log("🔔 APNs registration failed: \(error)", level: .error)
    }
    
//    func applicationDidBecomeActive(_ application: UIApplication) {}
//    
//    func applicationWillResignActive(_ application: UIApplication) {}
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Show notifications when the app is open
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
    
    // Notification tap processing
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        log("🔔 Push tapped: \(userInfo)", level: .info)
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler()
    }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
    
    // FCM token has been updated
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        log("🔔 FCM token: \(fcmToken ?? "nil")", level: .info)
        
        Messaging.messaging().subscribe(toTopic: "all") { error in
                log("🔔 Subscribed to topic 'all': \(String(describing: error))", level: .info)
            }
    }
}
