//
//  PostDraftsRowView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 13.11.2025.
//

import SwiftUI

struct PostDraftsRowView: View {
    
    let post: Post
    
    // MARK: MAIN BODY
    
    var body: some View {
        VStack(spacing: 5){
            Group {
                title
                author
            }
            .foregroundStyle(Color.mycolor.myAccent)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
//        .padding(8)
//        .padding(.horizontal, 8)
        .background(Color.mycolor.mySectionBackground)
    }
        
    // MARK: Subviews
    
    private var title: some View {
        Text(post.title)
            .font(.title3)
            .fontWeight(.bold)
            .minimumScaleFactor(0.75)
            .lineLimit(1)
//            .padding(.top, 8)
    }
    
    private var author: some View {
        HStack {
            
            if post.draft == true {
                Image(systemName: "square.stack.3d.up")
                    .font(.caption2)
                    .foregroundStyle(Color.mycolor.mySecondaryText)
            }
            
            Text("@" + post.author + ", ") +
            Text("\(post.postDate?.formatted(date: .numeric, time: .omitted) ?? "post date missed")") +
            Text(post.postType == .other ? "" : ", " + post.postType.displayName + " ")
        }
        .font(.footnote)
    }
}

fileprivate struct PostDraftsRowPreView: View {
    
//    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color.pink.opacity(0.1)
                .ignoresSafeArea()

            VStack {
                PostDraftsRowView(post: DevData.samplePost1)
                PostDraftsRowView(post: DevData.samplePost2)
                PostDraftsRowView(post: DevData.samplePost3)
            }
            .padding()
        }
    }
}

#Preview {
    PostDraftsRowPreView()
        .environmentObject(PostsViewModel())
}
