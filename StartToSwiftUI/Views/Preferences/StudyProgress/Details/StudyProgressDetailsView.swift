//
//  StudyProgressView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 04.12.2025.
//

import SwiftUI
import SwiftData

struct StudyProgressDetailsView: View {
    
    //    @EnvironmentObject private var vm: PostsViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    
    @State private var selectedTab: StudyLevelTabs = .all
    
    private var tabs: [StudyLevelTabs] {
        [.all, .beginner, .middle, .advanced]
    }
    
    var body: some View {
        //            Group {
        //            if UIDevice.isiPad {
        VStack(spacing: 0)  {
            Group {
                switch selectedTab {
                case .all:
                    StudyProgressForLevel(studyLevel: nil)
                        .opacity(selectedTab == .all ? 1 : 0)
                case .beginner:
                    StudyProgressForLevel(studyLevel: .beginner)
                        .opacity(selectedTab == .beginner ? 1 : 0)
                case .middle:
                    StudyProgressForLevel(studyLevel: .middle)
                        .opacity(selectedTab == .middle ? 1 : 0)
                case .advanced:
                    StudyProgressForLevel(studyLevel: .advanced)
                        .opacity(selectedTab == .advanced ? 1 : 0)
                }
            }
            .transition(.slide)
            .animation(.linear(duration: 0.3), value: selectedTab)
            
            Spacer()
            
            UnderlineSermentedPickerNotOptional(
                selection: $selectedTab,
                allItems: StudyLevelTabs.allCases,
                titleForCase: { $0.displayName },
                selectedFont: UIDevice.isiPad ? .headline : .subheadline
            )
            .padding(.horizontal)
            .padding(.top)
        }
        .padding()
        //            } else {
        //                TabView (selection: $selectedTab) {
        //                    ForEach(tabs, id: \.self) { tab in
        //                        StudyProgressForLevel(studyLevel: tab.studyLevel)
        //                            .tag(tab)
        //                            .padding(.top)
        //                            .padding(.bottom, 50)
        //                    }
        //                }
        //                .tabViewStyle(.page)
        //                .indexViewStyle(.page(backgroundDisplayMode: .always))
        //            }
        //            }
        //        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppSyncState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    
    let vm = PostsViewModel(modelContext: context)
    
    NavigationStack{
        StudyProgressDetailsView()
            .environmentObject(vm)
            .environmentObject(AppCoordinator())
    }
}
