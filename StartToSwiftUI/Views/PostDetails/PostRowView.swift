//
//  PostRowView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.08.2025.
//

import SwiftUI

struct PostRowView: View {
    
    // MARK: - Constants
    
    let post: Post
    
    // MARK: - Computed Properties
    
    private var subtitleText: String {
        var parts = ["@\(post.author)"]
        
        if let postDate = post.postDate {
            parts.append(postDate.formatted(date: .numeric, time: .omitted))
        }
        
        if post.postType != .other {
            parts.append(post.postType.displayName)
        }
        
        parts.append(post.postPlatform.displayName)
        
        return parts.joined(separator: ", ")
    }
    
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
        Text(post.title)
            .font(.title3)
            .fontWeight(.bold)
            .minimumScaleFactor(0.75)
            .lineLimit(1)
            .padding(.top, 12)
    }
    
    private var subtitle: some View {
        Text(subtitleText)
            .font(.footnote)
            .minimumScaleFactor(0.75)
            .lineLimit(1)
    }
    
    private var statusRow: some View {
        HStack {
            Text("\(post.studyLevel.displayName.capitalized)")
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundStyle(post.studyLevel.color)
            
            Spacer()
            
            PostStatusIcons(post: post)
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
                PostRowView(post: PreviewData.samplePost1)
                PostRowView(post: PreviewData.samplePost2)
                PostRowView(post: PreviewData.samplePost3)
                PostRowView(post: PreviewData.samplePost4)
            }
        }
    }
}
