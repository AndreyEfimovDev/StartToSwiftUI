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
            The **StartToSwiftUI** application provides you with the following functionality:
            
            • Create personal collections of links to educational materials, add new and edit existing posts.
            
            • Download a curated collection of SwiftUI learning links composed by the developer from a cloud service upon your request.
            
            • Update a current collection of links from a cloud service upon your request when available.
            
            • Toggle a notification to be informed of updates to the curated collection from the developer.
            
            • Make a search though posts.
            
            • Navigate material by searching and filtering.
            
            • Backup, restore, share and erase posts. 

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
