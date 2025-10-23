//
//  PreferencesView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 09.09.2025.
//

import SwiftUI

struct PreferencesView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: PostsViewModel
    
    let iconWidth: CGFloat = 18
        
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Settings")
                    .foregroundStyle(Color.mycolor.myAccent)
                ) {
                    HStack{
                        Image(systemName: "bell")
                            .frame(width: iconWidth)
                            .foregroundStyle(Color.mycolor.middle)
                        Toggle("Notification", isOn: $vm.isNotification)
                            .tint(.blue)
                    }
                }
                
                Section(header: Text("Managing posts (\(vm.allPosts.count))")
                    .foregroundStyle(Color.mycolor.myAccent)
                ) {
                    HStack {
                        Image(systemName: "icloud.and.arrow.down")
                            .frame(width: iconWidth)
                            .foregroundStyle(Color.mycolor.middle)
                        NavigationLink("Import pre-loaded posts from Cloud") {
                            ImportPostsFromCloudView()
                        }
                    }
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .frame(width: iconWidth)
                            .foregroundStyle(Color.mycolor.middle)
                        NavigationLink("Share/Backup posts") {
                            ShareStorePostsView()
                        }
                    }
                    HStack {
                        Image(systemName: "tray.and.arrow.up")
                            .frame(width: iconWidth)
                            .foregroundStyle(Color.mycolor.middle)
                        NavigationLink("Restore backup") {
                            RestoreBackupView()
                        }
                    }
                    HStack {
                        Image(systemName: "trash")
                            .frame(width: iconWidth)
                            .foregroundStyle(Color.mycolor.middle)
                        NavigationLink("Erase all posts") {
                            EraseAllPostsView()
                        }
                    }
                }
                
                Section {
                    HStack {
                        Image(systemName: "info.square")
                            .frame(width: iconWidth)
                            .foregroundStyle(Color.mycolor.middle)
                        NavigationLink("About App") {
                            AboutAppView()
                        }
                    }
                    HStack {
                        Image(systemName: "envelope") // envelope.open.fill envelope.fill
                            .frame(width: iconWidth)
                            .foregroundStyle(Color.mycolor.middle)
                        
                        Button("Contact Developer") {
                            EmailService().sendEmail(
                                to: "andrey.efimov.dev@gmail.com",
                                subject: "Start To SwftUI!",
                                body: ""
                            )
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .imageScale(.small)
                            .fontWeight(.bold)
                            .foregroundStyle(.gray).opacity(0.5)
                    }
                } //Section "About APP"
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
}


#Preview {
    PreferencesView ()
        .environmentObject(PostsViewModel())
}
