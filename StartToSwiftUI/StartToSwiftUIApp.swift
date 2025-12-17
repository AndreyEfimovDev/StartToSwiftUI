//
//  StartToSwiftUIApp.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.08.2025.
//
// v01.14 StartToSwiftUI_Github_GitKraken

import SwiftUI
import SwiftData
import Speech

@main
struct StartToSwiftUIApp: App {
    
    @Environment(\.dismiss) private var dismiss
    
    private let hapticManager = HapticService.shared
    
    @State private var showLaunchView: Bool = true
    @State private var showTermsOfUse: Bool = false
    
    // MARK: - SwiftData Container
    
    /// ModelContainer с поддержкой iCloud синхронизации
    let modelContainer: ModelContainer = {
        let schema = Schema([Post.self, Notice.self])
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
            ContentViewWrapper()
        }
        .modelContainer(modelContainer)
    }
}

// MARK: - Content View Wrapper

/// Wrapper для инициализации ViewModels с ModelContext
struct ContentViewWrapper: View {
    
    @Environment(\.modelContext) private var modelContext
    @AppStorage("isTermsOfUseAccepted") var isTermsOfUseIsAccepted: Bool = false
    @AppStorage("selectedTheme") var selectedTheme: Theme = .system
    
    @State private var vm: PostsViewModel?
    @State private var noticevm: NoticeViewModel?
    @State private var showLaunchView: Bool = true
    @State private var showTermsOfUse: Bool = false
    
    private let hapticManager = HapticService.shared
    
    var body: some View {
        ZStack {
            if showLaunchView {
                LaunchView() {
                    hapticManager.impact(style: .light)
                    showLaunchView = false
                }
                .transition(.move(edge: .leading))
            } else if let vm = vm, let noticevm = noticevm {
                mainContent(vm: vm, noticevm: noticevm)
            } else {
                ProgressView("Initializing...")
                    .onAppear {
                        initializeViewModels()
                    }
            }
        }
        .preferredColorScheme(selectedTheme.colorScheme)
        .task {
            // Загружаем статические посты при первом запуске
            await loadStaticPostsIfNeeded()
        }
    }
    
    @ViewBuilder
    private func mainContent(vm: PostsViewModel, noticevm: NoticeViewModel) -> some View {
        if !isTermsOfUseIsAccepted {
            welcomeAtFirstLaunch
        } else if UIDevice.isiPad {
            // iPad - NavigationSplitView
            SidebarView()
                .environmentObject(vm)
                .environmentObject(noticevm)
        } else {
            // iPhone - NavigationStack (portrait only)
            NavigationStack {
                HomeView(selectedCategory: vm.selectedCategory)
            }
            .environmentObject(vm)
            .environmentObject(noticevm)
        }
    }
    
