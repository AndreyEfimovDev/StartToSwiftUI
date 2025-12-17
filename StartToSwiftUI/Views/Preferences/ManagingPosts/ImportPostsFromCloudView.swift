//
//  CloudImportView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.10.2025.
//


import SwiftUI
import SwiftData

struct ImportPostsFromCloudView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var vm: PostsViewModel
    
    private let hapticManager = HapticService.shared
    
    @State private var isInProgress: Bool = false
    @State private var isLoaded: Bool = false
    
    @State private var postCount: Int = 0
    @State private var initialPostCount: Int = 0
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            VStack {
                textSection
                    .textFormater()
                
                Group {
                    CapsuleButtonView(
                        primaryTitle: "Confirm and Download",
                        secondaryTitle: "\(postCount) Posts Downloaded",
                        isToChange: isLoaded) {
                            isInProgress = true
                            initialPostCount = vm.allPosts.count
                            importFromCloud()
                        }
                        .disabled(isLoaded || isInProgress)
                        .padding(.top, 30)
                    
                    CapsuleButtonView(
                        primaryTitle: "Don't confirm",
                        textColorPrimary: Color.mycolor.myButtonTextRed,
                        buttonColorPrimary: Color.mycolor.myButtonBGRed) {
                            dismiss()
                        }
                        .opacity(isLoaded ? 0 : 1)
                        .disabled(isInProgress)
                }
                .padding(.horizontal, 50)
                
                Spacer()
                
            }
            if isInProgress {
                CustomProgressView()
            }
        }
        .padding(.horizontal, 30)
        .padding(.top, 30)
        .alert("Download Error", isPresented: $vm.showErrorMessageAlert) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        } message: {
            Text(vm.errorMessage ?? "Unknown error")
        }
        .navigationTitle("Import posts from cloud")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButtonView() { dismiss() }
            }
        }
    }
    
    
    // MARK: Subviews
    
    private var textSection: some View {
        VStack {
            Group {
                Text("""
                    The curated collection of links
                    to SwiftUI tutorials and articles are compiled by the developer from open sources for the purpose of learning the SwiftUI functionality.

                    """)
                
                Text("**IMPORTANT NOTICE:**")
                    .foregroundStyle(Color.mycolor.myRed)
                
                Text("""
                Clicking **Confirm and Download** constitutes your agreement to the following terms:
                
                """)
                
                Text("""
                1. The materials will be used solely for non-commercial educational purposes.
                2. All intellectual property rights in the materials are retained by the original authors.
                3. You will make every effort to access and reference the original source materials.
                """
                )
                .font(.subheadline)
                .multilineTextAlignment(.leading)
            }
        }
    }
    
    // MARK: - Import Methods
    
    private func importFromCloud() {
        
        // ВАРИАНТ 1: Загрузка DevData (для формирования JSON)
        // Раскомментируйте эту часть, когда нужно загрузить DevData
        
//        loadDevData()
       
        // ВАРИАНТ 2: Загрузка из облака (основной режим)
        // Закомментируйте эту часть, когда используете DevData
        
        loadFromCloudService()
        
    }
    
    /// ВАРИАНТ 1: Загрузка DevData для формирования JSON
    private func loadDevData() {
        print("🔵 Начинаем загрузку DevData...")
        
        Task { @MainActor in
            do {
                // Получаем существующие заголовки для фильтрации дубликатов
                let existingTitles = Set(vm.allPosts.map { $0.title })
                let existingIds = Set(vm.allPosts.map { $0.id })
                
                var addedCount = 0
                
                // Фильтруем и добавляем только уникальные посты
                for devPost in DevData.postsForCloud {
                    // Проверяем, что пост уникален
                    guard !existingTitles.contains(devPost.title) && !existingIds.contains(devPost.id) else {
                        print("⚠️ Пост '\(devPost.title)' уже существует, пропускаем")
                        continue
                    }
                    
                    // Создаём новый SwiftData Post
                    let newPost = Post(
                        id: devPost.id,
                        category: devPost.category,
                        title: devPost.title,
                        intro: devPost.intro,
                        author: devPost.author,
                        postType: devPost.postType,
                        urlString: devPost.urlString,
                        postPlatform: devPost.postPlatform,
                        postDate: devPost.postDate,
                        studyLevel: devPost.studyLevel,
                        progress: devPost.progress,
                        favoriteChoice: devPost.favoriteChoice,
                        postRating: devPost.postRating,
                        notes: devPost.notes,
                        origin: devPost.origin,
                        draft: devPost.draft,
                        date: devPost.date,
                        startedDateStamp: devPost.startedDateStamp,
                        studiedDateStamp: devPost.studiedDateStamp,
                        practicedDateStamp: devPost.practicedDateStamp
                    )
                    
                    modelContext.insert(newPost)
                    addedCount += 1
                }
                
                // Сохраняем в SwiftData
                try modelContext.save()
                print("✅ DevData: Загружено \(addedCount) постов из \(DevData.postsForCloud.count)")
                
                // 🌥️ Автоматическая синхронизация с iCloud!
                
                // Обновляем ViewModel
                vm.loadPostsFromSwiftData()
                
                // Обновляем счётчик
                postCount = vm.allPosts.count - initialPostCount
                
                // Завершаем
                isInProgress = false
                isLoaded = true
                hapticManager.notification(type: .success)
                
                // Закрываем через 1.5 секунды
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                dismiss()
                
            } catch {
                print("❌ Ошибка загрузки DevData: \(error)")
                vm.errorMessage = "Failed to load DevData: \(error.localizedDescription)"
                vm.showErrorMessageAlert = true
                isInProgress = false
                hapticManager.notification(type: .error)
            }
        }
    }
    
    /// ВАРИАНТ 2: Загрузка из облачного сервиса
    private func loadFromCloudService() {
        print("☁️ Начинаем загрузку из облака...")
        
        vm.importPostsFromCloud() { [self] in
            Task { @MainActor in
                isInProgress = false
                
                if !vm.showErrorMessageAlert {
                    isLoaded = true
                    
                    // Обновляем счётчик загруженных постов
                    postCount = vm.allPosts.count - initialPostCount
                    
                    // Отмечаем первый импорт как завершённый
                    if !vm.isFirstImportPostsCompleted {
                        vm.isFirstImportPostsCompleted = true
                    }
                    
                    hapticManager.notification(type: .success)
                    
                    // Закрываем через 1.5 секунды
                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                    dismiss()
                } else {
                    hapticManager.notification(type: .error)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ImportPostsFromCloudView()
            .environmentObject(PostsViewModel(
                modelContext: ModelContext(
                    try! ModelContainer(for: Post.self, Notice.self)
                )
            ))
    }
    .modelContainer(for: [Post.self, Notice.self], inMemory: true)
}
