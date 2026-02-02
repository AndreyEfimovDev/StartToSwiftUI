//
//  PostDetailsView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.08.2025.
//

import SwiftUI
import SwiftData

struct PostDetailsView: View {
    
    // MARK: - Dependencies
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var vm: PostsViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    
    private let hapticManager = HapticService.shared
    
    // MARK: - State
    
    @State private var showFullIntro: Bool = false
    @State private var showFullNotes: Bool = false
    @State private var lineCountIntro: Int = 0
    
    @State private var showRatingTab: Bool = false
    @State private var showProgressTab: Bool = false
    @State private var zIndexBarRating: Double = 0
    @State private var zIndexBarProgress: Double = 0
    
    @State private var maxHeight: CGFloat = 350
    @State private var tabWidth: CGFloat = 0
    @State private var expandedWidth: CGFloat = 0
    
    // MARK: - Constants
    
    let postId: String
    
    private let introFont: Font = .subheadline
    private let introLineSpacing: CGFloat = 0
    private let introLinesLimit: Int = 10
    private let widthRatio: CGFloat = 0.55
    
    // MARK: - Computed Properties
    
    private var post: Post? {
        vm.getPost(id: postId)
    }
    
    private var minHeight: CGFloat {
        UIDevice.isiPad ? 60 : 75
    }
    
    private var isEditable: Bool {
        post?.origin == .local
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                if let post {
                    postContent(for: post)
                        .navigationBarBackButtonHidden(true)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar { toolbar(for: post) }
                } else {
                    postNotSelectedEmptyView(text: "Post is not found")
                }
            }
            .onAppear {
                updateWidths(for: proxy.size.width)
            }
            .onChange(of: proxy.size.width) { _, newValue in
                updateWidths(for: newValue)
            }
            .safeAreaInset(edge: .bottom) {
                if post != nil {
                    bottomTabsContainer
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
    
    // MARK: - Content
    
    private func postContent(for post: Post) -> some View {
        ScrollView(showsIndicators: false) {
            VStack {
                header(for: post)
                    .cardBackground()
                    .padding(.top, 30)
                
                intro(for: post)
                    .cardBackground()
                
                goToTheSourceButton(urlString: post.urlString)
                    .frame(maxWidth: 250)
                
                if !post.notes.isEmpty {
                    notes(for: post)
                        .cardBackground()
                }
            }
            .foregroundStyle(Color.mycolor.myAccent)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Header
    
    private func header(for post: Post) -> some View {
        VStack(spacing: 16) {
            Text(post.title)
                .font(.title2)
                .fontWeight(.semibold)
                .minimumScaleFactor(0.75)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            
            Text("@" + post.author)
                .font(.body)
                .frame(maxWidth: .infinity)
            
            headerBottomLine(for: post)
        }
        .padding(8)
    }
    
    @ViewBuilder
    private func headerBottomLine(for post: Post) -> some View {
        HStack(spacing: 3) {
            Text("\(post.studyLevel.displayName)")
                .fontWeight(.medium)
                .foregroundStyle(post.studyLevel.color)
                .itemBackground()

            if let date = post.postDate {
                Text("\(date.formatted(date: .numeric, time: .omitted))")
                    .itemBackground()
            }
            Text(post.postType.displayName)
                .itemBackground()
            Text(post.postPlatform.displayName)
                .itemBackground()
            
            Spacer()
            
            PostStatusIcons(post: post)
        }
        .font(.caption2)
    }
    
    // MARK: - Intro
    
    private func intro(for post: Post) -> some View {
        VStack(spacing: 0) {
            Text (post.intro)
                .font(introFont)
                .lineLimit(showFullIntro ? nil : introLinesLimit)
                .lineSpacing(introLineSpacing)
                .frame(minHeight: 55, alignment: .topLeading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onLineCountChanged(font: introFont, lineSpacing: introLineSpacing) { count in
                    lineCountIntro = count - 1
                }
                .padding(.top, 8)
            
            if lineCountIntro > introLinesLimit {
                
                HStack(alignment: .top) {
                    Spacer()
                    MoreLessTextButton(showText: $showFullIntro)
                }
            }
        }
        .padding()
    }
    
    // MARK: - Notes
    
    private func notes(for post: Post) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text("Notes")
                    .font(.headline)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 8)
                
                Spacer()
                
                if !showFullNotes {
                    MoreLessTextButton(showText: $showFullNotes)
                }
            }
            
            if showFullNotes {
                VStack {
                    Text(post.notes)
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 8)
                    
                    HStack(alignment: .top) {
                        Spacer()
                        MoreLessTextButton(showText: $showFullNotes)
                    }
                    .offset(y: -10)
                }
            }
        }
    }
    
    // MARK: - Source Button
    
    private func goToTheSourceButton(urlString: String) -> some View {
        LinkButtonURL(
            buttonTitle: "Go to the Source",
            urlString: urlString
        )
    }
    
