//
//  HomwViewCopy.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.08.2025.
//  *** Combine

import SwiftUI

struct HomeView: View {
    
    // MARK: PROPERTIES
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: PostsViewModel
    
    private let hapticManager = HapticService.shared
    
    @State private var selectedPostId: String?
    @State private var selectedPost: Post?
    @State private var selectedPostToDelete: Post?
    
    @State private var showDetailView: Bool = false
    @State private var showPreferancesView: Bool = false
    @State private var showAddPostView: Bool = false
    @State private var showTermsOfUse: Bool = false
    
    
    @State private var showOnTopButton: Bool = false
    @State private var isFilterButtonPressed: Bool = false
    
    @State private var isShowingDeleteConfirmation: Bool = false
//    @State private var isAnyChanges: Bool = false
    
    // MARK: VIEW BODY
    
    var body: some View {
        NavigationStack {
            ZStack {
                mainViewBody
                    .navigationTitle(vm.homeTitleName)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarBackButtonHidden(true)
                    .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
                    .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
                    .toolbar { toolbarForMainViewBody() }
                    .safeAreaInset(edge: .top) {
                        SearchBarView()
                    }
                    .navigationDestination(isPresented: $showDetailView) {
                        if let id = selectedPostId {
                            PostDetailsView(postId: id)
                        }
                    }
                    .fullScreenCover(isPresented: $showPreferancesView) {
                        PreferencesView()
                    }
                    .fullScreenCover(isPresented: $showAddPostView) {
                        AddEditPostSheet(post: nil)
                    }
                    .fullScreenCover(item: $selectedPost) { post in
                        AddEditPostSheet(post: post)
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
            } // ZStack
        } // NavigationStack
        .onAppear {
            vm.isFiltersEmpty = vm.checkIfAllFiltersAreEmpty()
        }
        .overlay {
            // Affirmation at the first launch to accept Terms of Use
            if !vm.isTermsOfUseAccepted {
                welcomeAtFirstLauch
            }
            // Updates available notification
            if vm.isPostsUpdateAvailable && vm.isNotification {
                updateAvailableDialog
            }
            // Deletion confirmation dialog
            if isShowingDeleteConfirmation {
                deletionConfirmationDialog
            }
        }
    }
    
    // MARK: Subviews
    
    private var mainViewBody: some View {
        ScrollViewReader { proxy in
            ZStack (alignment: .bottomTrailing) {
                if vm.allPosts.isEmpty {
                    postsIsEmpty
                } else {
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
                                    
                                    Button("Edit", systemImage: "pencil") {
                                        selectedPost = post
                                    }
                                    .tint(Color.mycolor.myButtonBGBlue)
                                } // right side swipe action buttonss
                                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                    Button(post.favoriteChoice == .yes ? "Unmark" : "Mark" , systemImage: post.favoriteChoice == .yes ?  "heart.slash.fill" : "heart.fill") {
                                        vm.favoriteToggle(post: post)
                                    }
                                    .tint(post.favoriteChoice == .yes ? Color.mycolor.mySecondaryText : Color.mycolor.myYellow)
                                } // left side swipe action buttons
                        } // ForEach
                        // .buttonStyle(.plain) // it makes the buttons accessable through the List elements
                    } // List
                    .listStyle(.plain)
                    .background(Color.mycolor.myBackground)
                    
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
                            .frame(maxWidth: .infinity, alignment: .center)
//                            .padding(.trailing, 35)
                    } // if showButtonOnTop
                } // else-if
            } // ZStack
        } // ScrollViewReader
    }
    
    private var postsIsEmpty: some View {
        ContentUnavailableView(
            "No Posts Stored",
            systemImage: "tray.and.arrow.down",
            description: Text("You can create your own posts manually or go to Preferences to download a curated collection of links to SwiftUI tutorials and articles compiled by the developer from open sources.")
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
            Color.mycolor.myAccent.opacity(0.4)
                .ignoresSafeArea()
            NavigationStack {
                ScrollView {
                    VStack {
                        
                        Text("""
                    This application is created for educational purposes and helps organise links to learning SwiftUI materials.
                     
                    **It is importand to understand:**
                     
                    ✓ The app stores only links to materials available from public sources.
                    ✓ All content belongs to its respective authors.
                    ✓ The app is free and intended for non-commercial use.
                    ✓ Users are responsible for respecting copyright when using materials.
                     
                    **For each material, you have ability to save:**
                    
                    - Direct link to the original source.
                    - Author's name.
                    - Source (website, YouTube, etc.).
                    - Publication date (if known).
                                         
                    To use this application, you need to agree to **Terms of Use**.
                    """
                        )
                        .multilineTextAlignment(.leading)
                        .managingPostsTextFormater()
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
    
    private var updateAvailableDialog: some View {
        ZStack {
            Color.mycolor.myAccent.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Posts update is available")
                    .textCase(.uppercase)
                    .font(.headline)
                    .bold()
                    .foregroundColor(Color.mycolor.myAccent)
                
                Text("You can go to Preferences for updates.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.mycolor.mySecondaryText)
                ClearCupsuleButton(
                    primaryTitle: "OK, got it",
                    primaryTitleColor: Color.mycolor.myBlue) {
                        vm.isPostsUpdateAvailable = false
                    }
            }
            .padding()
            .background(.regularMaterial)
            .cornerRadius(30)
            .padding(.horizontal, 40)
        }
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
    HomeView()
        .environmentObject(PostsViewModel())
}
