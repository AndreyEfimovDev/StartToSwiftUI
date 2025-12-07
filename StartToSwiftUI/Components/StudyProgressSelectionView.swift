//
//  StudyProgressSelectionView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 07.12.2025.
//

import SwiftUI

struct StudyProgressSelectionView: View {
    
    @EnvironmentObject private var vm: PostsViewModel
    
    @Binding var showStudyProgressSelectionView: Bool
    
    var body: some View {
        Group {
            if showStudyProgressSelectionView {
                if let post = vm.allPosts.first(where: { $0.id == vm.selectedPostId}) {
                    VStack {
                        ZStack(alignment: .topTrailing) {
                            CircleStrokeButtonView(
                                iconName: "xmark",
                                isShownCircle: false)
                            {
                                showStudyProgressSelectionView = false
                            }
                            .padding(12)
                            .zIndex(1)
                            
                            VStack {
                                Text("Set Study Progress")
                                    .font(.headline)
                                    .foregroundStyle(Color.mycolor.myBlue)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                
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
                                
                                UnderlineSermentedPickerNotOptional(
                                    selection: $vm.selectedStudyProgress,
                                    allItems: StudyProgress.allCases,
                                    titleForCase: { $0.displayName },
                                    selectedFont: .caption2,
                                    selectedTextColor: Color.mycolor.myGreen,
                                    unselectedTextColor: Color.mycolor.mySecondary
                                )
                                .padding(.vertical)

                                ClearCupsuleButton(
                                    primaryTitle: "Place",
                                    primaryTitleColor: Color.mycolor.myBlue) {
                                        showStudyProgressSelectionView = false
                                        vm.updatePostStudyProgress(post: post)
                                    }
                                    .padding(.horizontal)
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
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 30)
        .scaleEffect(showStudyProgressSelectionView ? 1.0 : 0.5)
        .opacity(showStudyProgressSelectionView ? 1.0 : 0)
        .animation(.bouncy(duration: 0.5), value: showStudyProgressSelectionView)
    }
}

#Preview {
    StudyProgressSelectionView(showStudyProgressSelectionView: .constant(true))
        .environmentObject(PostsViewModel())
}
