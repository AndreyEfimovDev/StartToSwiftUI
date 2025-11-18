//
//  Intro.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 05.11.2025.
//

import SwiftUI

struct Introduction: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
// • Organise learning resources by category
            Text("""
               **StartToSwiftUI** is a free educational link aggregator designed to help you organise learning materials for SwiftUI.

               The app offers the following features:
                        
               **Personal Library**: Create and manage your own collection of links to learning materials.

               **Curated Collection**: Access a curated collection of SwiftUI tutorials and articles compiled from open sources. You'll receive a notification when a new version of the collection is available for download. I strive to keep this collection up to date, though this cannot be guaranteed at all times.
                                       
               **Posts Management**: Organise learning resources by category such as level of study, year of posts, type of source/media, etc, create a collection of favourite posts.
               
               **Full Control**: Edit and delete your posts as needed, save drafts for further processing.
               
               **Smart Search & Filter**: Quickly find what you need using search and filtering tools.

               **Data Management**: Backup, restore, share, or delete posts as needed.
               
               **IMPORTANT — COPYRIGHT NOTES**:
               
               The app only stores links to materials from public sources, it does not copy or distribute the content itself. All rights to the materials remain with their respective authors. For each resource, the following is provided: the author, the source, a direct link, and the publication date where available.
               
               This application is intended solely for non-commercial, educational use. The developer makes no claim of authorship over the featured resources and fully respects the intellectual property rights of content creators.
               
               Authors who wish to have a link to their content removed are requested to contact us via email.
               """)
      
            .multilineTextAlignment(.leading)
            .managingPostsTextFormater()
            .padding(.horizontal)
        }
        .navigationTitle("Introduction")
        .navigationBarBackButtonHidden(true)
//        .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                CircleStrokeButtonView(iconName: "chevron.left", isShownCircle: false) {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        Introduction()
    }
}

