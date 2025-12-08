//
//  PostDetailsView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.08.2025.
//

import SwiftUI

struct PostDetailsView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var vm: PostsViewModel
        
    @State private var showSafariView = false
    @State private var showFullIntro: Bool = false
    @State private var showFullFreeTextField: Bool = false
    @State private var showEditPostView: Bool = false
    @State private var showRatingSelectionView: Bool = false
    
    let postId: String
    
    private var post: Post? {
        vm.allPosts.first(where: { $0.id == postId })
//        PreviewData.samplePost3
    }
        
    @State private var lineCountIntro: Int = 0
    private let introFont: Font = .subheadline
    private let introLineSpacing: CGFloat = 0
    private let introLinesCountLimit: Int = 10
    
    @State private var lineCountFreeTextField: Int = 0
    private let fullFreeTextFieldFont: Font = .footnote
    private let fullFreeTextFieldLineSpacing: CGFloat = 0
    private let FreeTextFieldLinesCountLimit: Int = 2
    
    @State private var showRatingTab: Bool = false
    @State private var showProgressTab: Bool = false
    @State private var zIndexBarRating: Double = 0
    @State private var zIndexBarProgress: Double = 0
    private let minHeigt: CGFloat = 75
    private let maxHeigt: CGFloat = 300
    private let tabWidth: CGFloat = UIScreen.main.bounds.width * 0.60

    
    var body: some View {
        ZStack (alignment: .bottom) {
            VStack {
                if let validPost = post {
                    ScrollView(showsIndicators: false) {
                        VStack {
                            header(for: validPost)
                                .background(
                                    .thinMaterial,
                                    in: RoundedRectangle(cornerRadius: 15)
                                )
                                .padding(.top, 30)
                            
                            intro(for: validPost)
                                .background(
                                    .thinMaterial,
                                    in: RoundedRectangle(cornerRadius: 15)
                                )
                            goToTheSourceButton(for: validPost)
                                .padding(.top, 30)
                                .padding(.horizontal, 50)
                            
                            notesToPost(for: validPost)
                                .background(
                                    .thinMaterial,
                                    in: RoundedRectangle(cornerRadius: 15)
                                ).opacity(validPost.notes.isEmpty ? 0 : 1)
                        }
                        .foregroundStyle(Color.mycolor.myAccent)
                    } // ScrollView
                    .padding(.horizontal)
                    .navigationBarBackButtonHidden(true)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        toolbarForPostDetails(validPost: validPost)
                    }
                    .sheet(isPresented: $showEditPostView) {
                        NavigationStack {
                            AddEditPostSheet(post: post)
                        }
                    }
                } else {
                    Text("Post is not found")
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
//            if let validPost = post {
                bottomTabsContainer
//            }
        }
        .ignoresSafeArea(edges: .bottom)

    }
    
    private var bottomTabsContainer: some View {
        ZStack {
            // Rating Selection Bar
            selectionTabView (
                icon: "star", color: .yellow, alignment: .leading,
                isExpanded: showRatingTab,
                otherIsExpanded: showProgressTab,
                zIndexTab: zIndexBarRating)
            {
                zIndexBarRating = 1
                zIndexBarProgress = 0
                withAnimation(.easeInOut(duration: 0.25)) {
                    showRatingTab.toggle()
                }
            }
            // Study Progress Selection Bar
            selectionTabView (
                icon: "hare", color: .green, alignment: .trailing,
                isExpanded: showProgressTab,
                otherIsExpanded: showRatingTab,
                zIndexTab: zIndexBarProgress)
            {
                zIndexBarProgress = 1
                zIndexBarRating = 0
                withAnimation(.easeInOut(duration: 0.25)) {
                    showProgressTab.toggle()
                }
            }
        }

    }
    
    @ViewBuilder
    private func selectionTabView(
        icon: String,
        color: Color,
        alignment: Alignment,
        isExpanded: Bool,
        otherIsExpanded: Bool,
        zIndexTab: Double,
        completion: @escaping () -> Void
    ) -> some View {

        ZStack (alignment: .top) {
            UnevenRoundedRectangle(
                topLeadingRadius: 30,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 30,
                style: .continuous
            )
            .fill(isExpanded ? .thinMaterial : .ultraThinMaterial)
                .strokeBorder(
                    (isExpanded ? Color.mycolor.myBlue : Color.mycolor.mySecondary).opacity(0.2),
                    lineWidth: 1,
                        antialiased: true
                    )
                .frame(height: isExpanded ? maxHeigt : minHeigt)
            Button {
                completion()
            } label: {
                VStack(spacing: 0) {
                    if !isExpanded {
                        Image(systemName: "control")
                            .font(.headline)
                    }
//                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    Image(systemName: icon)
                        .imageScale(.small)
                        .padding(8)
                }
                .foregroundColor(Color.mycolor.myBlue)
                .background(.black.opacity(0.001))
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .frame(maxWidth: isExpanded ? .infinity : tabWidth)
        .frame(maxWidth: .infinity, alignment: alignment)
        .zIndex(zIndexTab)
        .offset(y: otherIsExpanded && !isExpanded ? maxHeigt : 0)
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
    }
    
    // MARK: Subviews
    
    @ToolbarContentBuilder
    private func toolbarForPostDetails(validPost: Post) -> some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            
            if UIDevice.isiPhone {
                BackButtonView() { dismiss() }
            }
            
            ShareLink(item: validPost.urlString) {
                Image(systemName: "square.and.arrow.up")
                    .font(.headline)
                    .foregroundStyle(Color.mycolor.myAccent)
                    .offset(y: -2)
                    .frame(width: 30, height: 30)
                    .background(.black.opacity(0.001))
            }
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            
//            CircleStrokeButtonView(
//                iconName: "star",
//                iconFont: .headline,
//                isShownCircle: false)
//            {
//                vm.selectedRating = validPost.postRating
//                showRatingSelectionView = true
//            }
            
            CircleStrokeButtonView(
                iconName: validPost.favoriteChoice == .yes ? "heart.slash" : "heart",
                iconFont: .headline,
                isShownCircle: false)
            {
                vm.favoriteToggle(post: validPost)
            }
            
            CircleStrokeButtonView(
                iconName: post?.origin == .cloud || post?.origin == .statical ? "pencil.slash" : "pencil",
                isShownCircle: false)
            {
                showEditPostView.toggle()
            }
            .disabled(post?.origin == .cloud || post?.origin == .statical)
        }
    }

    private func header(for post: Post) -> some View {
        
        VStack(spacing: 8) {
                Text(post.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("@" + post.author)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Text(post.studyLevel.displayName.capitalized + " level")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(post.studyLevel.color)
                Spacer()

                Group {
                    if post.draft {
                        Image(systemName: "square.stack.3d.up")
                    }
                    if post.favoriteChoice == .yes {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(Color.mycolor.myYellow)
                    }
                    if let rating = post.postRating {
                        rating.icon
                            .foregroundStyle(Color.mycolor.myBlue)
                    }
                    post.progress.icon
                        .foregroundStyle(Color.mycolor.myGreen)
                    post.origin.icon
                }
                .font(.caption)
                .foregroundStyle(Color.mycolor.myAccent)
 
                //                    Text("\(post.category)")
                //                        .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

//                if vm.selectedCategory == nil {
//                    Text(post.category)
//                        .font(.body)
//                        .fontWeight(.medium)
//                        .foregroundStyle(Color.mycolor.myYellow)
//                        .frame(maxWidth: .infinity)
//                }
//                
            }
            .padding()
    }
    
    private func intro(for post: Post) -> some View {
        VStack(spacing: 0) {
            VStack {
                let postDate = post.postDate == nil ? "" : (post.postDate?.formatted(date: .numeric, time: .omitted) ?? "")
                let prefixToDate = post.postDate == nil ? "" : " posted "
                let platform = post.postPlatform.displayName
                let postType = post.postType.displayName
                let titleForIntro = postType + prefixToDate +  postDate + " on " + platform
                
                Text(titleForIntro)
                    .font(.caption)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                
                Text (post.intro)
                    .font(introFont)
                    .lineLimit(showFullIntro ? nil : introLinesCountLimit)
                    .lineSpacing(introLineSpacing)
                    .frame(minHeight: 55, alignment: .topLeading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onLineCountChanged(font: introFont, lineSpacing: introLineSpacing) { count in
                        lineCountIntro = count - 1
                    }
                HStack(alignment: .top) {
                    Spacer()
                    if lineCountIntro > introLinesCountLimit {
                        MoreLessTextButton(showText: $showFullIntro)
                    }
                }
                .offset(y: -15)
            }
        }
        .padding()
    }
    
    private func goToTheSourceButton(for post: Post) -> some View {
                
        LinkButtonURL(
            buttonTitle: "Go to the Source",
            urlString: post.urlString
        )
    }
    
    private func notesToPost(for post: Post) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text("Notes")
                    .font(.headline)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 8)
                    .padding(.top, 0)
                
                Spacer()
                if !post.notes.isEmpty && !showFullFreeTextField {
                    MoreLessTextButton(showText: $showFullFreeTextField)
                }
            }
            
            if showFullFreeTextField {
                VStack {
                    Text(post.notes)
                        .font(fullFreeTextFieldFont)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 8)
                    
                    HStack(alignment: .top) {
                        Spacer()
                        MoreLessTextButton(showText: $showFullFreeTextField)
                    }
                    .offset(y: -15)
                }
            } // if isShowingFullFreeTextField
        } // VStack
    }
}


fileprivate struct PostDetailsPreView: View {
    var body: some View {
        NavigationStack {
            PostDetailsView(postId: PreviewData.samplePosts.first!.id)
                .environmentObject(createPreviewViewModel())
        }
    }
    private func createPreviewViewModel() -> PostsViewModel {
        let viewModel = PostsViewModel()
        viewModel.allPosts = PreviewData.samplePosts
        return viewModel
    }
    
}

#Preview {
    NavigationStack {
        PostDetailsPreView()
            .environmentObject(PostsViewModel())
    }
}
