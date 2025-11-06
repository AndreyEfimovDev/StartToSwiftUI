//
//  PostDetailsView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.08.2025.
//

import SwiftUI

struct PostDetailsView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var vm: PostsViewModel
    
    private let fileManager = FileStorageService.shared
    
    @State private var showSafariView = false
    @State private var showFullIntro: Bool = false
    @State private var showFullFreeTextField: Bool = false
    @State private var showEditPostView: Bool = false
    
    let postId: UUID
    
    private var post: Post? {
        vm.allPosts.first(where: { $0.id == postId })
    }
    
    @State private var lineCountIntro: Int = 0
    private let introFont: Font = .subheadline
    private let introLineSpacing: CGFloat = 0
    private let introLinesCountLimit: Int = 10
    
    @State private var lineCountFreeTextField: Int = 0
    private let fullFreeTextFieldFont: Font = .footnote
    private let fullFreeTextFieldLineSpacing: CGFloat = 0
    private let FreeTextFieldLinesCountLimit: Int = 2
    
    private let sectionBackground: Color = Color.mycolor.myBackground
    private let sectionCornerRadius: CGFloat = 15
    
    
    var body: some View {
        
        if let validPost = post {
            ScrollView(showsIndicators: false) {
                VStack {
                    header(for: validPost)
                        .background(
                            sectionBackground,
                            in: RoundedRectangle(cornerRadius: sectionCornerRadius)
                        )
                        .padding(.top, 30)
                    
                    intro(for: validPost)
                        .background(
                            sectionBackground,
                            in: RoundedRectangle(cornerRadius: sectionCornerRadius)
                        )
                    watchTheSourceButton(for: validPost)
                        .padding(.horizontal, 55)
                    
                    addInfoField(for: validPost)
                        .background(
                            sectionBackground,
                            in: RoundedRectangle(cornerRadius: sectionCornerRadius)
                        ).opacity(validPost.additionalText.isEmpty ? 0 : 1)
                }
                .foregroundStyle(Color.mycolor.myAccent)
            }
            .padding(.horizontal)
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                toolbarForPostDetails(validPost: validPost)
            }
            .fullScreenCover(isPresented: $showEditPostView, content: {
                AddEditPostSheet(post: post)
            })
            .fullScreenCover(isPresented: $showSafariView) {
                if let url = URL(string: validPost.urlString) {
                    SafariWebService(url: url)
                }
            }
        } else {
            Text("Post is not found")
        }
    }
    
    // MARK: Subviews
    
    private func header(for post: Post) -> some View {
        
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 8) {
                Text(post.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                
                Text("@" + post.author)
                    .font(.body)
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                
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
                let dateChecked = post.postDate == nil ? "" : (post.postDate?.formatted(date: .numeric, time: .omitted) ?? "")
                let prefixToDate = post.postDate == nil ? "" : " posted "
                let platform = post.postPlatform == .others ? "" : post.postPlatform.displayName
                let postType = post.postPlatform == .others ? "" : post.postType.displayName
                let titleForIntro = postType + " on " + platform + prefixToDate + dateChecked
                
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
    
    private func watchTheSourceButton(for post: Post) -> some View {
        Button {
            showSafariView = true
        } label: {
            RedCupsuleButton(buttonTitle: "Watch the Source")
        }
    }
    
    private func addInfoField(for post: Post) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text("Additional information")
                    .font(.headline)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 8)
                    .padding(.top, 0)
                
                Spacer()
                if !post.additionalText.isEmpty {
                    MoreLessTextButton(showText: $showFullFreeTextField)
                }
            }
            
            if showFullFreeTextField {
                VStack {
                    Text(post.additionalText)
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
                iconName: validPost.favoriteChoice == .yes ? "star.fill" : "star",
                iconFont: .headline,
                isIconColorToChange: validPost.favoriteChoice == .yes ? true : false,
                imageColorSecondary: Color.mycolor.myYellow,
                isShownCircle: false)
            {
                vm.favoriteToggle(post: validPost)
            }
            
            CircleStrokeButtonView(
                iconName: "pencil",
                isShownCircle: false)
            {
                showEditPostView.toggle()
            }
        }
    }
}


fileprivate struct PostDetailsPreView: View {
    var body: some View {
        NavigationStack {
            PostDetailsView(postId: DevPreview.postsForCloud.first!.id)
                .environmentObject(createPreviewViewModel())
        }
    }
    private func createPreviewViewModel() -> PostsViewModel {
        let viewModel = PostsViewModel()
        viewModel.allPosts = DevPreview.postsForCloud
        return viewModel
    }
    
}

#Preview {
    PostDetailsPreView()
}
