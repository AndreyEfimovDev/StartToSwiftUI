//
//  Intro.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 05.11.2025.
//

import SwiftUI

struct Intro: View {
    var body: some View {
        ScrollView {
// • Organise learning resources by category
            Text("""
               **StartToSwiftUI** is a free educational link aggregator designed to help you organise learning materials for SwiftUI.
               
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
        .navigationTitle("Intro")
    }
}

#Preview {
    Intro()
}
