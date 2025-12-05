//
//  HomwViewCopy.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.08.2025.
//  

import SwiftUI
import AudioToolbox

struct HomeView: View {
    
    // MARK: PROPERTIES
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: PostsViewModel
    @EnvironmentObject private var noticevm: NoticeViewModel

    private let hapticManager = HapticService.shared
    
    let selectedCategory: String?
    
    @State private var selectedPost: Post?
    @State private var selectedPostToDelete: Post?
    
    @State private var showDetailView: Bool = false
    @State private var showPreferancesView: Bool = false
    @State private var showAddPostView: Bool = false
    @State private var showNoticesView: Bool = false
    @State private var showOnTopButton: Bool = false
    
    @State private var isFilterButtonPressed: Bool = false
    @State private var isShowingDeleteConfirmation: Bool = false
    
    @State private var noticeButtonAnimation = false
    
    private func postsForCategory(_ category: String?) -> [Post] {
        guard let category = category else {
            return vm.filteredPosts
        }
        return vm.filteredPosts.filter { $0.category == category }
    }
    
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
                    onTopButton(proxy: proxy)
                }
            }
        }
        .navigationTitle(vm.selectedCategory ?? "All Categories")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
                toolbarForMainViewBody()
        }
        .safeAreaInset(edge: .top) {
            SearchBarView()
        }
        .navigationDestination(isPresented: $showDetailView) {
            if let id = vm.selectedPostId {
                withAnimation {
                    PostDetailsView(postId: id)
                }
            }
        }
        .sheet(isPresented: $showPreferancesView) {
            PreferencesView()
        }
        .sheet(isPresented: $showNoticesView) {
            NavigationStack {
                NoticesView()
            }
        }
        .sheet(isPresented: $showAddPostView) {
            NavigationStack {
                AddEditPostSheet(post: nil)
            }
        }
        .sheet(item: $selectedPost) { selectedPostToEdit in
            NavigationStack {
                AddEditPostSheet(post: selectedPostToEdit)
            }
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
            
            if vm.isTermsOfUseIsAccepted {
                if noticevm.isNotificationOn {
                    if  !noticevm.isUserNotified {
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
//                        if noticevm.isSoundNotificationOn {
//                            AudioServicesPlaySystemSound(1013) // 1005
//                        }
                        noticeButtonAnimation = true
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                        noticeButtonAnimation = false
                        noticevm.isUserNotified = true
                    }
                }
            }
        }
    }
    
    // MARK: Subviews
    
    private var mainViewBody: some View {
        List {
            ForEach(postsForCategory(selectedCategory)) { post in
                PostRowView(post: post)
                    .id(post.id)
                    .background(trackingFistPostInList(post: post))
                    .background(.black.opacity(0.001))
                    .onTapGesture {
                        vm.selectedPostId = post.id
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
                        .foregroundStyle(Color.mycolor.myAccent)
                        .tint(post.favoriteChoice == .yes ? Color.mycolor.myButtonTextPrimary : Color.mycolor.myYellow)
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
            .listRowBackground(Color.clear)
            .listRowSeparatorTint(Color.mycolor.myAccent.opacity(0.35))
            .listRowSeparator(.hidden, edges: [.top])
            .listRowInsets(
                EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            )
        } // List
        .listStyle(.plain)
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
        if !noticevm.notices.filter({ $0.isRead == false }).isEmpty && noticevm.isNotificationOn {
            ToolbarItem(placement: .navigationBarLeading) {
                CircleStrokeButtonView(
                    iconName: "message",
                    isShownCircle: false)
                {
                    showNoticesView = true
                }
                .overlay(alignment: .topTrailing) {
                    Capsule()
                        .fill(Color.mycolor.myRed)
                        .frame(maxWidth: 20, maxHeight: 15)
                        .overlay {
                            Text("\(noticevm.notices.filter({ $0.isRead == false }).count)")
                                .font(.system(size: 8, weight: .bold, design: .default))
                                .foregroundStyle(Color.mycolor.myButtonTextPrimary)
                        }
                }
                .background(
                    AnyView(
                        Circle()
                            .stroke(Color.mycolor.myRed, lineWidth: noticeButtonAnimation ? 3 : 0)
                            .scaleEffect(noticeButtonAnimation ? 1.2 : 0.8)
                            .opacity(noticeButtonAnimation ? 0.0 : 1.0)
                    )
                    .animation(
                        noticeButtonAnimation
                        ? .easeOut(duration: 1.0)
                        : .none,
                        value: noticeButtonAnimation
                    )
                )
            }
        }
        
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            CircleStrokeButtonView(
                iconName: "plus",
                isShownCircle: false)
            { showAddPostView.toggle() }
            
            CircleStrokeButtonView(
                iconName: "line.3.horizontal.decrease",
                isIconColorToChange: !vm.isFiltersEmpty,
                isShownCircle: false)
            { isFilterButtonPressed.toggle() }
        }
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
    
    @ViewBuilder
    private func onTopButton(proxy: ScrollViewProxy) -> some View {
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
        }
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
        HomeView(selectedCategory: "SwiftUI")
    }
    .environmentObject(PostsViewModel())
    .environmentObject(NoticeViewModel())
}


//     .buttonStyle(.plain) // it makes the buttons accessable through the List elements
