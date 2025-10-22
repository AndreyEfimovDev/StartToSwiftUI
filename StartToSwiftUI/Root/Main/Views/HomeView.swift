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
    
    @State private var selectedPostId: UUID?
    @State private var selectedPost: Post?
    
    @State private var showDetailView: Bool = false
    @State private var showPreferancesView: Bool = false
    @State private var showAddPostView: Bool = false
    
    @State private var showOnTopButton: Bool = false
    @State private var isFilterButtonPressed: Bool = false
    
    let hiderText: String = "SwiftUI posts"
    
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
            viewBody
                .navigationTitle(hiderText)
                .navigationBarBackButtonHidden(true)
                .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
                .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            //                    .toolbarBackground(.visible, for: .navigationBar)
                .toolbar {
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
                .safeAreaInset(edge: .top) {
                    SearchBarView(searchText: $vm.searchText)
                }
                .navigationDestination(isPresented: $showDetailView) {
                    if let id = selectedPostId {
                        PostDetailsView(postId: id)
                    }
                }
            // toolbar button "preferances"
                .fullScreenCover(isPresented: $showPreferancesView) {
                    PreferencesView()
//                    {
//                        showPreferancesView.toggle()
//                    }
                }
            // toolbar button "+"
                .fullScreenCover(isPresented: $showAddPostView, content: {
                    AddEditPostSheet(post: nil)
                })
            // swipe action Edit post
                .fullScreenCover(item: $selectedPost, content: { post in
                    AddEditPostSheet(post: post)
                })
            // toolbar button "filters"
                .sheet(isPresented: $isFilterButtonPressed) {
                    FiltersSheetView(
                        isFilterButtonPressed: $isFilterButtonPressed
                    )
                    .presentationBackground(.clear)
                    .presentationDetents([.height(600)])
                    .presentationDragIndicator(.automatic)
                    .presentationCornerRadius(30)
                }
        } // NavigationStack
        .myBackground(colorScheme: colorScheme)
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
                                .background(
                                    GeometryReader { geo in
                                        Color.clear
                                            .onChange(of: geo.frame(in: .global).minY) { oldY, newY in
                                                // Track first element position
                                                if post.id == vm.filteredPosts.first?.id {
                                                    showOnTopButton = newY < 0
                                                }
                                            }
                                    }
                                )
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(
                                    EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0)
                                )
                                .onTapGesture {
                                    selectedPostId = post.id
                                    showDetailView.toggle()
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button("Delete", action: {
                                        vm.deletePost(post: post)
                                    })
                                    .tint(.red)
                                    Button ("Edit", action: {
                                        print("Edit button tapped for post: \(post.title)")
                                        selectedPost = post
                                    })
                                    .tint(.blue)
                                } //swipeActions
                                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                    Button (post.favoriteChoice == .yes ? "Unfavorite" : "Favorite") {
                                        print("Favourite button tapped for post: \(post.title)")
                                        vm.favoriteToggle(post: post)
                                    }
                                    .tint(post.favoriteChoice == .yes ? Color.mycolor.mySecondaryText : Color.mycolor.myYellow)
                                } //swipeActions
                        } // ForEach
                    } // List
                    .listStyle(.plain)
                    .scrollIndicators(.hidden)
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
}


#Preview {
    HomeView()
        .environmentObject(PostsViewModel())
}
