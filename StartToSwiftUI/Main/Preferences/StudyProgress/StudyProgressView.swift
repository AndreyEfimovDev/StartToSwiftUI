//
//  StudyProgressView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 04.12.2025.
//

import SwiftUI

struct StudyProgressView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: PostsViewModel
    
    @State private var selectedTab: StudyLevelTabs = .all
        
    private var tabs: [StudyLevelTabs] {
            [.all, .beginner, .middle, .advanced]
        }

    var body: some View {
        Group {
            if UIDevice.isiPad {
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
                    
                    UnderlineSermentedPickerNotOptional(
                        selection: $selectedTab,
                        allItems: StudyLevelTabs.allCases,
                        titleForCase: { $0.displayName },
                        selectedFont: .headline,
                        selectedTextColor: Color.mycolor.myBlue,
                        unselectedTextColor: Color.mycolor.mySecondary
                    )
                    .padding(.horizontal)
                    .padding(.top)
                }
                .padding()
            } else {
                TabView (selection: $selectedTab) {
                    ForEach(tabs, id: \.self) { tab in
                        StudyProgressForLevel(studyLevel: tab.studyLevel)
                            .tag(tab)
                            .padding(.top)
                            .padding(.bottom, 50)
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButtonView() { dismiss() }
            }
        }
    }
}

#Preview {
    NavigationStack{
        StudyProgressView()
            .environmentObject(PostsViewModel())
    }
}
