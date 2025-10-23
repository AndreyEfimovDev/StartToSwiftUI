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
                    cloudImportLink
                    shareBackupLink
                    restoreBackupLink
                    erasePostsLink
                }
                
                Section {
                    aboutAppLink
                    contactDeveloperButton
                }
            } // Form
            .foregroundStyle(Color.mycolor.myAccent)
            .navigationTitle("Preferences")
//            .onAppear { print("✅ PreferencesView appeared on main thread: \(Thread.isMainThread)") }
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
                .foregroundStyle(Color.mycolor.middle)
            Toggle("Notification", isOn: $vm.isNotification)
                .tint(.blue)
        }
    }
    
    private var cloudImportLink: some View {
        NavigationLink("Import posts from Cloud") {
            ImportPostsFromCloudView()
//            LazyView { ImportPostsFromCloudView() }
        }
        .customPreferencesListRowStyle(iconName: "icloud.and.arrow.down", iconWidth: iconWidth)
    }
    
    private var shareBackupLink: some View {
        NavigationLink("Share/Backup posts") {
//            ShareStorePostsView()
            SharePostsView()
//            LazyView { ShareStorePostsView() }
        }
        .customPreferencesListRowStyle(iconName: "square.and.arrow.up", iconWidth: iconWidth)
    }
    
    private var restoreBackupLink: some View {
        NavigationLink("Restore backup") {
            RestoreBackupView()
//            LazyView { RestoreBackupView() }
        }
        .customPreferencesListRowStyle(iconName: "tray.and.arrow.up", iconWidth: iconWidth)
    }
    
    private var erasePostsLink: some View {
        NavigationLink("Erase all posts") {
            EraseAllPostsView()
//            LazyView { EraseAllPostsView() }
        }
        .customPreferencesListRowStyle(iconName: "trash", iconWidth: iconWidth)
    }
    
    private var aboutAppLink: some View {
        NavigationLink("About App") {
            AboutAppView()
//            LazyView { AboutAppView() }
        }
        .customPreferencesListRowStyle(iconName: "info.square", iconWidth: iconWidth)
    }
    
    private var contactDeveloperButton: some View {
        Button("Contact Developer") {
            EmailService().sendEmail(
                to: "andrey.efimov.dev@gmail.com",
                subject: "Start To SwiftUI!",
                body: ""
            )
        }
        .customPreferencesListRowStyle(iconName: "envelope", iconWidth: iconWidth)
    }
}

// MARK: - Wrapping all child views for lazy loading

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
