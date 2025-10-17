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

    let action: () -> Void
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Settings")
                        .foregroundStyle(Color.mycolor.accent)
                ) {
                    HStack{
                        Image(systemName: "bell")
                            .frame(width: iconWidth)
                            .foregroundStyle(Color.mycolor.middle)
                        Toggle("Notification", isOn: $vm.isNotification)
                            .tint(.blue)
                    }
                } //Section "Settings"
                
                Section(header: Text("Managing Posts (\(vm.allPosts.count))")
                        .foregroundStyle(Color.mycolor.accent)
                ) {
                    HStack {
                        Image(systemName: "icloud.and.arrow.down")
                            .frame(width: iconWidth)
                            .foregroundStyle(Color.mycolor.middle)
                        NavigationLink("Load Persistent App Posts") {
                            LoadPersistentPostsView()
                        }
                    }
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .frame(width: iconWidth)
                            .foregroundStyle(Color.mycolor.middle)
                        NavigationLink("Share/Backup Posts") {
                            ShareStorePostsView()
                        }
                    }
                    HStack {
                        Image(systemName: "tray.and.arrow.up")
                            .frame(width: iconWidth)
                            .foregroundStyle(Color.mycolor.middle)
                        NavigationLink("Restore Backup") {
                            RestoreBackupView()
                        }
                    }
                    HStack {
                        Image(systemName: "trash")
                            .frame(width: iconWidth)
                            .foregroundStyle(Color.mycolor.middle)
                        NavigationLink("Erase All Posts") {
                            //                        HapticManager.shared.notification(type: .warning)
                            EraseAllPostsView()
                        }
                    }
                } //Section "Managing Posts"
                
                Section {
                    HStack {
                        Image(systemName: "info.square")
                            .frame(width: iconWidth)
                            .foregroundStyle(Color.mycolor.middle)
                        NavigationLink("About APP") {
                            AboutAppView()
                        }
                    }
                    HStack {
                        
                        Image(systemName: "envelope") // envelope.open.fill envelope.fill
                            .frame(width: 15)
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
            .foregroundStyle(Color.mycolor.accent)
            .navigationTitle("Preferences")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    CircleStrokeButtonView(iconName: "chevron.left", isShownCircle: false) { action()
                    }
                }
            }
        } // NavigationStack
    }
    
    func sendEmail(to: String, subject: String, body: String) {
            let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            
            let urlString = "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)"
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        }
    
}




#Preview {
    PreferencesView{
        
    }
    .environmentObject(PostsViewModel())
}