    // MARK: - Toolbar
    
    @ToolbarContentBuilder
    private func toolbar(for post: Post) -> some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            
            if UIDevice.isiPhone {
                BackButtonView() { coordinator.pop() }
            }
            
            ShareLink(item: post.urlString) {
                Image(systemName: "square.and.arrow.up")
                    .font(.headline)
                    .foregroundStyle(Color.mycolor.myAccent)
                    .offset(y: -2)
                    .frame(width: 30, height: 30)
                    .background(.black.opacity(0.001))
            }
        }
        
        ToolbarItemGroup(placement: .topBarTrailing) {
            
            CircleStrokeButtonView(
                iconName: post.favoriteChoice == .yes ? "heart.slash" : "heart",
                iconFont: .headline,
                isShownCircle: false
            ) {
                vm.favoriteToggle(post)
            }
            
            CircleStrokeButtonView(
                iconName: isEditable ? "pencil" : "pencil.slash",
                isShownCircle: false
            ) {
                coordinator.push(.editPost(post))
            }
            .disabled(!isEditable)
        }
    }
    
    // MARK: - Bottom Tabs
    
    private var bottomTabsContainer: some View {
        ZStack {
            // Study Progress Selection Bar
            selectionTabView (
                icon: "hare",
                color: Color.mycolor.myGreen,
                alignment: .leading,
                isExpanded: showProgressTab,
                otherIsExpanded: showRatingTab,
                zIndexTab: zIndexBarProgress
            ){
                ProgressSelectionView { showProgressTab = false }
            } onTap: {
                maxHeight = 310
                zIndexBarProgress = 1
                zIndexBarRating = 0
                showProgressTab.toggle()
            }
            // Rating Selection Bar
            selectionTabView (
                icon: "star",
                color: Color.mycolor.myYellow,
                alignment: .trailing,
                isExpanded: showRatingTab,
                otherIsExpanded: showProgressTab,
                zIndexTab: zIndexBarRating
            ){
                RatingSelectionView { showRatingTab = false}
            } onTap: {
                maxHeight = 350
                zIndexBarRating = 1
                zIndexBarProgress = 0
                showRatingTab.toggle()
            }
        }
    }
    
    @ViewBuilder
    private func selectionTabView<Content: View>(
        icon: String,
        color: Color,
        alignment: Alignment,
        isExpanded: Bool,
        otherIsExpanded: Bool,
        zIndexTab: Double,
        @ViewBuilder content: () -> Content,
        onTap: @escaping () -> Void
    ) -> some View {
        ZStack (alignment: .top) {
            if UIDevice.isiPad {
                RoundedRectangle(cornerRadius: 30)
                    .fill(.bar)
                    .strokeBorder(
                        (isExpanded ? .clear : Color.mycolor.mySecondary.opacity(0.5)),
                        lineWidth: 1,
                        antialiased: true
                    )
            } else {
                UnevenRoundedRectangle(
                    topLeadingRadius: 30,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 30,
                    style: .continuous
                )
                .fill(.bar)
                .strokeBorder(
                    (isExpanded ? .clear : Color.mycolor.mySecondary.opacity(0.5)),
                    lineWidth: 1,
                    antialiased: true
                )
            }
            
            if isExpanded {
                content()
            } else {
                tabButton(icon: icon, onTap: onTap)
            }
        }
        .frame(height: isExpanded ? maxHeight : minHeight)
        .frame(maxWidth: isExpanded ? expandedWidth : tabWidth)
        .frame(maxWidth: .infinity, alignment: alignment)
        .padding(UIDevice.isiPad ? 8 : 0)
        .zIndex(zIndexTab)
        .offset(y: otherIsExpanded && !isExpanded ? maxHeight : 0)
        .animation(.easeInOut(duration: 0), value: isExpanded)
    }
    
    private func tabButton(icon: String, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                Image(systemName: "control")
                    .font(.headline)
                Image(systemName: icon)
                    .imageScale(.small)
                    .padding(8)
            }
            .foregroundColor(Color.mycolor.mySecondary)
            .padding(.top, 4)
            .padding(.horizontal, 30)
            .background(.black.opacity(0.001))
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Helpers
    
    private func updateWidths(for width: CGFloat) {
        tabWidth = width * widthRatio
        expandedWidth = width
    }
}

#Preview("Post Details with Mock Data") {
    let extendedPosts = PreviewData.samplePosts + DevData.postsForCloud
    let postsVM = PostsViewModel(
        dataSource: MockPostsDataSource(posts: extendedPosts)
    )
    
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppSyncState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    if let firstPost = PreviewData.samplePosts.first {
        NavigationStack {
            PostDetailsView(postId: firstPost.id)
                .environmentObject(postsVM)
                .environmentObject(AppCoordinator())
                .modelContainer(container)
        }
    } else {
        Text("No posts available")
            .padding()
    }
}
