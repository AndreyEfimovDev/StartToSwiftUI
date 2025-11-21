//
//  HomwViewCopy.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.08.2025.
//  *** Combine

import SwiftUI
import AudioToolbox

struct HomeView: View {
    
    // MARK: PROPERTIES
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: PostsViewModel
    @EnvironmentObject private var noticevm: NoticeViewModel
    
    private let hapticManager = HapticService.shared
    
    @State private var selectedPostId: String?
    @State private var selectedPost: Post?
    @State private var selectedPostToDelete: Post?
    
    @State private var showDetailView: Bool = false
    @State private var showPreferancesView: Bool = false
    @State private var showAddPostView: Bool = false
    @State private var showTermsOfUse: Bool = false
    @State private var showNoticesView: Bool = false
    
    @State private var bellRinging = false
    
    @State private var showOnTopButton: Bool = false
    @State private var isFilterButtonPressed: Bool = false
    
    @State private var isShowingDeleteConfirmation: Bool = false
    
    // MARK: VIEW BODY
    
    var body: some View {
        ScrollViewReader { proxy in
            ZStack (alignment: .bottom) {
                if vm.allPosts.isEmpty {
                    allPostsIsEmpty
                } else if vm.filteredPosts.isEmpty {
                    filteredPostsIsEmpty
                } else {
                    
                    mainViewBody
                    
                    if showOnTopButton {
                        CircleStrokeButtonView(
                            iconName: "control", // control arrow.up
                            iconFont: .title,
                            imageColorPrimary: Color.mycolor.myBlue,
                            widthIn: 55,
                            heightIn: 55) {
                                withAnimation {
                                    if let firstID = vm.filteredPosts.first?.id {
                                        proxy.scrollTo(firstID, anchor: .top)
                                    }
                                }
                            }
                    } // if showButtonOnTop
                } // else-if
            } // ZStack
        } // ScrollViewReader
        .navigationTitle(vm.homeTitleName)
        .navigationBarBackButtonHidden(true)
        .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbar {
            if vm.isTermsOfUseAccepted {
                toolbarForMainViewBody()
            }
        }
        .safeAreaInset(edge: .top) {
            SearchBarView()
        }
        .navigationDestination(isPresented: $showDetailView) {
            if let id = selectedPostId {
                withAnimation {
                    PostDetailsView(postId: id)
                }
            }
        }
        .navigationDestination(isPresented: $showPreferancesView) {
            PreferencesView()
        }
        .navigationDestination(isPresented: $showNoticesView) {
            NoticesView()
        }
        .navigationDestination(isPresented: $showAddPostView) {
            AddEditPostSheet(post: nil)
        }
        .navigationDestination(item: $selectedPost) {selectedPostToEdit in
            AddEditPostSheet(post: selectedPostToEdit)
        }
        .sheet(isPresented: $isFilterButtonPressed) {
            FiltersSheetView(
                isFilterButtonPressed: $isFilterButtonPressed
            )
            .presentationBackground(.clear)
            .presentationDetents([.height(600)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(30)
        }
        .task {
            vm.isFiltersEmpty = vm.checkIfAllFiltersAreEmpty()
            
            if noticevm.isNotificationOn {
                if  !noticevm.isUserNotified {
                    try? await Task.sleep(nanoseconds: 5_000_000_000)
                    if noticevm.isSoundNotificationOn {
                        AudioServicesPlaySystemSound(1013) // 1005
                    }
                    
                    withAnimation(
                        .spring(
                            response: 0.3,
                            dampingFraction: 0.3
                        )
                        .repeatCount(5, autoreverses: false)
                    ) {
                        bellRinging = true
                    }
                    
                    try? await Task.sleep(nanoseconds: 2_500_000_000)
                    bellRinging = false
                    noticevm.isUserNotified = true
                }
            }
        }
        .overlay {
            // Accept Terms of Use at the first launch
            if !vm.isTermsOfUseAccepted {
                welcomeAtFirstLauch
            }
        }
    }
    
    // MARK: Subviews
    
    private var mainViewBody: some View {
        List {
            ForEach(vm.filteredPosts) { post in
                PostRowView(post: post)
                    .id(post.id)
                    .background(trackingFistPostInList(post: post))
                    .padding(.bottom, 4)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(
                        EdgeInsets(top: 0, leading: 1, bottom: 1, trailing: 1)
                    )
                    .onTapGesture {
                        selectedPostId = post.id
                        showDetailView.toggle()
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button("Delete", systemImage: "trash") {
                            selectedPostToDelete = post
                            hapticManager.notification(type: .warning)
                            isShowingDeleteConfirmation = true
                        }.tint(Color.mycolor.myRed)
                        
                        Button("Edit", systemImage: post.origin == .cloud  || post.origin == .statical ? "pencil.slash" : "pencil") {
                            selectedPost = post
                        }
                        .tint(Color.mycolor.myButtonBGBlue)
                        .disabled(post.origin == .cloud || post.origin == .statical)
                    } // right side swipe action buttonss
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button(post.favoriteChoice == .yes ? "Unmark" : "Mark" , systemImage: post.favoriteChoice == .yes ?  "heart.slash.fill" : "heart.fill") {
                            vm.favoriteToggle(post: post)
                        }
                        .tint(post.favoriteChoice == .yes ? Color.mycolor.mySecondaryText : Color.mycolor.myYellow)
                    } // left side swipe action buttons
            } // ForEach
            .confirmationDialog(
                "Are you sure you want to delete this post?",
                isPresented: $isShowingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete the post", role: .destructive) {
                    withAnimation {
                        vm.deletePost(post: selectedPostToDelete ?? nil)
                        hapticManager.notification(type: .success)
                        isShowingDeleteConfirmation = false
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("It will be impossible to undo the deletion.")
            }
            // .buttonStyle(.plain) // it makes the buttons accessable through the List elements
        } // List
        .listStyle(.plain)
        .background(Color.mycolor.myBackground)
        
    }
    
    private var allPostsIsEmpty: some View {
        ContentUnavailableView(
            "No Posts",
            systemImage: "tray.and.arrow.down",
            description: Text("Posts will appear here when you create your own or download a curated collection.")
        )
    }
    
    private var filteredPostsIsEmpty: some View {
        ContentUnavailableView(
            "No Results matching your search criteria",
            systemImage: "magnifyingglass",
            description: Text("Check the spelling or try a new search.")
        )
    }
    
    
    @ViewBuilder
    private func trackingFistPostInList(post: Post) -> some View {
        GeometryReader { geo in
            Color.clear
                .onChange(of: geo.frame(in: .global).minY) { oldY, newY in
                    // Track first element position in the List
                    if post.id == vm.filteredPosts.first?.id {
                        showOnTopButton = newY < 0
                    }
                }
        }
    }
    
    @ToolbarContentBuilder
    private func toolbarForMainViewBody() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            CircleStrokeButtonView(
                iconName: "gearshape",
                isShownCircle: false)
            {
                showPreferancesView.toggle()
            }
        }
        if noticevm.isNewNotices && noticevm.isNotificationOn {
            ToolbarItem(placement: .navigationBarLeading) {
                
                ZStack {
                    CircleStrokeButtonView(
                        iconName: "bell",
                        isShownCircle: false)
                    {
                        showNoticesView = true
                    }
                    .rotationEffect(.degrees(bellRinging ? 15 : -15))
                    
                    Text("\(noticevm.notices.filter { $0.isRead == false }.count)")
                        .font(.system(size: 8, weight: .bold, design: .default))
                        .foregroundStyle(Color.mycolor.myButtonTextPrimary)
                        .frame(maxWidth: 15)
                        .background(Color.mycolor.myRed, in: .capsule)
                        .offset(x: 7, y: -7)
                }
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            CircleStrokeButtonView(
                iconName: "plus",
                isShownCircle: false)
            {
                showAddPostView.toggle()
            }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            CircleStrokeButtonView(
                iconName: "line.3.horizontal.decrease",
                isIconColorToChange: !vm.isFiltersEmpty,
                isShownCircle: false)
            {
                isFilterButtonPressed.toggle()}
        }
    }
    
    private var welcomeAtFirstLauch: some View {
        ZStack {
            Color.mycolor.myBackground
                .ignoresSafeArea()
            NavigationStack {
                ScrollView {
                    VStack {
                        
                        Text("""
                    This application is created for educational purposes and helps organise links to learning SwiftUI materials.
                     
                    **It is importand to understand:**
                     
                    - The app stores only links to materials available from public sources.
                    - All content belongs to its respective authors.
                    - The app is free and intended for non-commercial use.
                    - Users are responsible for respecting copyright when using materials.
                     
                    **For each material, you have ability to save:**
                    
                    - Direct link to the original source.
                    - Author's name.
                    - Source (website, YouTube, etc.).
                    - Publication date (if known).
                                         
                    To use this application, you need to agree to **Terms of Use**.
                    """
                        )
                        .multilineTextAlignment(.leading)
                        .textFormater()
                        .padding(.horizontal)
                        
                        Button {
                            showTermsOfUse = true
                        } label: {
                            Text("Terms of Use")
                                .font(.title)
                        }
                        .tint(Color.mycolor.myBlue)
                        .padding()
                        .navigationDestination(isPresented: $showTermsOfUse) {
                            TermsOfUse() {
                                dismiss()
                            }
                        }
                    } // VStack
                } // ScrollView
                .navigationTitle("Affirmation")
            } // NavigationStack
        } // ZStack
    }
    
    private var deletionConfirmationDialog: some View {
        ZStack {
            Color.mycolor.myAccent.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("DELETE THE POST?")
                    .font(.headline)
                    .bold()
                    .foregroundColor(Color.mycolor.myRed)
                
                Text("Please confirm the action.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.mycolor.myAccent.opacity(0.8))
                ClearCupsuleButton(
                    primaryTitle: "Yes",
                    primaryTitleColor: Color.mycolor.myRed) {
                        withAnimation {
                            vm.deletePost(post: selectedPostToDelete ?? nil)
                            hapticManager.notification(type: .success)
                            isShowingDeleteConfirmation = false
                        }
                    }
                
                ClearCupsuleButton(
                    primaryTitle: "No",
                    primaryTitleColor: Color.mycolor.myAccent) {
                        withAnimation {
                            isShowingDeleteConfirmation = false
                        }
                    }
            }
            .padding()
            .background(.regularMaterial)
            .cornerRadius(30)
            .padding(.horizontal, 40)
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .environmentObject(PostsViewModel())
    .environmentObject(NoticeViewModel())
}
