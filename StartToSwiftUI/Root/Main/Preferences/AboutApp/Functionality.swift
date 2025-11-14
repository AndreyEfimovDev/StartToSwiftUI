//
//  Functionality.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 05.11.2025.
//

import SwiftUI

struct Functionality: View {
    var body: some View {
//        • Organise learning resources by category.
        ScrollView {
            Text("""
            **StartToSwiftUI** offers the following features:
            
            **Personal Library**: Create and manage your own collection of links to learning materials by adding, editing, saving drafts.

            **Curated Collection**:
            - Download a pre-prepared collection of SwiftUI learning links, curated by the developer, directly from the cloud service.
            - Update your existing collection from the cloud when new materials become available.
            - Receive notifications when updates to the developer's curated collection is ready for download.
            
            **Posts Management**:
            - Specify posts by categories such as year of posts, level of study, type of source/media, etc.
            - Create a collection of favourite posts.
            
            **Smart Search & Filter**: Quickly find what you need using search and filtering tools.

            **Data Management**: Backup, restore, share, or delete your posts as needed.
            """)
            .multilineTextAlignment(.leading)
            .managingPostsTextFormater()
            .padding(.horizontal)
        }
        .foregroundStyle(Color.mycolor.myAccent)
        .navigationTitle("Functionality")
    }
}

#Preview {
    Functionality()
}
