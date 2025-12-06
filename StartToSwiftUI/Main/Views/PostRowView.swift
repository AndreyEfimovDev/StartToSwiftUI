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
    
    @State private var isDetectingLongPress: Bool = false
    @State private var isLongPressSuccess: Bool = false
    @State private var isShowPopover: Bool = false

    @State private var introLineCount: Int = 0
    
    private let introFont: Font = .footnote
    private let introLineSpacing: CGFloat = 0
    private let introLinesCountLimit: Int = 2
    private let longPressDuration: Double = 0.5
    
    
    @State var selectedRating: PostRating? = nil
   
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
        .overlay {
            ratingMenuSelection
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scaleEffect(isLongPressSuccess ? 1.0 : 0.5)
                .opacity(isLongPressSuccess ? 1.0 : 0)
                .animation(.bouncy(duration: 0.5), value: isLongPressSuccess)
        }
        .onLongPressGesture(
            minimumDuration: longPressDuration,
            maximumDistance: 50,
            perform: {
                    isLongPressSuccess = true
            },
            onPressingChanged: { isPressing in
                if isPressing {
                        isDetectingLongPress = true
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if !isLongPressSuccess {
                                isDetectingLongPress = false
                        }
                    }
                }
            })

    }
        
    // MARK: Subviews
    
    private var ratingMenuSelection: some View {
        Group {
            if isLongPressSuccess {
                VStack {
                    ratingIconsView
                        .overlay(overlayView.mask(ratingIconsView))
                        .padding()
                        .padding(.bottom, 30)
                    
                    HStack (spacing: 20) {
                        
                        ClearCupsuleButton(
                            primaryTitle: "Place",
                            primaryTitleColor: Color.mycolor.myBlue) {
                                isLongPressSuccess = false
                            }
                        
                        ClearCupsuleButton(
                            primaryTitle: "Reset",
                            primaryTitleColor: Color.mycolor.myRed) {
                                selectedRating = nil
                                isLongPressSuccess = false
                            }
                    }
                }
                .padding(20)
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: 30))
            }
        }
    }
    
    private var ratingIconsView: some View {
        HStack(spacing: 20) {
            ForEach(PostRating.allCases, id: \.self) { rating in
                rating.icon
                    .font(.largeTitle)
                    .foregroundColor(Color.gray)
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            selectedRating = rating
                        }
                    }
            }
        }
    }

    private var overlayView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(selectedRating?.color ?? .secondary)
                    .frame(width: CGFloat(selectedRating?.value ?? 0) / 3 * geometry.size.width)
            }
        }
        .allowsHitTesting(false)
    }
    
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
                if post.favoriteChoice == .yes {
                    Image(systemName: "heart")
                        .foregroundStyle(Color.mycolor.myYellow)
                }
                
                post.progress.icon
                    .foregroundStyle(post.progress.color)
                
                if let rating = post.postRating {
                    rating.icon
                        .foregroundStyle(rating.color)
                }

                if post.draft {
                    Image(systemName: "square.stack.3d.up")
                }
                
                if post.origin != .local {
                    post.origin.icon
                } else { EmptyView() }
                
            }
            .font(.caption)
            .foregroundStyle(Color.mycolor.mySecondary)
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
