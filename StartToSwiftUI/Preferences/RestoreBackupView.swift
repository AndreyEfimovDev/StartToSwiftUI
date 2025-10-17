///
//  BackupView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 09.09.2025.
//

import SwiftUI

struct RestoreBackupView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: PostsViewModel
    
    private let fileManager = FileStorageManager.shared
    
    
    @State var isBackuped: Bool = false
    @State var isPerformBackup: Bool = false
    @State private var postCount: Int = 0
    
    var body: some View {
        
        VStack {
            Text("""
            You are about to restored posts from backup on the device.
            
            The posts from backup will replace
            all current posts in App.
            
            """)
            .managingPostsTextFormater()

            CapsuleButtonView(
                primaryTitle: "Restore Backup",
                secondaryTitle: "\(postCount) Posts Restored!",
                isToChangeTitile: isBackuped) {
                    isPerformBackup.toggle()
                }
            .disabled(isBackuped)
            .padding(.top, 30)
            .fileImporter(
                isPresented: $isPerformBackup,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        vm.importPostsFromURL(url) {
                            isBackuped.toggle()
                        }
                    }
                case .failure(let error):
                    print("❌ Ошибка импорта: \(error.localizedDescription)")
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 30)
        .padding(.top, 30)
        .padding(30)
    }
}



#Preview {
    RestoreBackupView()
}
