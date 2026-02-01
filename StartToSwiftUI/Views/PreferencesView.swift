//
//  PreferencesView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 09.09.2025.
//

import SwiftUI
import SwiftData

struct PreferencesView: View {
    
    // MARK: - Dependencies
    
    @EnvironmentObject private var vm: PostsViewModel
    @EnvironmentObject private var noticevm: NoticeViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    
    // MARK: - Constants
    
    let iconSize: CGFloat = 18
    
    // MARK: - Body
    
    var body: some View {
        Form {
            Section(header: sectionHeader("Appearance")) {
                themeAppearance
            }
            Section(header: sectionHeader("Notices")) {
                if noticevm.notices.count > 0 {
                    noticeMessages
                }
                notificationToggle
                soundNotificationToggle
            }
            
            Section(header: sectionHeader("Achievements")) {
                achievements
            }
            Section(header: sectionHeader("Manage materials (\(vm.allPosts.count))")) {
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
        }
        .foregroundStyle(Color.mycolor.myAccent)
        .listSectionSpacing(0)
        .navigationTitle("Preferences")
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationViewStyle(StackNavigationViewStyle())
        .toolbar { toolbar }
        .preferredColorScheme(vm.selectedTheme.colorScheme)
    }
    
    // MARK: - Toolbar
    
    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            BackButtonView(iconName: UIDevice.isiPad ? "xmark" : "chevron.left") {
                coordinator.closeModal()
            }
        }
    }
    
    // MARK: - Section Header
    
    private func sectionHeader(_ text: String) -> some View {
                
        return Text(text)
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
    
    // MARK: - Appearance
    
    private var themeAppearance: some View {
        UnderlineSermentedPickerNotOptional(
            selection: $vm.selectedTheme,
            allItems: Theme.allCases,
            titleForCase: { $0.displayName },
            selectedFont: .footnote
        )
        .preferredColorScheme(vm.selectedTheme.colorScheme)
    }
    
    // MARK: - Notifications
    
    private var noticeMessages: some View {
        Button("Messages (\(noticevm.unreadCount)/\(noticevm.notices.count))") {
            coordinator.pushModal(.notices)
        }
        .accessibilityIdentifier("MessagesButton")
        .customListRowStyle(
            iconName: noticevm.unreadCount == 0 ? "message" : "message.badge",
            iconWidth: iconSize
        )
    }
    
    private var notificationToggle: some View {
        HStack {
            Image(systemName: noticevm.isNotificationOn ? "bell" : "bell.slash")
                .frame(width: iconSize)
                .foregroundStyle(Color.mycolor.myBlue)
            Toggle(noticevm.isNotificationOn ? "On" : "Off", isOn: $noticevm.isNotificationOn)
                .tint(Color.mycolor.myBlue)
        }
    }
    
    private var soundNotificationToggle: some View {
        HStack {
            Image(systemName: noticevm.isSoundNotificationOn ? "speaker.wave.2" : "speaker.slash")
                .frame(width: iconSize)
                .foregroundStyle(Color.mycolor.myBlue)
            Toggle(noticevm.isSoundNotificationOn ? "Sound On" : "Sound Off", isOn: $noticevm.isSoundNotificationOn)
                .tint(Color.mycolor.myBlue)
        }
    }
    
    // MARK: - Achievements
    
    private var achievements: some View {
        Button("Check progress") {
            coordinator.pushModal(.studyProgress)
        }
        .customListRowStyle(
            iconName: "hare",
            iconWidth: iconSize
        ) // gauge.open.with.lines.needle.67percent.and.arrowtriangle
    }
    
    // MARK: - Materials Management
    
    private var postDrafts: some View {
        Group {
            if vm.hasDrafts {
                Button("Post drafts (\(vm.draftsCount))") {
                    coordinator.pushModal(.postDrafts)
                }
                .customListRowStyle(
                    iconName: "square.stack.3d.up",
                    iconWidth: iconSize
                )
            }
        }
    }
    
    /// Checking for new curated references to materials is available if:
    /// - new materials availability status = true, and
    /// - The local array of materials contains author's materials (for posts with origin = .cloud)
    ///
    @ViewBuilder
    private var checkForPostsUpdate: some View {
        if vm.hasAvailableCuratedPostsUpdate {
            Button("Check for materials update") {
                coordinator.pushModal(.checkForUpdates)
            }
            .customListRowStyle(iconName: "arrow.trianglehead.counterclockwise", iconWidth: iconSize)
        }
    }
        
    /// Import is available if there are no curated materials in the local array (for posts with origin = .cloud)
    @ViewBuilder
    private var importFromCloud: some View {
        if vm.shouldShowImportFromCloud {
            Button("Download curated collection") {
                coordinator.pushModal(.importFromCloud)
            }
            .customListRowStyle(iconName: "icloud.and.arrow.down", iconWidth: iconSize)
        }
    }
        
    private var shareBackup: some View {
        Button("Share/Backup") {
            coordinator.pushModal(.shareBackup)
        }
        .customListRowStyle(
            iconName: "square.and.arrow.up",
            iconWidth: iconSize
        )
    }
    
    private var restoreBackup: some View {
        Button("Restore backup") {
            coordinator.pushModal(.restoreBackup)
        }
        .customListRowStyle(
            iconName: "tray.and.arrow.up",
            iconWidth: iconSize
        )
    }
    
    private var erasePosts: some View {
        Button("Erase all materials") {
            coordinator.pushModal(.erasePosts)
        }
        .customListRowStyle(
            iconName: "trash",
            iconWidth: iconSize
        )
    }
    
    // MARK: - Communication
    
    private var acknowledgements: some View {
        Button("Acknowledgements") {
            coordinator.pushModal(.acknowledgements)
        }
        .customListRowStyle(
            iconName: "hand.thumbsup",
            iconWidth: iconSize
        )
    }
    
    private var aboutApplication: some View {
        Button("About App") {
            coordinator.pushModal(.aboutApp)
        }
        .customListRowStyle(
            iconName: "info.circle",
            iconWidth: iconSize
        )
    }
    
    private var legalInformation: some View {
        Button("Legal information") {
            coordinator.pushModal(.legalInfo)
        }
        .customListRowStyle(
            iconName: "long.text.page.and.pencil",
            iconWidth: iconSize
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
            iconWidth: iconSize
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
    .environmentObject(AppCoordinator())
}
