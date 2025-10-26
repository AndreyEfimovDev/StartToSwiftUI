//
//  PostRowView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.08.2025.
//

import SwiftUI

struct PostRowView: View {
    
    @State private var showFullIntro: Bool = false
    
    let post: Post
    
    @State private var introLineCount: Int = 0
    private let introFont: Font = .footnote
    private let introLineSpacing: CGFloat = 0
    private let introLinesCountLimit: Int = 2
    
    // MARK: MAIN BODY
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5){
            Group {
                title
                author
                level
            }
            .foregroundStyle(Color.mycolor.myAccent)
        }
        .padding(8)
        .padding(.horizontal, 8)
        .background(Color.mycolor.mySectionBackground)
//        .background(
//            Color.mycolor.mySectionBackground,
//            in: RoundedRectangle(cornerRadius: 8)
//        )
    }
        
    // MARK: VIEW VARS
    
    private var title: some View {
        HStack {
            Text(post.title)
                .font(.title3)
                .fontWeight(.bold)
                .minimumScaleFactor(0.75)
                .lineLimit(1)
                .padding(.top, 8)
            Spacer()
            Image(systemName: "star.fill")
                .foregroundStyle(post.favoriteChoice == .yes ? Color.mycolor.myYellow : Color.mycolor.mySecondaryText)
                .padding(.top, 8)
        }
        
    }
    
    private var author: some View {
        HStack {
            Text("@" + post.author + ", ") +
            Text(post.postLanguage.displayName)
            +
            Text(", \(post.postDate?.formatted(date: .numeric, time: .omitted) ?? "post date missed")") +
            Text(post.postType == .other ? "" : ", " + post.postType.displayName)
        }
        .font(.footnote)
    }
    
    private var level: some View {
        Text(post.studyLevel.rawValue.capitalized + " level")
            .font(.body)
            .fontWeight(.medium)
            .foregroundStyle(post.studyLevel.color)

    }
}

fileprivate struct PostRowPreView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color.pink.opacity(0.1)
                .ignoresSafeArea()

            VStack {
                PostRowView(post: DevPreview.samplePost1)
                PostRowView(post: DevPreview.samplePost2)
                PostRowView(post: DevPreview.samplePost3)
            }
            .padding()
        }
    }
}


#Preview {
    PostRowPreView()
    
}