    private var welcomeAtFirstLaunch: some View {
        ZStack {
            Color.mycolor.myBackground
                .ignoresSafeArea()
            NavigationStack {
                ScrollView {
                    VStack {
                        Text("""
                    This application is created for educational purposes and helps organise links to learning SwiftUI materials.
                     
                    **It is important to understand:**
                     
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
                        .padding(.top)
                        .padding(.horizontal)
                        
                        Button {
                            showTermsOfUse = true
                        } label: {
                            Text("Terms of Use")
                                .font(.title)
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color.mycolor.myBlue, lineWidth: 1)
                                )
                        }
                        .tint(Color.mycolor.myBlue)
                        .padding()
                        .fullScreenCover(isPresented: $showTermsOfUse) {
                            NavigationStack {
                                TermsOfUse() {
                                    // Закрываем через Environment dismiss
                                }
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
    
    // MARK: - Private Methods
    
    private func initializeViewModels() {
        vm = PostsViewModel(modelContext: modelContext)
        noticevm = NoticeViewModel(modelContext: modelContext)
        print("✅ ViewModels инициализированы")
    }
    
    /// Загружает статические посты при первом запуске
    @MainActor
    private func loadStaticPostsIfNeeded() async {
        // Проверяем, есть ли уже посты в базе
        let descriptor = FetchDescriptor<Post>()
        let existingPostsCount = (try? modelContext.fetchCount(descriptor)) ?? 0
        
        guard existingPostsCount == 0 else {
            print("✅ Посты уже загружены (\(existingPostsCount) шт.)")
            return
        }
        
        print("📦 Загружаем статические посты при первом запуске...")
        
        // Конвертируем статические посты из старого формата в SwiftData
        for staticPost in StaticPost.staticPosts {
            let newPost = Post(
                id: staticPost.id,
                category: staticPost.category,
                title: staticPost.title,
                intro: staticPost.intro,
                author: staticPost.author,
                postType: staticPost.postType,
                urlString: staticPost.urlString,
                postPlatform: staticPost.postPlatform,
                postDate: staticPost.postDate,
                studyLevel: staticPost.studyLevel,
                progress: staticPost.progress,
                favoriteChoice: staticPost.favoriteChoice,
                postRating: staticPost.postRating,
                notes: staticPost.notes,
                origin: staticPost.origin,
                draft: staticPost.draft,
                date: staticPost.date,
                startedDateStamp: staticPost.startedDateStamp,
                studiedDateStamp: staticPost.studiedDateStamp,
                practicedDateStamp: staticPost.practicedDateStamp
            )
            modelContext.insert(newPost)
        }
        
        do {
            try modelContext.save()
            print("✅ Загружено \(StaticPost.staticPosts.count) статических постов")
        } catch {
            print("❌ Ошибка загрузки статических постов: \(error)")
        }
    }
}

#Preview {
    ContentViewWrapper()
        .modelContainer(for: [Post.self, Notice.self], inMemory: true)
}


//import SwiftUI
//import Speech
//
//
//@main
//struct StartToSwiftUIApp: App {
//    
//    @Environment(\.dismiss) private var dismiss
//    
//    @StateObject private var vm = PostsViewModel()
//    @StateObject private var noticevm = NoticeViewModel()
//    
//    private let hapticManager = HapticService.shared
//    
//    @State private var showLaunchView: Bool = true
//    @State private var showTermsOfUse: Bool = false
//    
//    init() {
//        
//        // Set a custom colour titles for NavigationStack and the magnifying class in the search bar
//        let appearance = UINavigationBarAppearance()
//        appearance.configureWithTransparentBackground() // it also removes a dividing line
//        
//        // Explicitly setting the background colour
//        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
//        
//        // Setting colour for titles using NSAttributedString
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
//        // Apply to all possible states
//        UINavigationBar.appearance().standardAppearance = appearance
//        UINavigationBar.appearance().compactAppearance = appearance
//        UINavigationBar.appearance().scrollEdgeAppearance = appearance
//        UINavigationBar.appearance().compactScrollEdgeAppearance = appearance
//        
//        // Buttons colour
//        UINavigationBar.appearance().tintColor = accentColor
//        
//        // For UITableView
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
//            
//        }
//    } // init()
//    
//    var body: some Scene {
//        WindowGroup {
//            ZStack{
//                if showLaunchView {
//                    LaunchView() {
//                        hapticManager.impact(style: .light)
//                        showLaunchView = false
//                    }
//                    .transition(.move(edge: .leading))
//                } else if !vm.isTermsOfUseIsAccepted {
//                    //                    NavigationStack {
//                    welcomeAtFirstLauch
//                    //                    }
//                } else if UIDevice.isiPad {
//                    // iPad - NavigationSplitView
//                    SidebarView()
//                } else {
//                    // iPhone - NavigationStack (portrait only)
//                    NavigationStack{
//                        //                        if let selectedCategory = vm.selectedCategory {
//                        HomeView(selectedCategory: vm.selectedCategory)
//                        //                        }
//                    }
//                }
//            }
//            .environmentObject(vm)
//            .environmentObject(noticevm)
//            .preferredColorScheme(vm.selectedTheme.colorScheme)
//            }
//    }
//    
//    private var welcomeAtFirstLauch: some View {
//        ZStack {
//            Color.mycolor.myBackground
//                .ignoresSafeArea()
//            NavigationStack {
//                ScrollView {
//                    VStack {
//                        Text("""
//                    This application is created for educational purposes and helps organise links to learning SwiftUI materials.
//                     
//                    **It is importand to understand:**
//                     
//                    - The app stores only links to materials available from public sources.
//                    - All content belongs to its respective authors.
//                    - The app is free and intended for non-commercial use.
//                    - Users are responsible for respecting copyright when using materials.
//                     
//                    **For each material, you have ability to save:**
//                    
//                    - Direct link to the original source.
//                    - Author's name.
//                    - Source (website, YouTube, etc.).
//                    - Publication date (if known).
//                                         
//                    To use this application, you need to agree to **Terms of Use**.
//                    """
//                        )
//                        .multilineTextAlignment(.leading)
//                        .textFormater()
//                        .padding(.top)
//                        .padding(.horizontal)
//                        
//                        Button {
//                            showTermsOfUse = true
//                        } label: {
//                            Text("Terms of Use")
//                                .font(.title)
//                                .padding()
//                                .background(.ultraThinMaterial)
//                                .clipShape(Capsule())
//                                .overlay(
//                                    Capsule()
//                                        .stroke(Color.mycolor.myBlue, lineWidth: 1)
//                                )
//                        }
//                        .tint(Color.mycolor.myBlue)
//                        .padding()
//                        .fullScreenCover(isPresented: $showTermsOfUse) {
//                            NavigationStack {
//                                TermsOfUse() { dismiss() }
//                            }
//                        }
//                    } // VStack
//                    .frame(maxWidth: 600)
//                    .padding()
//                } // ScrollView
//                .navigationTitle("Affirmation")
//                .navigationBarTitleDisplayMode(.inline)
//            } // NavigationStack
//        } // ZStack
//    }
//    
//}

