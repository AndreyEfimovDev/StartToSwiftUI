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
        Form {
            Section(header: sectionHeader("Appearance")) {
                themeAppearence
            }
            
            Section(header: sectionHeader("Notifications")) {
                notificationToggle
                soundNotificationToggle
                noticeMessages
            }

            Section(header: sectionHeader("Managing materials (\(postsCount))")) {
                
                if !vm.allPosts.filter({ $0.draft == true }).isEmpty {
                    postDrafts
                }
                
                if (!vm.allPosts.isEmpty) && vm.isFirstImportPostsCompleted {
                    checkForPostsUpdate
                }
                
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
//        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                CircleStrokeButtonView(iconName: "chevron.left", isShownCircle: false) {
                    dismiss()
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .foregroundStyle(Color.mycolor.myAccent)
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
        NavigationLink("Post drafts (\(draftsCount))") {
            PostDraftsView()
        }
        .customListRowStyle(
            iconName: "square.stack.3d.up",
            iconWidth: iconWidth
        )
    }
    
    private var checkForPostsUpdate: some View {
        NavigationLink("Check for materials update") {
            CheckForPostsUpdateView()
        }
        .customListRowStyle(
            iconName: "arrow.trianglehead.counterclockwise",
            iconWidth: iconWidth
        )
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
