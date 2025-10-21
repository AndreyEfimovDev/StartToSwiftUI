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
    
    private let fileManager = FileStorageManager.shared

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
    
    var body: some View {
        
        if let validPost = post {
            ScrollView(showsIndicators: false) {
                header(for: validPost)
                    .background(
                        .ultraThickMaterial,
                        in: RoundedRectangle(cornerRadius: 15)
                    )
                intro(for: validPost)
                    .background(
                        .ultraThickMaterial,
                        in: RoundedRectangle(cornerRadius: 15)
                    )
                watchTheSourceButton(for: validPost)
                addInfoField(for: validPost)
                    .background(
                        .ultraThickMaterial,
                        in: RoundedRectangle(cornerRadius: 15)
                    )
                    .opacity(validPost.additionalText.isEmpty ? 0 : 1)
            }
            .foregroundStyle(Color.mycolor.myAccent)
            .padding(.top, 15)
            .padding(.horizontal)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CircleStrokeButtonView(
                        iconName: "chevron.left",
                        isShownCircle: false)
                    {
                        dismiss()
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    ShareLink(item: validPost.urlString) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title2)
                            .foregroundStyle(Color.mycolor.myAccent)
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
//                }
//                ToolbarItem(placement: .topBarTrailing) {
                    CircleStrokeButtonView(
                        iconName: "pencil",
                        isShownCircle: false)
                    {
                        showEditPostView.toggle()
                    }
                }
            }
            .fullScreenCover(isPresented: $showEditPostView, content: {
                AddEditPostSheet(post: post)
            })
            .fullScreenCover(isPresented: $showSafariView) {
                if let url = URL(string: validPost.urlString) {
                    SafariWebService(url: url)
                }
            }
            .myBackground(colorScheme: colorScheme)
            
        } else {
            Text("Post not found")
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
                let author = "@" + post.author
                Text(author)
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
                let date = post.date.formatted(date: .numeric, time: .omitted)
                let platform = post.postPlatform == .others ? "" : " on " + post.postPlatform.rawValue
                Text("Posted " + date + platform)
                    .font(.system(size: 10, weight: .light, design: .rounded))
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
    } // private var additionalText
}


fileprivate struct PostDetailsPreView: View {
    var body: some View {
        NavigationStack {
            PostDetailsView(postId: DevPreview.samplePosts.first!.id)
                .environmentObject(createPreviewViewModel())
        }
            }
    private func createPreviewViewModel() -> PostsViewModel {
        let viewModel = PostsViewModel()
        viewModel.allPosts = DevPreview.samplePosts
        return viewModel
    }

}

#Preview {
    PostDetailsPreView()
}

