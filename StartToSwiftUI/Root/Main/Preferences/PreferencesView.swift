//
//  PreferencesView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 09.09.2025.
//

import SwiftUI


enum PreferencesDestination: Hashable {
    case cloudImport
    case shareBackup
    case restoreBackup
    case erasePosts
    case aboutApp
}

struct PreferencesView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: PostsViewModel
    
    @State private var navigationPath = NavigationPath()
    @State private var selectedDestination: PreferencesDestination?
    
    let iconWidth: CGFloat = 18
    
    private var postsCount: Int {
            vm.allPosts.count
        }
        
    var body: some View {
        NavigationStack {
            Form {
                Section(header: sectionHeader("Settings")) {
                    notificationSetting
                }
                Section(header: sectionHeader("Managing posts (\(postsCount))")) {
                    if (!vm.allPosts.isEmpty || vm.isPostsUpdateAvailable) && vm.isFirstImportPostsCompleted {
                        checkForPostsUpdate
                    }
                    
                    if !vm.isFirstImportPostsCompleted {
                        importFromCloud
                    }
                    shareBackup
                    restoreBackup
                    erasePosts
                }
                Section {
                    aboutApplication
                    legalInformation
                    contactDeveloperButton
                }
            } // Form
            .foregroundStyle(Color.mycolor.myAccent)
            .navigationTitle("Preferences")
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
    
    private var notificationSetting: some View {
        HStack {
            Image(systemName: "bell")
                .frame(width: iconWidth)
                .foregroundStyle(Color.mycolor.myBlue)
            Toggle("Notification", isOn: $vm.isNotification)
                .tint(Color.mycolor.myBlue)
        }
    }
    
    private var checkForPostsUpdate: some View {
        NavigationLink("Check posts updates") {
            CheckForPostsUpdateView()
        }
        .customPreferencesListRowStyle(
            iconName: "arrow.trianglehead.counterclockwise", // arrow.counterclockwise.circle
            iconWidth: iconWidth
        )
    }
    
    private var importFromCloud: some View {
        NavigationLink("Download the curated collection") {
            ImportPostsFromCloudView()
        }
        .customPreferencesListRowStyle(
            iconName: "icloud.and.arrow.down",
            iconWidth: iconWidth
        )
    }
    
    private var shareBackup: some View {
        NavigationLink("Share/Backup posts") {
            SharePostsView()
        }
        .customPreferencesListRowStyle(
            iconName: "square.and.arrow.up",
            iconWidth: iconWidth
        )
    }
    
    private var restoreBackup: some View {
        NavigationLink("Restore backup") {
            RestoreBackupView()
        }
        .customPreferencesListRowStyle(
            iconName: "tray.and.arrow.up",
            iconWidth: iconWidth
        )
    }
    
    private var erasePosts: some View {
        NavigationLink("Delete all posts") {
            EraseAllPostsView()
        }
        .customPreferencesListRowStyle(
            iconName: "trash",
            iconWidth: iconWidth
        )
    }
    
    private var aboutApplication: some View {
        NavigationLink("About App") {
            AboutApp()
        }
        .customPreferencesListRowStyle(
            iconName: "info.circle",
            iconWidth: iconWidth
        )
    }
    
    private var legalInformation: some View {
        
        NavigationLink("Legal information") {
            LegalInformationView()
        }
        .customPreferencesListRowStyle(
            iconName: "long.text.page.and.pencil", // long.text.page.and.pencil receipt exclamationmark.triangle.text.page
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
        .customPreferencesListRowStyle(
            iconName: "envelope",
            iconWidth: iconWidth
        )
    }
}


// MARK: - Wrapping all child views for lazy loading (for testing)

struct LazyView<Content: View>: View {
    
    let build: () -> Content
    
    init(_ build: @escaping () -> Content) {
        self.build = build
    }
    
    var body: Content {
        build()
    }
}



#Preview {
    PreferencesView ()
        .environmentObject(PostsViewModel())
}
