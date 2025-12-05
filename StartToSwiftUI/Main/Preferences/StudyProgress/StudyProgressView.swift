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
    
//    @State var studyLevel: StudyLevel = .beginner
    
    var body: some View {
        
        TabView {
            StudyProgressForLevel(studyLevel: nil)
                .tabItem {
                    Label("Total", systemImage: "1.circle")
                        .labelStyle(.titleOnly)
                }.tag(0)
            
            StudyProgressForLevel(studyLevel: .beginner)
                .tabItem {
                    Label("Beginner", systemImage: "2.circle")
                        .labelStyle(.titleOnly)
                }.tag(1)
            
            StudyProgressForLevel(studyLevel: .middle)
                .tabItem {
                    Label("Middle", systemImage: "3.circle")
                        .labelStyle(.titleOnly)
                }.tag(2)
            
            StudyProgressForLevel(studyLevel: .advanced)
                .tabItem {
                    Label("Advanced", systemImage: "4.circle")
                        .labelStyle(.titleOnly)
                }.tag(3)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .navigationTitle("Study progress")
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
