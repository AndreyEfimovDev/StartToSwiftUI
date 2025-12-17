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
    @State private var vm: PostsViewModel?
    @State private var noticevm: NoticeViewModel?
    @State private var showLaunchView: Bool = true
    @State private var showTermsOfUse: Bool = false
    @State private var areViewModelsInitialized = false // <- Новый флаг
    
    @AppStorage("isTermsOfUseAccepted") var isTermsOfUseAccepted: Bool = false
    
    private let hapticManager = HapticService.shared
    
    var body: some View {
        ZStack {
            if showLaunchView {
                LaunchView() {
                    initializeViewModels() // <- Инициализируем после LaunchView
                    hapticManager.impact(style: .light)
                    showLaunchView = false
                }
                .transition(.move(edge: .leading))
            } else if areViewModelsInitialized, let vm = vm, let noticevm = noticevm {
                mainContent(vm: vm, noticevm: noticevm)
            } else {
                ProgressView("Initializing...")
                    .onAppear {
                        initializeViewModels()
                    }
            }
        }
        .preferredColorScheme(vm?.selectedTheme.colorScheme)
        .task {
            // Загружаем статические посты при первом запуске
            await loadStaticPostsIfNeeded()
        }
    }
    
    @ViewBuilder
    private func mainContent(vm: PostsViewModel, noticevm: NoticeViewModel) -> some View {
        if !isTermsOfUseAccepted {
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
                                TermsOfUse(isTermsOfUseAccepted: $isTermsOfUseAccepted)
                                .environmentObject(vm!)
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
        areViewModelsInitialized = true // <- Устанавливаем флаг
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
    NavigationStack {
        ContentViewWrapper()
            .modelContainer(for: [Post.self, Notice.self], inMemory: true)
    }
}
