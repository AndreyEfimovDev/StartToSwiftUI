//
//  PostRowView2.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 26.10.2025.
//

import SwiftUI

struct PostRowView2: View {
    
    @State private var showFullIntro: Bool = false
    @State private var introLineCount: Int = 0
    private let introFont: Font = .footnote
    private let introLineSpacing: CGFloat = 0
    private let introLinesCountLimit: Int = 2
    
    let post: Post

    // swipe properties
    @State private var offset: CGFloat = 0
    @State private var isSwiped = false
    @State private var containerWidth: CGFloat = 0
    
    @State private var initialOffset: CGFloat = 0
    @State private var isHorisontalDrag: Bool = false
    
    private let reductionRation: CGFloat = 1.8
    
    // MARK: MAIN BODY
        
    var body: some View {
        GeometryReader { geo in
            
            ZStack {
                
                // MARK: Swipe action buttons on background
                swipeButtonsSection(geo: geo)
                
                // MARK: Main body
                postRowBody
                
                .offset(x: offset)
                .gesture(
                    DragGesture(minimumDistance: 5, coordinateSpace: .global)
                        .onChanged { value in
                            let horisontalTranslation = value.translation.width
                            let verticalTranslation = value.translation.height
                            
                            // Detect gesture direcrtion
                            if !isHorisontalDrag {
                                // If gesture is horisontal - go to process swipe
                                if abs(horisontalTranslation) > abs(verticalTranslation) && abs(horisontalTranslation) > 10 {
                                    isHorisontalDrag = true
                                    initialOffset = offset
                                } else {
                                    // If gesture is vertival - let ScrollView work
                                    return
                                }
                            }
                            
                            // Process horisontal swipes only
                            if isHorisontalDrag {
                                let newOffset = initialOffset + horisontalTranslation
                                
                                // Limit the swipe maximum motion
                                if newOffset > geo.size.height * 0.85 {
                                    offset = geo.size.height * 0.85
                                } else if newOffset < -geo.size.height * 1.5 {
                                    offset = -geo.size.height * 1.5
                                } else {
                                    offset = newOffset
                                }
                            }
                        }
                        .onEnded { value in
                            if isHorisontalDrag {
                                let horisontalTranslation = value.translation.width
                                
                                withAnimation(.spring(duration: 0.3)) {
                                    if horisontalTranslation < -geo.size.height * 1.5 {
                                        offset = -geo.size.height * 1.3
                                        isSwiped = true
                                    } else if horisontalTranslation > geo.size.height * 0.85 {
                                        offset = geo.size.height * 0.65
                                        isSwiped = true
                                    } else {
                                        resetPosition()
                                    }
                                }
                            }
                            isHorisontalDrag = false
                            initialOffset = 0
                        }
                )// .gesture
            } // ZStack
        } // GeometryReader
        .frame(height: 89)
        .onChange(of: isSwiped) { _, newValue in
            if !newValue {
                resetPosition()
            }
        }
    }
    
    // MARK: Functions
    private func resetPosition() {
        withAnimation(.spring()) {
            offset = 0
            isSwiped = false
        }
    }
    
    // MARK: Subviews
    
    @ViewBuilder
    private func swipeButtonsSection(geo: GeometryProxy) -> some View {
                
        HStack(spacing: 8) {
            
            SwipeListButton(
                systemImageName: "star.fill",
                minorImageName: "star.slash.fill",
                size: geo.size.height,
                ratio: reductionRation,
                buttonColor: Color.mycolor.myYellow,
                isToChangeImage: post.favoriteChoice == .yes ? true : false) {
                    withAnimation {
                        resetPosition()
                    }
                }
 
            Spacer()
            
            SwipeListButton(
                systemImageName: "pencil",
                size: geo.size.height,
                ratio: reductionRation,
                buttonColor: Color.mycolor.myBlue) {
                    
                    resetPosition()
                }
            
            SwipeListButton(
                systemImageName: "trash.fill",
                size: geo.size.height,
                ratio: reductionRation,
                buttonColor: Color.mycolor.myRed) {
                    withAnimation {
                        print("width: \(geo.size.width) + height: \(geo.size.height)")
                        resetPosition()
                    }
                }
            
        }
//                .padding(.horizontal, 16)
//                .opacity(offset < 0 ? 1 : 0) // Show only right buttons
    }
    
    private var postRowBody: some View {
        
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
        .background(
            Color.mycolor.mySectionBackground,
            in: RoundedRectangle(cornerRadius: 8)
        )
    }
    
    
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
//            Text(post.postLanguage.displayName)
//            +
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
                PostRowView2(post: DevData.samplePost1)
                PostRowView2(post: DevData.samplePost2)
                PostRowView2(post: DevData.samplePost3)
            }
//            .padding()
        }
    }
}


#Preview {
    PostRowPreView()
    
}
