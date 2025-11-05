//
//  HomwViewCopy.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.08.2025.
//  *** Combine

import SwiftUI

struct HomeView: View {
    
    // MARK: PROPERTIES
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var vm: PostsViewModel
    
    private let hapticManager = HapticService.shared
    
    @State private var selectedPostId: UUID?
    @State private var selectedPost: Post?
    @State private var selectedPostToDelete: Post?
    
    @State private var showDetailView: Bool = false
    @State private var showPreferancesView: Bool = false
    @State private var showAddPostView: Bool = false
    
    @State private var showOnTopButton: Bool = false
    @State private var isFilterButtonPressed: Bool = false
    
    @State private var isShowingDeleteConfirmation: Bool = false
    @State private var isAnyChanges: Bool = false

//    
//    private var searchedPosts: [Post] {
//        if vm.searchText.isEmpty {
//            return vm.filteredPosts
//        } else {
//            let searchedPosts = vm.filteredPosts.filter( {
//                $0.title.lowercased().contains(vm.searchText.lowercased()) ||
//                $0.intro.lowercased().contains(vm.searchText.lowercased())  ||
//                $0.author.lowercased().contains(vm.searchText.lowercased()) ||
//                $0.additionalText.lowercased().contains(vm.searchText.lowercased())
//            } )
//            return searchedPosts
//        }
//    }
    
    // MARK: VIEW BODY
    
    var body: some View {
        NavigationStack {
            ZStack {
                mainViewBody
                    .navigationTitle(vm.homeTitleName)
                    .navigationBarBackButtonHidden(true)
                    .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
                    .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
                    .toolbar { toolbarForMainViewBody() }
                    .safeAreaInset(edge: .top) {
                        SearchBarView()
//                        SearchBarView(searchText: $vm.searchText)
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
                        .presentationDetents([.height(550)])
                        .presentationDragIndicator(.visible)
                        .presentationCornerRadius(30)
                    }
            } // ZStack
        } // NavigationStack
        .onAppear {
            vm.isFiltersEmpty = vm.checkIfAllFiltersAreEmpty()
        }
        .overlay {
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
                                    Button(post.favoriteChoice == .yes ? "Unmark" : "Mark" , systemImage: "star.fill") {
                                        vm.favoriteToggle(post: post)
                                    }
                                    .tint(post.favoriteChoice == .yes ? Color.mycolor.mySecondaryText : Color.mycolor.myYellow)
                                } // lefut side swipe action buttonss
                        } // ForEach
                        // .buttonStyle(.plain) // it makes the buttons accessable
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
                            .padding(.trailing, 35)
                    } // if showButtonOnTop
                }
            } // ZStack
        } // ScrollViewReader
    }
    
    private var postsIsEmpty: some View {
        ContentUnavailableView(
            "No Posts Stored",
            systemImage: "tray.and.arrow.down",
            description: Text("You should go to Preferences to upload posts")
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
                    
                    Text("You can go to Preferenses for updates.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.mycolor.mySecondaryText)
                    ClearCupsuleButton(
                        primaryTitle: "OK",
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
                    
                    Text("Please confirm the deletion of the post?")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.mycolor.myAccent.opacity(0.8))
                    ClearCupsuleButton(
                        primaryTitle: "YES",
                        primaryTitleColor: Color.mycolor.myRed) {
                            vm.deletePost(post: selectedPostToDelete ?? nil)
                            hapticManager.notification(type: .success)
                            isShowingDeleteConfirmation = false
                        }
                    
                    ClearCupsuleButton(
                        primaryTitle: "Cancel",
                        primaryTitleColor: Color.mycolor.myAccent) {
                            isShowingDeleteConfirmation = false
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
