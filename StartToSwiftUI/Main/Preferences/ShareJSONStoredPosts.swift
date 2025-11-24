//
//  ShareJSONPostsFile.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.09.2025.
//

import Foundation
import SwiftUI

struct ShareJSONStoredPostsView: View {
    
    @EnvironmentObject private var vm: PostsViewModel
    private let fileManager = FileStorageManager.shared
    
    var body: some View {
        VStack(spacing: 20) {

            if let fileURL = fileManager.getPath(fileName: "posts.json") {
                ShareLink(item: fileURL) {
                    Label("Tap to share all posts", systemImage: "square.and.arrow.up")
                        .border(.red)
                }
            } else {
                Text("File is no found")
            }
        }
        .padding()
    }
}

#Preview {
    ShareJSONStoredPostsView()
        .environmentObject(PostsViewModel())
}
