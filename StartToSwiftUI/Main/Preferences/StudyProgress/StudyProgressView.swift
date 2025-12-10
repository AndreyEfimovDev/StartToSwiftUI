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
    
    @State private var selectedTab: StudyProgressTabs = .total
        
    private var tabs: [StudyProgressTabs] {
            [.total, .beginner, .middle, .advanced]
        }

    var body: some View {
        
        VStack {
            
            if UIDevice.isiPad {
                Group {
                    Group {
                        switch selectedTab {
                        case .total:
                            StudyProgressForLevel(studyLevel: nil)
                        case .beginner:
                            StudyProgressForLevel(studyLevel: .beginner)
                        case .middle:
                            StudyProgressForLevel(studyLevel: .middle)
                        case .advanced:
                            StudyProgressForLevel(studyLevel: .advanced)
                        }
                    }
                    .transition(.opacity)
                    .animation(.bouncy(duration: 0.3), value: selectedTab)
                    .padding(.horizontal, 50)
                    
                    UnderlineSermentedPickerNotOptional(
                        selection: $selectedTab,
                        allItems: StudyProgressTabs.allCases,
                        titleForCase: { $0.displayName },
                        selectedFont: .caption,
                        selectedTextColor: Color.mycolor.myBlue,
                        unselectedTextColor: Color.mycolor.mySecondary
                    )
                    .padding(.horizontal, 50)
                    .padding(.bottom, 30)
                }

            } else {
                TabView (selection: $selectedTab) {
                    ForEach(tabs, id: \.self) { tab in
                        StudyProgressForLevel(studyLevel: tab.studyLevel)
                            .tag(tab)
                    }
                }
                .padding(.bottom, 30)
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
