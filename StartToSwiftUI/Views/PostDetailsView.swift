//
//  PostDetailsView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.08.2025.
//

import SwiftUI
import SwiftData

struct PostDetailsView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var vm: PostsViewModel
    @EnvironmentObject private var coordinator: NavigationCoordinator
    
    private let hapticManager = HapticService.shared
    
    let postId: String
    
    private var post: Post? {
        vm.allPosts.first(where: { $0.id == postId })
        //                        PreviewData.samplePost3
    }
    
    @State private var showSafariView = false
    @State private var showFullIntro: Bool = false
    @State private var showFullFreeTextField: Bool = false
    @State private var showEditPostView: Bool = false
    @State private var showAddPostView: Bool = false
    @State private var showRatingSelectionView: Bool = false
    
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
    private var minHeight: CGFloat {
        if UIDevice.isiPad { 60 }
        else { 75 }
    }
    @State private var maxHeight: CGFloat = 350
    private let widthRatio: CGFloat = 0.55
    @State private var tabWidth: CGFloat = 0
    @State private var expandedWidth: CGFloat = 0
    
    var body: some View {
        GeometryReader { proxy in
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
                                .frame(maxWidth: 250)
                            
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
                    .sheetForUIDeviceItem(item: $coordinator.showEditPost) { post in
                        NavigationStack {
                            AddEditPostSheet(post: post)
                        }
                    }
                    .sheetForUIDeviceBoolean(isPresented: $coordinator.showAddPost) {
                        NavigationStack {
                            AddEditPostSheet(post: nil)
                        }
                    }
                } else {
                    Text("Post is not found")
                }
            }
            .onAppear {
                tabWidth = proxy.size.width * widthRatio
                expandedWidth = proxy.size.width
            }
            .onChange(of: proxy.size.width, { oldValue, newValue in
                tabWidth = newValue * widthRatio
                expandedWidth = newValue
            })
            .safeAreaInset(edge: .bottom) {
                bottomTabsContainer
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
    
    private var bottomTabsContainer: some View {
        ZStack {
            // Study Progress Selection Bar
            selectionTabView (
                icon: "hare", color: .green, alignment: .leading,
                isExpanded: showProgressTab,
                otherIsExpanded: showRatingTab,
                zIndexTab: zIndexBarProgress,
                content: {
                    ProgressSelectionView {
                        showProgressTab = false
                    }
                }) {
                    maxHeight = 310
                    zIndexBarProgress = 1
                    zIndexBarRating = 0
                    showProgressTab.toggle()
                }
            // Rating Selection Bar
            selectionTabView (
                icon: "star", color: .yellow, alignment: .trailing,
                isExpanded: showRatingTab,
                otherIsExpanded: showProgressTab,
                zIndexTab: zIndexBarRating,
                content: {
                    RatingSelectionView {
                        showRatingTab = false
                    }
                }) {
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
            .fill(.bar)
            .strokeBorder(
                (isExpanded ? .clear : Color.mycolor.mySecondary.opacity(0.5)),
                lineWidth: 1,
                antialiased: true
            )
            
            Button {
                completion()
            } label: {
                VStack(spacing: 0) {
                    if !isExpanded {
                        Image(systemName: "control")
                            .font(.headline)
                        Image(systemName: icon)
                            .imageScale(.small)
                            .padding(8)
                    }
                }
                .foregroundColor(Color.mycolor.mySecondary)
                .padding(.top, 4)
                .padding(.horizontal, 30)
                .background(.black.opacity(0.001))
            }
            .buttonStyle(.plain)
            .opacity(isExpanded ? 0 : 1)
            .disabled(isExpanded)
            
            
            if isExpanded {
                content()
            }
        }
        .frame(height: isExpanded ? maxHeight : minHeight)
        .frame(maxWidth: isExpanded ? expandedWidth : tabWidth)
        .frame(maxWidth: .infinity, alignment: alignment)
        .zIndex(zIndexTab)
        .offset(y: otherIsExpanded && !isExpanded ? maxHeight : 0)
        .animation(.bouncy(duration: 0.3), value: isExpanded)
    }
    
    // MARK: Subviews
    
    @ToolbarContentBuilder
    private func toolbarForPostDetails(validPost: Post) -> some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            
            if UIDevice.isiPhone {
                BackButtonView() {
//                    dismiss()
                    coordinator.pop()
                }
            }
            
            if UIDevice.isiPad {
                CircleStrokeButtonView(
                    iconName: "plus",
                    isShownCircle: false
                ){
//                    showAddPostView.toggle()
                    coordinator.presentAddPost()
                }
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
            
            CircleStrokeButtonView(
                iconName: validPost.favoriteChoice == .yes ? "heart.slash" : "heart",
                iconFont: .headline,
                isShownCircle: false)
            {
                vm.favoriteToggle(post: validPost)
                hapticManager.impact(style: .light)
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
                .minimumScaleFactor(0.75)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("@" + post.author)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .center)
            
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
                        Image(systemName: "heart")
                            .foregroundStyle(Color.mycolor.myRed)
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
        let container = try! ModelContainer(for: Post.self, Notice.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let viewModel = PostsViewModel(modelContext: context)
        
        viewModel.allPosts = PreviewData.samplePosts
        return viewModel
    }
    
}

#Preview {
    
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppSyncState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    
    let vm = PostsViewModel(modelContext: context)
    
    NavigationStack {
        PostDetailsPreView()
            .environmentObject(vm)
            .environmentObject(NavigationCoordinator())
    }
}
