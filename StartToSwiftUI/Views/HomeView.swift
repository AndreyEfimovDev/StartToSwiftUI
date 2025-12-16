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
    @State private var showProgressSelectionView: Bool = false
    
    @State private var isFilterButtonPressed: Bool = false
    @State private var isShowingDeleteConfirmation: Bool = false
    private let limitToShortenTitle: Int = 30
    
    @State private var noticeButtonAnimation = false
    
    @State private var isDetectingLongPress: Bool = false
    @State private var isLongPressSuccess: Bool = false
    private let longPressDuration: Double = 0.5
    
    private var isShowingNoticeMessageButton: Bool {
        !noticevm.notices.filter({ $0.isRead == false }).isEmpty &&
        noticevm.isNotificationOn
    }
    private var isPerformingNoticeTask: Bool {
        vm.isTermsOfUseIsAccepted &&
        noticevm.isNotificationOn &&
        !noticevm.isUserNotified
    }
   
    // MARK: VIEW BODY
    
    var body: some View {
        GeometryReader { proxy in
            ScrollViewReader { scrollProxy in
                ZStack (alignment: .bottom) {
                    if vm.allPosts.isEmpty {
                        allPostsIsEmpty
                    } else if vm.filteredPosts.isEmpty {
                        filteredPostsIsEmpty
                    } else {
                        mainViewBody
                        onTopButton(proxy: scrollProxy)
                    }
                }
            }
            .disabled(isLongPressSuccess || isShowingDeleteConfirmation)
            .navigationTitle(vm.selectedCategory ?? "SwiftUI") // -> All Categories!!!
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
            .sheetForUIDeviceBoolean(isPresented: $showPreferancesView) {
                PreferencesView()
            }
            .sheetForUIDeviceBoolean(isPresented: $showNoticesView) {
                NavigationStack {
                    NoticesView()
                }
            }
            .sheetForUIDeviceBoolean(isPresented: $showAddPostView) {
                NavigationStack {
                    AddEditPostSheet(post: nil)
                }
            }
            .sheetForUIDeviceItem(item: $selectedPost) { selectedPostToEdit in
                NavigationStack {
                    AddEditPostSheet(post: selectedPostToEdit)
                }
            }
            .sheet(isPresented: $isFilterButtonPressed) {
                FiltersSheetView(
                    isFilterButtonPressed: $isFilterButtonPressed
                )
                .presentationBackground(.ultraThinMaterial)
                .presentationDetents([.height(600)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(30)
            }
            .overlay {
                if UIDevice.isiPhone {
                    if isLongPressSuccess {
                        RatingSelectionView() {
                            isLongPressSuccess = false
                        }
                        .frame(maxHeight: max(proxy.size.height / 3, 300))
                        .padding(.horizontal, 30)
                    }
                }
            }
            .overlay {
                if UIDevice.isiPhone {
                    if showProgressSelectionView {
                        ProgressSelectionView() {
                            showProgressSelectionView = false
                        }
                        .frame(maxHeight: max(proxy.size.height / 3, 300))
                        .padding(.horizontal, 30)
                    }
                }
            }
            .overlay {
                if isShowingDeleteConfirmation {
                    postDeletionConfirmation
                        .opacity(isShowingDeleteConfirmation ? 1 : 0)
                        .transition(.move(edge: .bottom))
                }
            }
            .onAppear {
                vm.isFiltersEmpty = vm.checkIfAllFiltersAreEmpty()
            }
            .task { // task
                if isPerformingNoticeTask {
                    try? await Task.sleep(nanoseconds: 3_000_000_000)
                    if noticevm.isSoundNotificationOn {
                        AudioServicesPlaySystemSound(1013) // 1005
                    }
                    noticeButtonAnimation = true
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    noticeButtonAnimation = false
                    noticevm.isUserNotified = true
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
                    .onLongPressGesture(
                        minimumDuration: longPressDuration,
                        maximumDistance: 50,
                        perform: {
                            vm.selectedRating = post.postRating
                            vm.selectedPostId = post.id
                            isLongPressSuccess = true
                        },
                        onPressingChanged: { isPressing in
                            if isPressing {
                                isDetectingLongPress = true
                            } else {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    if !isLongPressSuccess {
                                        isDetectingLongPress = false
                                    }
                                }
                            }
                        })
                    .onTapAndDoubleTap(
                        singleTap: {
                            vm.selectedPostId = post.id
                            showDetailView.toggle()
                        },
                        doubleTap: {
                            vm.selectedStudyProgress = post.progress
                            vm.selectedPostId = post.id
                            showProgressSelectionView = true
                        }
                    )
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button("Delete", systemImage: "trash") {
                            selectedPostToDelete = post
                            hapticManager.notification(type: .warning)
                            isShowingDeleteConfirmation = true
                        }
                        .tint(Color.mycolor.myRed)
                        
                        Button("Edit", systemImage: post.origin == .cloud  || post.origin == .statical ? "pencil.slash" : "pencil") {
                            selectedPost = post
                        }
                        .tint(Color.mycolor.myBlue)
                        .disabled(post.origin == .cloud || post.origin == .statical)
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button(post.favoriteChoice == .yes ? "Unmark" : "Mark" , systemImage: post.favoriteChoice == .yes ?  "heart.slash" : "heart") {
                            vm.favoriteToggle(post: post)
                        }.tint(post.favoriteChoice == .yes ? Color.mycolor.mySecondary : Color.mycolor.myRed.opacity(0.5))
                    }
            } // ForEach
            .listRowBackground(Color.clear)
            .listRowSeparatorTint(Color.mycolor.myAccent.opacity(0.35))
            .listRowSeparator(.hidden, edges: [.top])
            .listRowInsets(
                EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            )
        } // List
        .listStyle(.plain)
    }
    
    private var postDeletionConfirmation: some View {
        ZStack {
            Color.mycolor.myAccent.opacity(0.001)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    isShowingDeleteConfirmation = false
                }
            VStack(spacing: 8) {
                Text("Are you sure you want to delete the material?")
                    .font(.headline)
                    .foregroundColor(Color.mycolor.myRed)
                    .multilineTextAlignment(.center)
                    .padding(.vertical)
                Text(selectedPostToDelete?.title ?? "No material selected")
                    .font(.subheadline)
                    .foregroundColor(Color.mycolor.myAccent)
                    .minimumScaleFactor(0.75)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
                Text("This cannot be undone.")
                    .font(.caption2)
                    .foregroundColor(Color.mycolor.myAccent)
                    .padding(.vertical)
                ClearCupsuleButton(
                    primaryTitle: "Delete",
                    primaryTitleColor: Color.mycolor.myRed) {
                        withAnimation {
                            vm.deletePost(post: selectedPostToDelete ?? nil)
                            hapticManager.notification(type: .success)
                            isShowingDeleteConfirmation = false
                        }
                    }
                ClearCupsuleButton(
                    primaryTitle: "Cancel",
                    primaryTitleColor: Color.mycolor.myAccent) {
                        isShowingDeleteConfirmation = false
                    }
            } // VStack
            .padding()
            .background(.ultraThinMaterial)
            .menuFormater()
            .padding(.horizontal, 40)
        } // ZStack
    }

    private func shortenPostTitle(title: String) -> String {
           if title.count > limitToShortenTitle {
               return String(title.prefix(limitToShortenTitle - 3)) + "..."
           }
           return title
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
        if isShowingNoticeMessageButton {
            ToolbarItem(placement: .navigationBarLeading) {
                CircleStrokeButtonView(
                    iconName: "message",
                    isShownCircle: false)
                {
                    showNoticesView = true
                }
                .overlay {
                    Capsule()
                        .fill(Color.mycolor.myRed)
                        .frame(maxWidth: 15, maxHeight: 10)
                        .overlay {
                            Text("\(noticevm.notices.filter({ $0.isRead == false }).count)")
                                .font(.system(size: 8, weight: .bold, design: .default))
                                .foregroundStyle(Color.mycolor.myButtonTextPrimary)
                        }
                        .offset(x: 6, y: -9)
                }
                .background(
                    AnyView(
                        Circle()
                            .stroke(
                                Color.mycolor.myRed,
                                lineWidth: noticeButtonAnimation ? 3 : 0
                            )
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
            
            if UIDevice.isiPhone {
                CircleStrokeButtonView(
                    iconName: "plus",
                    isShownCircle: false)
                { showAddPostView.toggle() }
            }
            
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
 
    // MARK: Private functions
    
    private func postsForCategory(_ category: String?) -> [Post] {
        guard let category = category else {
            return vm.filteredPosts
        }
        return vm.filteredPosts.filter { $0.category == category }
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
