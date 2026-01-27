//
//  RatingMenuSelectionView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 06.12.2025.
//

import SwiftUI
import SwiftData

struct RatingSelectionView: View {
    
    @EnvironmentObject private var vm: PostsViewModel
    @State private var isShowingView: Bool = false

    let completion: () -> Void
        
    init(completion: @escaping () -> Void) {
        self.completion = completion
    }

    var body: some View {
        Group {
            if let post = vm.allPosts.first(where: { $0.id == vm.selectedPostId}) {
                VStack {
                    ZStack(alignment: .topTrailing) {
                        xmarkButton
                        .padding()
                        .zIndex(1)
                        
                        VStack {
                            Text("Rate Material")
                                .font(.title3).bold()
                                .foregroundStyle(Color.mycolor.myBlue)
                            VStack (spacing: 8) {
                                Text(post.title)
                                    .font(.headline)
                                    .minimumScaleFactor(0.75)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                
                                Text("@" + post.author)
                                    .font(.footnote)
                                    .lineLimit(1)
                            }
                            .foregroundStyle(Color.mycolor.myAccent)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top)
                            
                            ratingIconsView
                                .overlay(raringOverlayView.mask(ratingIconsView))
                                .padding(.vertical, 30)
                            
                            HStack (spacing: 20) {
                                if vm.selectedRating != nil {
                                    ClearCupsuleButton(
                                        primaryTitle: "Reset",
                                        primaryTitleColor: Color.mycolor.myRed) {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                vm.selectedRating = nil
                                            }
                                        }
                                        .frame(maxWidth: 200)
                                }
                                ClearCupsuleButton(
                                    primaryTitle: "Place",
                                    primaryTitleColor: Color.mycolor.myBlue) {
                                        vm.ratePost(post)
                                        completion()
                                    }
                                    .frame(maxWidth: 200)
                            }
                            .padding(.bottom)
                        } // VStack
                        .padding(20)
                    } // ZStack
                } //VStack
                .onAppear {
                    vm.selectedRating = post.postRating
                }
            } else {
                Text("No post found")
            }
        } // Group
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            .bar,
            in: RoundedRectangle(cornerRadius: 30))
        .scaleEffect(isShowingView ? 1.0 : 0.5)
        .opacity(isShowingView ? 1.0 : 0)
        .animation(.bouncy(duration: 0.3), value: isShowingView)
        .onAppear {
            isShowingView = true
        }
    }
    private var xmarkButton: some View {
        CircleStrokeButtonView(
            iconName: "xmark",
            isShownCircle: false
        ){
            withAnimation {
                completion()
            }
        }
    }
    
    private var ratingIconsView: some View {
        HStack(spacing: 20) {
            ForEach(PostRating.allCases, id: \.self) { rating in
                VStack(spacing: 8) {
                    rating.icon
                        .font(.largeTitle)
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                vm.selectedRating = rating
                            }
                        }
                    Text(rating.displayName)
                        .font(.caption)
                }
                .foregroundStyle(Color.mycolor.myAccent)
            }
        }
    }
    
    private var raringOverlayView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
//                    .foregroundColor(vm.selectedRating?.color ?? Color.mycolor.mySecondary)
//                    .fill(LinearGradient(gradient: Gradient(colors: [Color.mycolor.myBlue.opacity(0.3), Color.mycolor.myBlue]), startPoint: .leading, endPoint: .trailing))
                    .foregroundStyle(Color.mycolor.myBlue)
                    .frame(width: CGFloat(vm.selectedRating?.value ?? 0) / 3 * geometry.size.width)
            }
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppSyncState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    
    let vm = PostsViewModel(modelContext: context)
    
    RatingSelectionView() {}
        .environmentObject(vm)
}
