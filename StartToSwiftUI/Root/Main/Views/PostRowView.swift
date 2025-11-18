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
        .background(.ultraThinMaterial)
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
                Text("@" + post.author + ", ") +
                Text(postDate.formatted(date: .numeric, time: .omitted)) +
                Text(post.postType == .other ? "" : ", " + post.postType.displayName)
            } else  {
                Text("@" + post.author) +
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
            if post.origin == .cloud {
                Image(systemName: "cloud")
                    .font(.caption2)
                    .foregroundStyle(Color.mycolor.mySecondaryText)
            }
            
            Image(systemName: post.favoriteChoice == .yes ? "heart.fill" : "heart")
                .font(.caption2)
                .foregroundStyle(post.favoriteChoice == .yes ? Color.mycolor.myYellow : Color.mycolor.mySecondaryText)
        }
    }
    
}

fileprivate struct PostRowPreView: View {
    
//    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color.pink.opacity(0.1)
                .ignoresSafeArea()

            VStack {
                PostRowView(post: DevData.samplePost1)
                PostRowView(post: DevData.samplePost2)
                PostRowView(post: DevData.samplePost3)
            }
            .padding()
        }
    }
}


#Preview {
    PostRowPreView()
    
}
