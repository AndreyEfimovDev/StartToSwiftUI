//
//  RatingMenuSelectionView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 06.12.2025.
//

import SwiftUI

struct RatingSelectionView: View {
    
    @EnvironmentObject private var vm: PostsViewModel
    
    @Binding var showRatingView: Bool
    
    var body: some View {
        Group {
            if showRatingView {
                if let post = vm.allPosts.first(where: { $0.id == vm.selectedPostId}) {
                    VStack {
                        ZStack(alignment: .topTrailing) {
                            CircleStrokeButtonView(
                                iconName: "xmark",
                                isShownCircle: false)
                            {
                                showRatingView = false
                            }
                            .padding(12)
                            .zIndex(1)
                            
                            VStack {
                                VStack (spacing: 8) {
                                    Text(post.title)
                                        .font(.headline)
                                        .minimumScaleFactor(0.75)
                                        .lineLimit(2)
                                    
                                    Text("@" + post.author)
                                        .font(.subheadline)
                                        .lineLimit(1)
                                }
                                .foregroundStyle(Color.mycolor.myAccent)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top)
                                
                                ratingIconsView
                                    .overlay(raringOverlayView.mask(ratingIconsView))
                                    .padding()
                                    .padding(.bottom, 30)
                                
                                HStack (spacing: 20) {
                                    ClearCupsuleButton(
                                        primaryTitle: "Place",
                                        primaryTitleColor: Color.mycolor.myBlue) {
                                            showRatingView = false
                                            vm.ratePost(post: post)
                                        }
                                    ClearCupsuleButton(
                                        primaryTitle: "Reset",
                                        primaryTitleColor: Color.mycolor.myRed) {
                                            vm.selectedRating = nil
                                            vm.ratePost(post: post)
                                        }
                                }
                            } // VStack
                            .padding(20)
                        } // ZStack
                    } //VStack
                    .background(
                        .ultraThinMaterial,
                        in: RoundedRectangle(cornerRadius: 30))
                } else {
                    Text("No post found")
                }
            }
        } // Group
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 30)
        .scaleEffect(showRatingView ? 1.0 : 0.5)
        .opacity(showRatingView ? 1.0 : 0)
        .animation(.bouncy(duration: 0.5), value: showRatingView)
    }
    
    private var ratingIconsView: some View {
        HStack(spacing: 20) {
            ForEach(PostRating.allCases, id: \.self) { rating in
                rating.icon
                    .font(.largeTitle)
                    .foregroundColor(Color.gray)
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            vm.selectedRating = rating
                        }
                    }
            }
        }
    }
    
    private var raringOverlayView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(vm.selectedRating?.color ?? .secondary)
                    .frame(width: CGFloat(vm.selectedRating?.value ?? 0) / 3 * geometry.size.width)
            }
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    RatingSelectionView(showRatingView: .constant(true))
        .environmentObject(PostsViewModel())
}
