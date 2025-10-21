//
//  ShareJSONPostsFile.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.09.2025.
//

import SwiftUI

struct ShareStorePostsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: PostsViewModel
    
    private let fileManager = FileStorageManager.shared

    var body: some View {
        VStack {
            Text("""
                You are about to share/backup posts from App.
                
                Posts in JSON format can be
                stored on your device or
                shared directly via
                AirDop / Mail / Messenger / etc.
                
                """)
            .managingPostsTextFormater()

            if let fileURL = fileManager.getFileURL(fileName: fileManager.fileName) {
                ShareLink(item: fileURL) {
                    VStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title)
                            .foregroundStyle(Color.mycolor.myAccent)
                        
                        Text("Share/Store")
                            .font(.caption)
                            .foregroundStyle(Color.mycolor.mySecondaryText)
                    }
                    .padding()
                    .background(Color.black.opacity(0.001))
                }
            }
            else {
                Text("File is no found")
                    .font(.headline)
                    .foregroundStyle(Color.mycolor.myRed)
                    .frame(width: 200, height: 100)
                    .background(.ultraThinMaterial)
                    .cornerRadius(15)
                    .overlay {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.mycolor.myAccent.opacity(1), lineWidth: 1)
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
    ShareStorePostsView()
        .environmentObject(PostsViewModel())
}
