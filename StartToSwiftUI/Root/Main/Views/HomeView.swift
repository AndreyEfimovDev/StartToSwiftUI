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
    
    private let hapticManager = HapticManager.shared
    
    @State private var selectedPostId: UUID?
    @State private var selectedPost: Post?
    @State private var selectedPostToDelete: Post?
    
    @State private var showDetailView: Bool = false
    @State private var showPreferancesView: Bool = false
    @State private var showAddPostView: Bool = false
    
    @State private var showOnTopButton: Bool = false
    @State private var isFilterButtonPressed: Bool = false
    
    @State private var isShowingDeleteConfirmation: Bool = false
    @State private var isPostsUpdateAvailable: Bool = false
    
    private var searchedPosts: [Post] {
        if vm.searchText.isEmpty {
            return vm.filteredPosts
        } else {
            let searchedPosts = vm.filteredPosts.filter( {
                $0.title.lowercased().contains(vm.searchText.lowercased()) ||
                $0.intro.lowercased().contains(vm.searchText.lowercased())  ||
                $0.author.lowercased().contains(vm.searchText.lowercased()) ||
                $0.additionalText.lowercased().contains(vm.searchText.lowercased())
            } )
            return searchedPosts
        }
    }
    
    // MARK: VIEW BODY
    
    var body: some View {
        NavigationStack {
            ZStack {
                viewBody
                    .navigationTitle("SwiftUI posts")
                    .navigationBarBackButtonHidden(true)
                    .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
                    .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
                    .toolbar { toolbarForMainViewBody() }
                    .safeAreaInset(edge: .top) {
                        SearchBarView(searchText: $vm.searchText)
                    }
                    .navigationDestination(isPresented: $showDetailView) {
                        if let id = selectedPostId {
                            PostDetailsView(postId: id)
                        }
                    }
                    .fullScreenCover(isPresented: $showPreferancesView) {
                        PreferencesView()
                    }
                    .fullScreenCover(isPresented: $showAddPostView, content: {
                        AddEditPostSheet(post: nil)
                    })
                    .fullScreenCover(item: $selectedPost, content: { post in
                        AddEditPostSheet(post: post)
                    })
                    .sheet(isPresented: $isFilterButtonPressed) {
                        FiltersSheetView(
                            isFilterButtonPressed: $isFilterButtonPressed
                        )
                        .presentationBackground(.clear)
                        .presentationDetents([.height(600)])
                        .presentationDragIndicator(.automatic)
                        .presentationCornerRadius(30)
                    }
                // Updates available dialog
                if isPostsUpdateAvailable && vm.isNotification {
                    updateAvailableDialog
                }
                // Deletion confirmation dialog
                if isShowingDeleteConfirmation {
                    deletionConfirmationDialog
                }
            } // ZStack
        } // NavigationStack
        .onAppear {
            vm.isFiltersEmpty = vm.checkIfAllFiltersAreEmpty()
        }
    }
    
    
    // MARK: VAR VIEWS
    
    private var viewBody: some View {
        ScrollViewReader { proxy in
            ZStack (alignment: .bottomTrailing) {
                if searchedPosts.isEmpty {
                    ContentUnavailableView(
                        "No Posts Stored",
                        systemImage: "tray.and.arrow.down",
                        description: Text("You should go to Preferences to upload posts")
                    )
                } else {
                    List {
                        ForEach(searchedPosts) { post in
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
                                    }
                                    .tint(Color.mycolor.myRed)
                                    
                                    Button("Edit", systemImage: "pencil") {
                                        selectedPost = post
                                    }
                                    .tint(Color.mycolor.myBlue)
                                    
                                } //swipeActions
                                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                    Button(post.favoriteChoice == .yes ? "Unmark" : "Mark" , systemImage: "star.fill") {
                                        vm.favoriteToggle(post: post)
                                    }
                                    .tint(post.favoriteChoice == .yes ? Color.mycolor.mySecondaryText : Color.mycolor.myYellow)
                                } //swipeActions
                        } // ForEach
                        //                        .buttonStyle(.plain) // it makes the buttons accessable
                    } // List
                    .listStyle(.plain)
                    //                    .scrollIndicators(.hidden)
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
    
    @ViewBuilder
    private func trackingFistPostInList(post: Post) -> some View {
        GeometryReader { geo in
            Color.clear
                .onChange(of: geo.frame(in: .global).minY) { oldY, newY in
                    // Track first element position
                    if post.id == vm.filteredPosts.first?.id {
                        showOnTopButton = newY < 0
                    }
                }
        }
    }
    
//    @ToolbarContentBuilder
    private func toolbarForMainViewBody() -> some ToolbarContent {
        Group {
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
    }
    
    private var updateAvailableDialog: some View {
        VStack {
            ZStack {
                Color.mycolor.myAccent.opacity(0.4)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Posts update is available")
                        .textCase(.uppercase)
                        .font(.headline)
                        .bold()
                        .foregroundColor(Color.mycolor.myRed)
                    
                    Text("You can go to Preferenses for updates.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.mycolor.myAccent.opacity(0.8))
                    ClearCupsuleButton(
                        primaryTitle: "OK",
                        primaryTitleColor: Color.mycolor.myGreen) {
                            vm.isPostsUpdateAvailable = false
                            isPostsUpdateAvailable = false
                        }
                }
                .padding()
                .background(.regularMaterial)
                .cornerRadius(30)
                .padding(.horizontal, 40)
            }
        } // VStack: Deletion confirmation dialog
    }
    
    private var deletionConfirmationDialog: some View {
        VStack {
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
                        primaryTitle: "Yes",
                        primaryTitleColor: Color.mycolor.myRed) {
                            vm.deletePost(post: selectedPostToDelete ?? nil)
                            hapticManager.notification(type: .success)
                            isShowingDeleteConfirmation = false
                        }
                    
                    ClearCupsuleButton(
                        primaryTitle: "No",
                        primaryTitleColor: Color.mycolor.myGreen) {
                            isShowingDeleteConfirmation = false
                        }
                }
                .padding()
                .background(.regularMaterial)
                .cornerRadius(30)
                .padding(.horizontal, 40)
            }
        } // VStack: Deletion confirmation dialog
    }
}


#Preview {
    HomeView()
        .environmentObject(PostsViewModel())
}
