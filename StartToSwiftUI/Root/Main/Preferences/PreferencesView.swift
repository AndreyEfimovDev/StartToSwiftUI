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

    
//    @State private var navigationPath = NavigationPath()
//    @State private var selectedDestination: PreferencesDestination?
    
    let iconWidth: CGFloat = 18
    
    private var postsCount: Int {
            vm.allPosts.count
        }
    
    private var draftsCount: Int {
        let postDrafts = vm.allPosts.filter { $0.draft == true }
        return postDrafts.count
        }

    @State private var theme: Theme = .dark

        
    var body: some View {
        NavigationView {
            Form {
                Section(header: sectionHeader("Appearance")) {
//                    appearance
                    UnderlineSermentedPickerNotOptional(
                        selection: $theme,
                        allItems: Theme.allCases,
                        titleForCase: { $0.displayName },
                        selectedFont: .footnote,
                        selectedTextColor: Color.mycolor.myBlue,
                        unselectedTextColor: Color.mycolor.mySecondaryText
                    )
                }
                Section(header: sectionHeader("Notifications")) {
                    notificationToggle
                    notifications
                }
                Section(header: sectionHeader("Managing posts (\(postsCount))")) {
                    
                    if !vm.allPosts.filter({ $0.draft == true }).isEmpty {
                        postDrafts
                    }
                    
                    if (!vm.allPosts.isEmpty || vm.isPostsUpdateAvailable) && vm.isFirstImportPostsCompleted {
                        checkForPostsUpdate
                    }
                    
                    importFromCloud
                    shareBackup
                    restoreBackup
                    erasePosts
                }
                Section(header: sectionHeader("Сommunication")){
                    thankfullness
                    aboutApplication
                    legalInformation
                    contactDeveloperButton
                }
            } // Form
            .foregroundStyle(Color.mycolor.myAccent)
            .navigationTitle("Preferences")
//            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    CircleStrokeButtonView(iconName: "chevron.left", isShownCircle: false) {
                        dismiss()
                    }
                }
            }
        } // NavigationStack
    }
    
    // MARK: - Subviews
    
    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .foregroundStyle(Color.mycolor.myAccent)
    }
    
    
    private var appearance: some View {
        HStack {
            Image(systemName: "sun.max")
                .frame(width: iconWidth)
                .foregroundStyle(Color.mycolor.myBlue)
            Toggle("Appearance", isOn: $vm.isNotification)
                .tint(Color.mycolor.myBlue)
        }
    }
    private var notificationToggle: some View {
        HStack {
            Image(systemName: "bell")
                .frame(width: iconWidth)
                .foregroundStyle(Color.mycolor.myBlue)
            Toggle(vm.isNotification ? "On" : "Off", isOn: $vm.isNotification)
                .tint(Color.mycolor.myBlue)
        }
    }
    
    private var notifications: some View {
        NavigationLink("Notice messages \(noticevm.notices.count)") {
            NoticesView()
        }
        .customListRowStyle(
            iconName: "message",
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
        NavigationLink("Check posts updates") {
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
        NavigationLink("Share/Backup posts") {
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
        NavigationLink("Delete all posts") {
            EraseAllPostsView()
        }
        .customListRowStyle(
            iconName: "trash",
            iconWidth: iconWidth
        )
    }
    
    private var thankfullness: some View {
        
        NavigationLink("Thankfullness") {
            
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
