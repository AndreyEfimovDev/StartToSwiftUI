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
import FirebaseCrashlytics
import FirebaseMessaging

@main
struct StartToSwiftUIApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    /// Результат сборки composition root: либо готовые зависимости и
    /// контейнер, либо неудача создания `ModelContainer` — раньше в этом
    /// случае был `fatalError`, теперь показываем `DatabaseErrorView`.
    private enum Startup {
        case ready(container: ModelContainer, dependencies: AppDependencies)
        case failed
    }
    private let startup: Startup

    init() {
        // Должен отработать раньше первого обращения к любому Firebase SDK —
        // AppDependencies.make() ниже строит FBPostsManager/FBNoticesManager,
        // которые обращаются к Firestore.firestore() уже в своём init().
        // AppDelegate.application(didFinishLaunchingWithOptions:) выполняется
        // позже (после App.init()), так что полагаться на конфигурацию там
        // нельзя.
        FirebaseApp.configure()

        let schema = Schema([
            Post.self,
            Notice.self,
            AppSyncState.self
        ])

#if DEBUG
        Analytics.setAnalyticsCollectionEnabled(false)
        
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none  // ← without CloudKit in debug
        )
#else
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
#endif

        if let container = try? ModelContainer(for: schema, configurations: [config]) {
            log("SwiftData container created successfully", level: .info)
            let dependencies = AppDependencies.make(modelContext: container.mainContext)
            startup = .ready(container: container, dependencies: dependencies)
        } else {
            log("Failed to create ModelContainer", level: .error)
            startup = .failed
        }
        
        configureNavigationBarAppearance()
    }

    var body: some Scene {
        WindowGroup {
            switch startup {
            case .ready(let container, let dependencies):
                StartView(dependencies: dependencies)
                    .modelContainer(container)
                    .task {
                        dependencies.postsViewModel.start()
                        dependencies.noticesViewModel.start()
                        clearBadge()
                    }
                    .onReceive(NotificationCenter.default.publisher(
                        for: UIApplication.willEnterForegroundNotification)
                    ) { _ in
                        clearBadge()
                    }
            case .failed:
                DatabaseErrorView()
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
        // FirebaseApp.configure() вызывается в StartToSwiftUIApp.init() —
        // раньше, чем сюда доходит управление (App.init() выполняется до
        // didFinishLaunchingWithOptions), иначе AppDependencies.make() внутри
        // App.init() падает при первом же обращении к Firestore.

#if DEBUG
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(false)
#else
        // FCM delegate
        Messaging.messaging().delegate = self

        // Request push notification permission
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            log("🔔 Push notification permission: \(granted)", level: .info)
        }
        application.registerForRemoteNotifications()
#endif
        
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
