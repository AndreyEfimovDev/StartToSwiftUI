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
//                    .padding(.top, 4)
                author
                level
//                    .padding(.bottom, 4)
            }
            .foregroundStyle(Color.mycolor.myAccent)
            .padding(.leading, 8)
//            .padding(.vertical, 8)
        }
        .padding(.vertical, 8)
//        .buttonStyle(.plain) // it makes the button "...more" accessable on touchable view
        .background(.ultraThickMaterial)
//            ,
//            in: RoundedRectangle(cornerRadius: 15)
//        )
//        .padding(.horizontal, 8)
    }
        
    // MARK: VIEW VARS
    
    private var title: some View {
        HStack {
            Text(post.title)
                .font(.title3)
                .fontWeight(.bold)
                .minimumScaleFactor(0.75)
                .lineLimit(1)
            Spacer()
            Image(systemName: "star.fill")
                .foregroundStyle(post.favoriteChoice == .yes ? Color.mycolor.myYellow : Color.mycolor.mySecondaryText)
        }
    }
    
    private var author: some View {
        HStack {
            Text("@" + post.author + ", ") +
            Text(post.postLanguage.displayName)
            +
            Text(", \(post.postDate?.formatted(date: .numeric, time: .omitted) ?? "post date missed")") +
            Text(post.postPlatform == .others ? "" : ", on " + post.postPlatform.rawValue)
        }
        .font(.footnote)
    }
    
    private var level: some View {
        Text(post.studyLevel.rawValue.capitalized + " level")
            .font(.body)
            .fontWeight(.medium)
            .foregroundStyle(post.studyLevel.color)
    }
//    private var intro: some View {
//        
//        VStack {
//            Text(post.intro)
//                .lineLimit(showFullIntro ? nil : introLinesCountLimit)
//                .font(introFont)
//                .lineSpacing(introLineSpacing)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .onLineCountChanged(font: introFont, lineSpacing: introLineSpacing) { count in
//                    introLineCount = count
//                }
//            HStack {
//                Spacer()
//                if introLineCount > introLinesCountLimit { MoreLessTextButton(showText: $showFullIntro)
//                }
//            }
//            .offset(y: -15)
//        }
//        .frame(minHeight: 40, alignment: .topLeading)
//    } // private var intro
}

fileprivate struct PostRowPreView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            PostRowView(post: DevPreview.samplePost1)
            PostRowView(post: DevPreview.samplePost2)
            PostRowView(post: DevPreview.samplePost3)
        }
        .myBackground(colorScheme: colorScheme)
    }
}


#Preview {
    PostRowPreView()
    
}
