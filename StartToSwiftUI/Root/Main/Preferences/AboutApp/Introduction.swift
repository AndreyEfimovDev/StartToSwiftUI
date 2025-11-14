//
//  Intro.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 05.11.2025.
//

import SwiftUI

struct Introduction: View {
    var body: some View {
        ScrollView {
// • Organise learning resources by category
            Text("""
               **StartToSwiftUI** is a free educational link aggregator designed to help you organise learning materials for SwiftUI.

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

               The app offers the following features:

               **Pre-loaded Collection**: Access a curated collection of SwiftUI tutorials and articles compiled from open sources. You'll receive a notification when a new version of the collection is available for download. I strive to keep this collection up to date, though this cannot be guaranteed at all times.

               **Personal Library**: Add your own posts to create a personal collection for learning SwiftUI.

               **Full Control**: Edit and delete your posts as needed, save drafts for further processing.

               **Data Management**: Share all posts stored in the app or save them for backup and recovery purposes.
                           
               
               **KEY FEATURES**:
               - Create a personal collection of links to educational materials.
               - Download a curated collection of SwiftUI learning links from the developer.
               - Organise learning resources by category.
               - Manage your collected material with search and filtering tools.
               - Handle backup, restoration, sharing, and deletion of posts.
               
               **IMPORTANT — COPYRIGHT NOTES**:
               The app only stores links to materials from public sources, it does not copy or distribute the content itself. All rights to the materials remain with their respective authors. For each resource, the following is provided: the author, the source, a direct link, and the publication date where available.
               
               This application is intended solely for non-commercial, educational use. The developer makes no claim of authorship over the featured resources and fully respects the intellectual property rights of content creators.
               
               Authors who wish to have a link to their content removed are requested to contact us via email.
               """)
      
            .multilineTextAlignment(.leading)
            .managingPostsTextFormater()
            .padding(.horizontal)
        }
        .foregroundStyle(Color.mycolor.myAccent)
        .navigationTitle("Introduction")
    }
}

#Preview {
    Introduction()
}
