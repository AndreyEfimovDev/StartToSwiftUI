//
//  PreferencesView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 09.09.2025.
//

import SwiftUI
import SwiftData

struct PreferencesView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var vm: PostsViewModel
    @EnvironmentObject private var noticevm: NoticeViewModel
    @EnvironmentObject private var coordinator: NavigationCoordinator

    
    let iconWidth: CGFloat = 18
    
    private var postsCount: Int {
        vm.allPosts.count
    }
    
    private var draftsCount: Int {
        let postDrafts = vm.allPosts.filter { $0.draft == true }
        return postDrafts.count
    }
    
    private var newNoticesCount: Int {
        noticevm.notices.filter { $0.isRead == false }.count
    }
    
    var body: some View {
            Form {
                
                Section(header: Text("Debug Navigation")) {
                    // Простая тестовая кнопка
                    Button("🚀 Test Push to StudyProgress") {
                        print("=== DEBUG: PreferencesView button tapped ===")
                        print("Path count before: \(coordinator.path.count)")
                        
                        // Пробуем самый простой переход
                        coordinator.push(.studyProgress)
                        
                        print("Path count after push: \(coordinator.path.count)")
                    }
                    .customListRowStyle(iconName: "testtube.2", iconWidth: 18)
                    
                    // Кнопка для проверки текущего состояния
                    Button("📊 Print Current State") {
                        print("=== PreferencesView State ===")
                        print("Coordinator instance: \(Unmanaged.passUnretained(coordinator).toOpaque())")
                        print("Path count: \(coordinator.path.count)")
                        
                        // Попробуем получить hashValue path для проверки
                        let mirror = Mirror(reflecting: coordinator.path)
                        print("Path type: \(type(of: coordinator.path))")
                        print("Path mirror children count: \(mirror.children.count)")
                    }
                }
                
                
                Section(header: sectionHeader("Appearance")) {
                    themeAppearence
                }
                
                Section(header: sectionHeader("Notifications")) {
                    noticeMessages
                    notificationToggle
                    soundNotificationToggle
                }
                
                //                if UIDevice.isiPhone {
                //                    Section(header: sectionHeader("Selected category")) {
                //                        selectedCategory
                //                    }
                //                }
                
                
                Section(header: sectionHeader("Achievements")) {
                    Button("Check progress") {
                        // ✅ Используем координатор
                        coordinator.push(.studyProgress)
                    }
                    .customListRowStyle(iconName: "hare", iconWidth: iconWidth)
                    
                    //                    NavigationLink("Check progress") {
                    //                        StudyProgressView()
                    //                    }
                    //                    .customListRowStyle(
                    //                        iconName: "hare",
                    //                        iconWidth: iconWidth
                    //                    )
                } // gauge.open.with.lines.needle.67percent.and.arrowtriangle
                
                Section(header: sectionHeader("Manage materials (\(postsCount))")) {
                    loadStaticPostsToggle
                    postDrafts
                    checkForPostsUpdate
                    importFromCloud
                    shareBackup
                    restoreBackup
                    erasePosts
                }
                
                
                Section(header: sectionHeader("Сommunication")){
                    acknowledgements
                    aboutApplication
                    legalInformation
                    contactDeveloperButton
                }
            } // Form
            .foregroundStyle(Color.mycolor.myAccent)
            .listSectionSpacing(0)
            .navigationTitle("Preferences")
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(StackNavigationViewStyle())
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if UIDevice.isiPad {
                        BackButtonView(iconName: "xmark") {
                            print("📱 PreferencesView: Back button tapped")
                            coordinator.pop()
                        }
                    } else {
                        BackButtonView() {
                            print("📱 PreferencesView: Back button tapped")
                            coordinator.pop()
                        }
                    }
                }
            }
            .onAppear {
                print("=== PreferencesView APPEARED ===")
                print("✅ Coordinator IS available")
                print("Path count on appear: \(coordinator.path.count)")
                
                // Простой способ проверить, что координатор работает
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    print("Path count after 0.5s: \(coordinator.path.count)")
                }
                
            }
            .preferredColorScheme(vm.selectedTheme.colorScheme)
       
    }
    
    // MARK: - Subviews
    
    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .foregroundStyle(Color.mycolor.myAccent)
    }
    
    private var selectedCategory: some View {
        Group {
            if let list = vm.allCategories {
                CustomOneCapsulesLineSegmentedPicker(
                    selection: $vm.selectedCategory,
                    allItems: list,
                    titleForCase: { $0 },
                    selectedTextColor: Color.mycolor.myBackground,
                    unselectedTextColor: Color.mycolor.myAccent,
                    selectedBackground: Color.mycolor.myButtonBGBlue,
                    unselectedBackground: .clear,
                    showNilOption: true,
                    nilTitle: "All"
                )
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            }
        }
    }
    
    private var themeAppearence: some View {
        UnderlineSermentedPickerNotOptional(
            selection: $vm.selectedTheme,
            allItems: Theme.allCases,
            titleForCase: { $0.displayName },
            selectedFont: .footnote
        )
    }
    
    private var notificationToggle: some View {
        HStack {
            Image(systemName: noticevm.isNotificationOn ? "bell" : "bell.slash")
                .frame(width: iconWidth)
                .foregroundStyle(Color.mycolor.myBlue)
            Toggle(noticevm.isNotificationOn ? "On" : "Off", isOn: $noticevm.isNotificationOn)
                .tint(Color.mycolor.myBlue)
        }
    }
    
    private var soundNotificationToggle: some View {
        HStack {
            Image(systemName: noticevm.isSoundNotificationOn ? "speaker.wave.2" : "speaker.slash")
                .frame(width: iconWidth)
                .foregroundStyle(Color.mycolor.myBlue)
            Toggle(noticevm.isSoundNotificationOn ? "Sound On" : "Sound Off", isOn: $noticevm.isSoundNotificationOn)
                .tint(Color.mycolor.myBlue)
        }
    }
    
    private var loadStaticPostsToggle: some View {
        
        HStack {
            Image(systemName: "arrow.2.squarepath")
                .frame(width: iconWidth)
                .foregroundStyle(Color.mycolor.myBlue)
            Toggle("Load static posts", isOn: $vm.shouldLoadStaticPosts)
                .tint(Color.mycolor.myBlue)
        }
    }
    
    private var noticeMessages: some View {
//        NavigationLink("Messages (\(newNoticesCount)/\(noticevm.notices.count))") {
//            NoticesView()
//        }
        Button("Messages (\(newNoticesCount)/\(noticevm.notices.count))") {
            coordinator.push(.notices) // ✅ Используем координатор
        }
        .customListRowStyle(
            iconName: newNoticesCount == 0 ? "message" : "message.badge",
            iconWidth: iconWidth
        )
    }
    
    private var postDrafts: some View {
        Group {
            if !vm.allPosts.filter({ $0.draft == true }).isEmpty {
//                NavigationLink("Post drafts (\(draftsCount))") {
//                    PostDraftsView()
//                }
                Button("Post drafts (\(draftsCount))") {
                    coordinator.push(.postDrafts) // ✅ Используем координатор
                }
                .customListRowStyle(
                    iconName: "square.stack.3d.up",
                    iconWidth: iconWidth
                )
            }
        }
    }
    
    /// Проверка наличие новых авторских ссылок на материалы доступна если:
    /// - статус наличия новых материалов = true, и
    /// - в локальном массиве материалов есть авторские (для постов с .origin = ,cloud)
    private var checkForPostsUpdate: some View {
        Group {
            let appStateManager = AppSyncStateManager(modelContext: modelContext)
            let status = appStateManager.getAvailableNewCuratedPostsStatus()
            let localPostsFromCloud = vm.allPosts.filter { $0.origin == .cloud }

            if status && !localPostsFromCloud.isEmpty {
//                NavigationLink("Check for materials update") {
//                    CheckForPostsUpdateView()
//                }
                Button("Check for materials update") {
                    coordinator.push(.checkForUpdates)
                }
                .customListRowStyle(
                    iconName: "arrow.trianglehead.counterclockwise",
                    iconWidth: iconWidth
                )
            }
        }
    }
    
    /// Импорт доступен, если в локальных массиве материалов нет авторских (для постов с .origin = ,cloud)

    private var importFromCloud: some View {
        Group {
            let localPostsFromCloud = vm.allPosts.filter { $0.origin == .cloud }

            if localPostsFromCloud.isEmpty {
//                NavigationLink("Download the curated collection") {
//                    ImportPostsFromCloudView()
//                }
                Button("Download the curated collection") {
                    coordinator.push(.importFromCloud)
                }
                .customListRowStyle(
                    iconName: "icloud.and.arrow.down",
                    iconWidth: iconWidth
                )
            }
        }
    }
    
    private var shareBackup: some View {
//        NavigationLink("Share/Backup") {
//            SharePostsView()
//        }
        Button("Share/Backup") {
            coordinator.push(.shareBackup)
        }
        .customListRowStyle(
            iconName: "square.and.arrow.up",
            iconWidth: iconWidth
        )
    }
    
    private var restoreBackup: some View {
//        NavigationLink("Restore backup") {
//            RestoreBackupView()
//        }
        Button("Restore backup") {
            coordinator.push(.restoreBackup)
        }
        .customListRowStyle(
            iconName: "tray.and.arrow.up",
            iconWidth: iconWidth
        )
    }
    
    private var erasePosts: some View {
//        NavigationLink("Erase all materials") {
//            EraseAllPostsView()
//        }
        Button("Erase all materials") {
            coordinator.push(.erasePosts)
        }
        .customListRowStyle(
            iconName: "trash",
            iconWidth: iconWidth
        )
    }
    
    private var acknowledgements: some View {
//        NavigationLink("Acknowledgements") {
//            Acknowledgements()
//        }
        Button("Acknowledgements") {
            coordinator.push(.acknowledgements)
        }
        .customListRowStyle(
            iconName: "hand.thumbsup",
            iconWidth: iconWidth
        )
    }
    
    private var aboutApplication: some View {
//        NavigationLink("About App") {
//            AboutApp()
//        }
        Button("About App") {
            coordinator.push(.aboutApp)
        }
        .customListRowStyle(
            iconName: "info.circle",
            iconWidth: iconWidth
        )
    }
    
    private var legalInformation: some View {
//        NavigationLink("Legal information") {
//            LegalInformationView()
//        }
        Button("Legal information") {
            coordinator.push(.legalInfo)
        }
        .customListRowStyle(
            iconName: "long.text.page.and.pencil",
            iconWidth: iconWidth
        )
    }
    
    private var contactDeveloperButton: some View {
        Button("Contact Developer") {
            EmailService().sendEmail(
                to: "andrey.efimov.dev@gmail.com",
                subject: "Start To SwiftUI!",
                body: ""
            )
        }
        .customListRowStyle(
            iconName: "envelope",
            iconWidth: iconWidth
        )
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppSyncState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    
    let vm = PostsViewModel(modelContext: context)
    let noticevm = NoticeViewModel(modelContext: context)
    
    NavigationStack {
        PreferencesView ()
    }
    .modelContainer(container)
    .environmentObject(vm)
    .environmentObject(noticevm)
    .environmentObject(NavigationCoordinator())
}
