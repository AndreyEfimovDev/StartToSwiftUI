//
//  PostStatusIcons.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.01.2026.
//

import SwiftUI

struct PostStatusIcons: View {
    // Значения, а не сам Post — чтобы строка списка перерисовывалась по
    // сравнению значений (см. PostRowData).
    let isDraft: Bool
    let isFavoriteShown: Bool
    let postRating: PostRating?
    let progress: StudyProgress
    let origin: OriginOptions

    /// Значки для экрана деталей — берутся прямо из поста.
    ///
    /// - Parameters:
    ///   - post: Пост, чьи статусы показываются.
    ///   - showFavorite: Показывать ли звёздочку избранного.
    init(post: Post, showFavorite: Bool) {
        isDraft = post.draft
        isFavoriteShown = showFavorite && post.favoriteChoice == .yes
        postRating = post.postRating
        progress = post.progress
        origin = post.origin
    }

    /// Значки для строки списка — из снимка строки, звёздочка показывается.
    ///
    /// - Parameter data: Снимок значений строки.
    init(data: PostRowData) {
        isDraft = data.isDraft
        isFavoriteShown = data.favoriteChoice == .yes
        postRating = data.postRating
        progress = data.progress
        origin = data.origin
    }

    var body: some View {
        Group {
            if isDraft {
                Image(systemName: "square.stack.3d.up")
            }
            if isFavoriteShown {
                Image(systemName: "star.fill")
                    .foregroundStyle(Color.mycolor.myYellow)
            }
            if let rating = postRating {
                rating.icon
                    .foregroundStyle(Color.mycolor.myBlue)
            }
            progress.icon
                .foregroundStyle(Color.mycolor.myGreen)
            origin.icon
        }
        .foregroundStyle(Color.mycolor.myAccent)
    }
}

#Preview {
    PostStatusIcons(post: PreviewData.samplePost1, showFavorite: true)
}
