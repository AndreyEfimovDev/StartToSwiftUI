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
    }
        
    // MARK: Subviews
    
    private var title: some View {
        Text(post.title)
            .font(.title3)
            .fontWeight(.bold)
            .minimumScaleFactor(0.75)
            .lineLimit(1)
            .padding(.top, 8)
        
    }
    
    private var author: some View {
        HStack {
            if let postDate = post.postDate {
                Text("@" + post.author + ", " + post.category + ", " ) +
                Text(postDate.formatted(date: .numeric, time: .omitted)) +
                Text(post.postType == .other ? "" : ", " + post.postType.displayName)
            } else  {
                Text("@" + post.author + ", " + post.category) +
                Text(post.postType == .other ? "" : ", " + post.postType.displayName)
            }
        }
        .font(.footnote)
    }
    
    private var level: some View {
        
        HStack {
            Text(post.studyLevel.rawValue.capitalized + " level")
                .font(.body)
                .fontWeight(.medium)
                .foregroundStyle(post.studyLevel.color)
            Spacer()
            
            if post.draft == true {
                Image(systemName: "square.stack.3d.up")
                    .font(.caption2)
                    .foregroundStyle(Color.mycolor.mySecondaryText)
            }
            
            Group {
                switch post.origin {
                case .cloud:
                    post.origin.icon
                case .statical:
                    post.origin.icon
                case .local:
                    EmptyView()
                }
            }
            .font(.caption2)
            .foregroundStyle(Color.mycolor.mySecondaryText)
                        
            Image(systemName: post.favoriteChoice == .yes ? "heart.fill" : "heart")
                .font(.caption2)
                .foregroundStyle(post.favoriteChoice == .yes ? Color.mycolor.myYellow : Color.mycolor.mySecondaryText)
        }
    }
    
}

fileprivate struct PostRowPreView: View {
    
    var body: some View {
        ZStack {
            Color.pink.opacity(0.1)
                .ignoresSafeArea()

            VStack {
                PostRowView(post: PreviewData.samplePost1)
                PostRowView(post: PreviewData.samplePost2)
                PostRowView(post: PreviewData.samplePost3)
            }
            .padding()
        }
    }
}


#Preview {
    NavigationStack {
        PostRowPreView()
    }
}
