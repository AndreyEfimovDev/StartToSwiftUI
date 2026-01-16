//
//  StudyProgressSelectionView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 07.12.2025.
//

import SwiftUI
import SwiftData

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
                            isShownCircle: false) {
                                withAnimation {
                                    completion()
                                }
                            }
                        .padding()
                        .zIndex(1)
                        
                        VStack {
                            Text("Update Progress")
                                .font(.title3).bold()
                                .foregroundStyle(Color.mycolor.myGreen)
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
                            
                            UnderlineSermentedPickerNotOptional(
                                selection: $vm.selectedStudyProgress,
                                allItems: StudyProgress.allCases,
                                titleForCase: { $0.displayName },
                                selectedFont: .caption2,
                                selectedTextColor: Color.mycolor.myGreen,
                                unselectedTextColor: Color.mycolor.myAccent
                            )
                            .padding(30)
                            
                            ClearCupsuleButton(
                                primaryTitle: "Place",
                                primaryTitleColor: Color.mycolor.myBlue) {
                                    vm.updatePostStudyProgress(post: post)
                                    completion()
                                }
                                .padding(.horizontal)
                                .frame(maxWidth: 200)
                                .padding(.bottom)
                        } // VStack
                        .padding(20)
                    } // ZStack
                } //VStack
                .onAppear {
                    vm.selectedStudyProgress = post.progress
                }
            } else {
                Text("No post found")
            }
        } // Group
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 30))
        .scaleEffect(isShowingView ? 1.0 : 0.5)
        .opacity(isShowingView ? 1.0 : 0)
        .animation(.bouncy(duration: 0.3), value: isShowingView)
        .onAppear {
            isShowingView = true
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppSyncState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    
    let vm = PostsViewModel(modelContext: context)
    
    ProgressSelectionView() {}
        .environmentObject(vm)
}
