//
//  PostDraftsRowView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 13.11.2025.
//

import SwiftUI

struct PostDraftsRowView: View {
        
    let post: Post
    
    // MARK: BODY
    var body: some View {
        VStack(spacing: 5){
            Group {
                title
                author
            }
            .foregroundStyle(Color.mycolor.myAccent)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
        
    // MARK: Subviews
    private var title: some View {
        Text(post.title)
            .font(.title3)
            .fontWeight(.bold)
            .minimumScaleFactor(0.75)
            .lineLimit(1)
            .padding(.top, 4)
    }
    
    private var author: some View {
        HStack {
            Text("@" + post.author + ", ") +
            Text("\(post.postDate?.formatted(date: .numeric, time: .omitted) ?? "date missed")") +
            Text(post.postType == .other ? "" : ", " + post.postType.displayName + " ")
        }
        .font(.footnote)
        .padding(.vertical)

    }
}

#Preview {
    ZStack {
        Color.pink.opacity(0.1)
            .ignoresSafeArea()

        VStack {
            Divider()
            PostDraftsRowView(post: PreviewData.samplePost1)
            Divider()
            PostDraftsRowView(post: PreviewData.samplePost2)
            Divider()
            PostDraftsRowView(post: PreviewData.samplePost3)
            Divider()
        }
    }
}

