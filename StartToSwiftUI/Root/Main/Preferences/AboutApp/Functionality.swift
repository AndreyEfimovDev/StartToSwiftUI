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
            The **StartToSwiftUI** application provides you with the following features:
            
            - Creating personal collections of links to educational materials, adding new posts and editing existing ones.
            - Downloading a curated collection of links for learning SwiftUI composed by the developer from the cloud service upon your request.
            - Updating your current collection of links from a cloud service upon your request if updates are available.
            - Enabling notifications about the availability of updates to the developer's curated collection.
            - Navigating through materials using search and filtering to quickly find and use the relevant information.
            - Backing up, restoring, sharing and deleting posts. 
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
