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
    
    let postId: String
    
    private var post: Post? {
        vm.allPosts.first(where: { $0.id == postId })
//        DevData.samplePost1
    }
        
    @State private var lineCountIntro: Int = 0
    private let introFont: Font = .subheadline
    private let introLineSpacing: CGFloat = 0
    private let introLinesCountLimit: Int = 10
    
    @State private var lineCountFreeTextField: Int = 0
    private let fullFreeTextFieldFont: Font = .footnote
    private let fullFreeTextFieldLineSpacing: CGFloat = 0
    private let FreeTextFieldLinesCountLimit: Int = 2
    
    
    var body: some View {
        
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
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                toolbarForPostDetails(validPost: validPost)
            }
            .fullScreenCover(isPresented: $showEditPostView, content: {
                AddEditPostSheet(post: post)
            })
        } else {
            Text("Post is not found")
        }
    }
    
    // MARK: Subviews
    
    @ToolbarContentBuilder
    private func toolbarForPostDetails(validPost: Post) -> some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            CircleStrokeButtonView(
                iconName: "chevron.left",
                isShownCircle: false)
            {
                dismiss()
            }
            
            ShareLink(item: validPost.urlString) {
                Image(systemName: "square.and.arrow.up")
                    .font(.headline)
                    .foregroundStyle(Color.mycolor.mySecondaryText)
                    .offset(y: -2)
                    .frame(width: 30, height: 30)
                    .background(.black.opacity(0.001))
            }
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            CircleStrokeButtonView(
                iconName: validPost.favoriteChoice == .yes ? "heart.fill" : "heart",
                iconFont: .headline,
                isIconColorToChange: validPost.favoriteChoice == .yes ? true : false,
                imageColorSecondary: Color.mycolor.myYellow,
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
            .disabled(post?.origin == .cloud)
        }
    }

    private func header(for post: Post) -> some View {
        
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 8) {
                Text(post.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                
                HStack {
                    
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

                    Text("@" + post.author)
                        .font(.body)
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
                
//                if vm.selectedCategory == nil {
//                    Text(post.category)
//                        .font(.body)
//                        .fontWeight(.medium)
//                        .foregroundStyle(Color.mycolor.myYellow)
//                        .frame(maxWidth: .infinity)
//                }
//                
                Text(post.studyLevel.rawValue.capitalized + " level")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(post.studyLevel.color)
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 8)
        }
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
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
                
                Text (post.intro)
                    .font(introFont)
                    .lineLimit(showFullIntro ? nil : introLinesCountLimit)
                    .lineSpacing(introLineSpacing)
                    .frame(minHeight: 55, alignment: .topLeading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 8)
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
                if !post.notes.isEmpty {
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
            PostDetailsView(postId: DevData.postsForCloud.first!.id)
                .environmentObject(createPreviewViewModel())
        }
    }
    private func createPreviewViewModel() -> PostsViewModel {
        let viewModel = PostsViewModel()
        viewModel.allPosts = DevData.postsForCloud
        return viewModel
    }
    
}

#Preview {
    NavigationStack {
        PostDetailsPreView()
            .environmentObject(PostsViewModel())
    }
}
