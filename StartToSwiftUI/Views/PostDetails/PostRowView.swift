//
//  PostRowView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.08.2025.
//

import SwiftUI

// MARK: - Row Data

/// Снимок значений поста, которые показывает строка списка.
///
/// Строка получает значения, а не сам `Post`: Post — SwiftData @Model
/// (reference type), и после перезагрузки из хранилища fetch возвращает те же
/// объекты. SwiftUI сравнивает такие входы по ссылке и строку не
/// перерисовывает, а Observation на изменения, пришедшие импортом CloudKit,
/// не срабатывает — значки избранного/рейтинга/прогресса в списке оставались
/// старыми до пересоздания экрана. Снимок сравнивается по значениям, поэтому
/// строка обновляется при любой перезагрузке постов.
struct PostRowData: Equatable {
    let title: String
    let subtitle: String
    let studyLevel: StudyLevel
    let isDraft: Bool
    let favoriteChoice: FavoriteChoice
    let postRating: PostRating?
    let progress: StudyProgress
    let origin: OriginOptions

    /// Снимает отображаемые значения с поста.
    ///
    /// - Parameter post: Пост, для которого строится строка.
    init(post: Post) {
        title = post.title
        subtitle = Self.subtitle(for: post)
        studyLevel = post.studyLevel
        isDraft = post.draft
        favoriteChoice = post.favoriteChoice
        postRating = post.postRating
        progress = post.progress
        origin = post.origin
    }

    /// Подзаголовок строки: категория, дата, автор и тип (тип `.other` не показывается).
    ///
    /// - Parameter post: Пост, для которого строится подзаголовок.
    /// - Returns: Части подзаголовка через запятую.
    private static func subtitle(for post: Post) -> String {
        var parts = [post.category]

        if let postDate = post.postDate {
            parts.append(postDate.calendarDateText)
        }

        parts.append("@\(post.author)")

        if post.postType != .other {
            parts.append(post.postType.displayName)
        }

        return parts.joined(separator: ", ")
    }
}

// MARK: - Row View

struct PostRowView: View {

    // MARK: - Constants

    let data: PostRowData

    // MARK: Body

    var body: some View {
        VStack(alignment: .leading, spacing: 5){
            Group {
                title
                subtitle
                statusRow
            }
            .foregroundStyle(Color.mycolor.myAccent)
        }
        .padding(8)
        .padding(.horizontal, 8)
        .frame(height: 100)
        .background(.black.opacity(0.001))

    }

    // MARK: Subviews

    private var title: some View {
        Text(data.title)
            .font(.title3)
            .fontWeight(.bold)
            .minimumScaleFactor(0.75)
            .lineLimit(1)
            .padding(.top, 12)
    }

    private var subtitle: some View {
        Text(data.subtitle)
            .font(.caption)
            .minimumScaleFactor(0.75)
            .lineLimit(1)
    }

    private var statusRow: some View {
        HStack {
            Text("\(data.studyLevel.displayName.capitalized)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(data.studyLevel.color)

            Spacer()

            PostStatusIcons(data: data)
                .font(.caption)
        }
    }
}

#Preview {
    NavigationStack {
        ZStack {
            Color.pink.opacity(0.1)
                .ignoresSafeArea()
            VStack {
                PostRowView(data: PostRowData(post: PreviewData.samplePost1))
                PostRowView(data: PostRowData(post: PreviewData.samplePost2))
                PostRowView(data: PostRowData(post: PreviewData.samplePost3))
                PostRowView(data: PostRowData(post: PreviewData.samplePost4))
            }
        }
    }
}
