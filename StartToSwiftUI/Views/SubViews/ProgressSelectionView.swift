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
    
    let completion: () -> Void
    
    private let selectionColor: Color = Color.mycolor.myGreen
    
    init(completion: @escaping () -> Void) {
        self.completion = completion
    }
    
    var body: some View {
        Group {
            if let post = vm.selectedPost {
                VStack {
                    ZStack(alignment: .topTrailing) {
                        xmarkButton
                            .padding()
                            .zIndex(1)
                        VStack {
                            header(post)
                            progressSelector
                            bottomPlaceButton(post)
                        }
                        .padding(.vertical, 20)
                    }
                }
                .onAppear {
                    vm.selectedStudyProgress = post.progress
                }
            } else {
                VStack{
                    xmarkButton
                    Text("No post found")
                        .padding()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            .bar,
            in: RoundedRectangle(cornerRadius: 30))
    }
    
    @ViewBuilder
    private func header(_ post: Post) -> some View {
        Text("Update Progress")
            .font(.title3).bold()
            .foregroundStyle(selectionColor)
        VStack (spacing: 8) {
            Text(post.title)
                .font(.headline)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            
            Text("@" + post.author)
                .font(.footnote)
                .lineLimit(1)
        }
        .foregroundStyle(Color.mycolor.myAccent)
        .frame(maxWidth: .infinity)
        .padding(.top)

    }
    
    private var progressSelector: some View {
        VStack {
            HStack {
                ForEach(StudyProgress.allCases, id:\.self) { item in
                    let isSelected = vm.selectedStudyProgress == item
                    item.icon
                        .font(.caption)
                        .foregroundStyle(isSelected ? selectionColor : Color.mycolor.myAccent)
                        .fontWeight(isSelected ? .bold : .regular)
                        .frame(maxWidth: .infinity)
                }
            }
            
            UnderlineSermentedPickerNotOptional(
                selection: $vm.selectedStudyProgress,
                allItems: StudyProgress.allCases,
                titleForCase: { $0.displayName },
                selectedFont: .caption,
                selectedTextColor: selectionColor,
                unselectedTextColor: Color.mycolor.myAccent
            )
        }
        .padding(30)
    }
    
    @ViewBuilder
    private func bottomPlaceButton(_ post: Post) -> some View {
        ClearCupsuleButton(
            primaryTitle: "Place",
            primaryTitleColor: Color.mycolor.myBlue) {
                vm.updatePostStudyProgress(post)
                completion()
            }
            .padding(.horizontal)
            .frame(maxWidth: 200)
            .padding(.bottom)
    }
    
    private var xmarkButton: some View {
        CircleStrokeButtonView(
            iconName: "xmark",
            isShownCircle: false
        ){
                completion()
        }
    }

}

#Preview("Valid post") {
    let vm: PostsViewModel = {
        let vm = PostsViewModel(dataSource: MockPostsDataSource(posts: PreviewData.samplePosts))
        vm.start()
        vm.selectedPost = PreviewData.samplePost1
        return vm
    }()
    
    ProgressSelectionView() {}
        .environmentObject(vm)
}
