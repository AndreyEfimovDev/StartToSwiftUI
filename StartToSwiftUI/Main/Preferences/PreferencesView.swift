//
//  PreferencesView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 09.09.2025.
//

import SwiftUI


//enum PreferencesDestination: Hashable {
//    case cloudImport
//    case shareBackup
//    case restoreBackup
//    case erasePosts
//    case aboutApp
//}

struct PreferencesView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: PostsViewModel
    @EnvironmentObject private var noticevm: NoticeViewModel
    
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
        NavigationStack {
            Form {
                
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
                    
                    NavigationLink("Check progress") {
                        StudyProgressView()
                    }
                    .customListRowStyle(
                        iconName: "hare",
                        iconWidth: iconWidth)
                } // gauge.open.with.lines.needle.67percent.and.arrowtriangle
                
                Section(header: sectionHeader("Manage materials (\(postsCount))")) {
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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if UIDevice.isiPad {
                        BackButtonView(iconName: "xmark") { dismiss() }
                    } else {
                        BackButtonView() { dismiss() }
                    }
                }
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
            selectedFont: .footnote,
            selectedTextColor: Color.mycolor.myBlue,
            unselectedTextColor: Color.mycolor.myAccent
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
    
    private var noticeMessages: some View {
        NavigationLink("Messages (\(newNoticesCount)/\(noticevm.notices.count))") {
            NoticesView()
        }
        .customListRowStyle(
            iconName: newNoticesCount == 0 ? "message" : "message.badge",
            iconWidth: iconWidth
        )
    }
    
    private var postDrafts: some View {
        Group {
            if !vm.allPosts.filter({ $0.draft == true }).isEmpty {
                NavigationLink("Post drafts (\(draftsCount))") {
                    PostDraftsView()
                }
                .customListRowStyle(
                    iconName: "square.stack.3d.up",
                    iconWidth: iconWidth
                )
            }
        }
    }
    
    private var checkForPostsUpdate: some View {
        Group {
            if (!vm.allPosts.isEmpty) && vm.isFirstImportPostsCompleted {
                NavigationLink("Check for materials update") {
                    CheckForPostsUpdateView()
                }
                .customListRowStyle(
                    iconName: "arrow.trianglehead.counterclockwise",
                    iconWidth: iconWidth
                )
            }
        }
    }
    
    private var importFromCloud: some View {
        NavigationLink("Download the curated collection") {
            ImportPostsFromCloudView()
        }
        .customListRowStyle(
            iconName: "icloud.and.arrow.down",
            iconWidth: iconWidth
        )
    }
    
    private var shareBackup: some View {
        NavigationLink("Share/Backup") {
            SharePostsView()
        }
        .customListRowStyle(
            iconName: "square.and.arrow.up",
            iconWidth: iconWidth
        )
    }
    
    private var restoreBackup: some View {
        NavigationLink("Restore backup") {
            RestoreBackupView()
        }
        .customListRowStyle(
            iconName: "tray.and.arrow.up",
            iconWidth: iconWidth
        )
    }
    
    private var erasePosts: some View {
        NavigationLink("Delete all materials") {
            EraseAllPostsView()
        }
        .customListRowStyle(
            iconName: "trash",
            iconWidth: iconWidth
        )
    }
    
    private var acknowledgements: some View {
        
        NavigationLink("Acknowledgements") {
            Acknowledgements()
        }
        .customListRowStyle(
            iconName: "hand.thumbsup",
            iconWidth: iconWidth
        )
    }
    
    private var aboutApplication: some View {
        NavigationLink("About App") {
            AboutApp()
        }
        .customListRowStyle(
            iconName: "info.circle",
            iconWidth: iconWidth
        )
    }
    
    private var legalInformation: some View {
        
        NavigationLink("Legal information") {
            LegalInformationView()
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


//// MARK: - Wrapping all child views for lazy loading (for testing)
//
//struct LazyView<Content: View>: View {
//
//    let build: () -> Content
//
//    init(_ build: @escaping () -> Content) {
//        self.build = build
//    }
//
//    var body: Content {
//        build()
//    }
//}


#Preview {
    NavigationStack {
        PreferencesView ()
    }
    .environmentObject(PostsViewModel())
    .environmentObject(NoticeViewModel())
}
