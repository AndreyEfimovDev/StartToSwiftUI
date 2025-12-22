//
//  ContentViewWrapper.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 17.12.2025.
//

import SwiftUI
import SwiftData


struct ContentViewWrapper: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        ContentViewWithViewModels(modelContext: modelContext)
    }
}


struct ContentViewWithViewModels: View {
    
    @Environment(\.modelContext) private var modelContext  // ✅ Добавили
    
    @StateObject private var vm: PostsViewModel
    @StateObject private var noticevm: NoticeViewModel
    
    @State private var showLaunchView: Bool = true
    @State private var showTermsOfUse: Bool = false
    @State private var showTermsButton = false // Контролирует анимацию появления кнопки Terms of Use
    @State private var isLoadingData = true // Показывает ProgressView во время загрузки данных

    @AppStorage("isTermsOfUseAccepted") var isTermsOfUseAccepted: Bool = false
    
    init(modelContext: ModelContext) {
            _vm = StateObject(wrappedValue: PostsViewModel(modelContext: modelContext))
            _noticevm = StateObject(wrappedValue: NoticeViewModel(modelContext: modelContext))
        }

    var body: some View {
        ZStack {
//            if !isTermsOfUseAccepted {
//                welcomeAtFirstLaunch
//            } else
            if showLaunchView {
                LaunchView() {
                    showLaunchView = false
                }
                .transition(.move(edge: .leading))
            } else if isLoadingData {
                // 🔥 Показываем ProgressView пока идет загрузка
                ProgressView("...loading data...")
                    .controlSize(.large)
            } else {
                // 🔥 Когда загрузка завершена - показываем контент
                mainContent
            }
            
        }
        .preferredColorScheme(vm.selectedTheme.colorScheme)
//        .onAppear {
////            print("🔍 AppStorage hasLoadedInitialData: \(vm.hasLoadedInitialData)")
////            print("🔍 Всего постов в VM: \(vm.allPosts.count)")
////            print("🔍 NoticeVM уведомлений: \(noticevm.notices.count)")
//        }
        .task {
            // 🧹 ШАГ 0: Очистка дубликатов AppState из прошлых запусков
            let appStateManager = AppStateManager(modelContext: modelContext)
            appStateManager.cleanupDuplicateAppStates()
            
            // Загружаем посты
            print("🔥🔥 Загружаем посты из SwiftData")
            vm.loadPostsFromSwiftData()
            
            // 🔥🔥Если нужно, загружаем статические посты при первом запуске"
            print("🔥🔥 Если нужно, загружаем статические посты при первом запуске")
            await vm.loadStaticPostsIfNeeded()
            
            // 🔥🔥 Импортируем уведомления (включает задержку и удаление дубликатов)
            print("🔥🔥 Импортируем уведомления (включает задержку и удаление дубликатов)")
            await noticevm.importNoticesFromCloud()
            
            isLoadingData = false
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {

        if UIDevice.isiPad {
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
                        
                        if showTermsButton {
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
                                    TermsOfUse(isTermsOfUseAccepted: $isTermsOfUseAccepted)
                                    .environmentObject(vm)
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
            .onAppear {
                // 🔥 Задержка 8 секунд
                DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                    withAnimation(.easeInOut(duration: 3)) {
                        showTermsButton = true
                    }
                }
            }
        } // ZStack
    }
    
}


#Preview("Simple Test") {
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    NavigationStack {
        ContentViewWrapper()
            .environment(\.modelContext, container.mainContext)
            .modelContainer(container)
    }
}
