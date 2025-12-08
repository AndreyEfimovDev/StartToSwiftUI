//
//  StudyProgressSelectionView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 07.12.2025.
//

import SwiftUI

struct ProgressSelectionView: View {
    
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
                            CircleStrokeButtonView(
                                iconName: "xmark",
                                isShownCircle: false)
                            {
                                completion()
                            }
                            .padding(12)
                            .zIndex(1)
                            
                            VStack {
                                Text("Set Study Progress")
                                    .font(.title3).bold()
                                    .foregroundStyle(Color.mycolor.myGreen)
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
                                    selectedFont: .callout,
                                    selectedTextColor: Color.mycolor.myGreen,
                                    unselectedTextColor: Color.mycolor.mySecondary
                                )
                                .padding(.bottom, 30)

                                ClearCupsuleButton(
                                    primaryTitle: "Place",
                                    primaryTitleColor: Color.mycolor.myBlue) {
                                        vm.updatePostStudyProgress(post: post)
                                        completion()
                                    }
                                    .padding(.horizontal)
                                    .frame(maxWidth: 200)
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
        } // Group
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 30)
        .scaleEffect(isShowingView ? 1.0 : 0.5)
        .opacity(isShowingView ? 1.0 : 0)
        .animation(.bouncy(duration: 0.5), value: isShowingView)
        .onAppear {
            isShowingView = true
        }
    }
}

#Preview {
    ProgressSelectionView() {}
        .environmentObject(PostsViewModel())
}
