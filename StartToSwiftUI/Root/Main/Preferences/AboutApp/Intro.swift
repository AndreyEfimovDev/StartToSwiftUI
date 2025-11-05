//
//  Intro.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 05.11.2025.
//

import SwiftUI

struct Intro: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                Text("""
                        **StartToSwiftUI** — a free educational link aggregator, created to help organise learning materials for SwiftUI.
                        
                        **KEY FEATURES**:
                        
                        • Create personal collections of links to educational materials
                        • Organise learning resources by category
                        • Download a curated collection of SwiftUI learning links from the developer
                        
                        **IMPORTANT — ON COPYRIGHT**:
                        
                        The app only stores links to materials from public sources, it does not copy or distribute content. All rights to the materials belong to their respective authors. For each resource, the following is provided: author, source, a direct link to the original, and the publication date (where known).
                        
                        The app is intended solely for non-commercial, educational use. The developer makes no claim of authorship over the featured resources and respects the rights of content creators.
                        
                        Content authors can request the removal of links via email request.
                        """)
                
                .multilineTextAlignment(.leading)
                .managingPostsTextFormater()
                .padding(.horizontal)
            }
            .foregroundStyle(Color.mycolor.myAccent)
            .navigationTitle("Intro")
        }    }
}

#Preview {
    Intro()
}
