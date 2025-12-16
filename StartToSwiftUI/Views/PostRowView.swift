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
        .background(.black.opacity(0.001))

    }
        
    // MARK: Subviews
    
    private var title: some View {
        Text(post.title)
            .font(.title3)
            .fontWeight(.bold)
            .minimumScaleFactor(0.75)
            .lineLimit(1)
            .padding(.top, 12)
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
        .minimumScaleFactor(0.75)
        .lineLimit(1)
    }
    
    private var level: some View {
        
        HStack {
            Text(post.studyLevel.displayName.capitalized + " level")
                .font(.body)
                .foregroundStyle(post.studyLevel.color)
            Spacer()
            
            Group {
                if post.draft {
                    Image(systemName: "square.stack.3d.up")
                }
                if post.favoriteChoice == .yes {
                    Image(systemName: "heart")
                        .foregroundStyle(Color.mycolor.myRed)
                }
                if let rating = post.postRating {
                    rating.icon
                        .foregroundStyle(Color.mycolor.myBlue)
                }
                post.progress.icon
                    .foregroundStyle(Color.mycolor.myGreen)
                
//                if post.origin != .local {
                    post.origin.icon
//                }
            }
            .font(.caption)
            .foregroundStyle(Color.mycolor.myAccent)
        }
        .fontWeight(.medium)
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
                PostRowView(post: PreviewData.samplePost4)
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
