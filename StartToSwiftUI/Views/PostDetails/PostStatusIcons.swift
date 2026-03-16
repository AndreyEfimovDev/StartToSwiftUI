
//
//  PostStatusIcons.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.01.2026.
//

import SwiftUI

struct PostStatusIcons: View {
    let post: Post
    let showFavorite: Bool
    
    var body: some View {
        Group {
            if post.draft {
                Image(systemName: "square.stack.3d.up")
            }
            if post.favoriteChoice == .yes && showFavorite {
                Image(systemName: "star.fill")
                    .foregroundStyle(Color.mycolor.myYellow)
            }
            if let rating = post.postRating {
                rating.icon
                    .foregroundStyle(Color.mycolor.myBlue)
            }
            post.progress.icon
                .foregroundStyle(Color.mycolor.myGreen)
            post.origin.icon
        }
        .foregroundStyle(Color.mycolor.myAccent)
    }
}

#Preview {
    PostStatusIcons(post: PreviewData.samplePost1, showFavorite: true)
}
