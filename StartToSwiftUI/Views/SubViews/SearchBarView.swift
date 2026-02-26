//
//  SearchBarView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 28.08.2025.
//

import SwiftUI
import SwiftData
//import Speech

struct SearchBarView: View {
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var vm: PostsViewModel
    
    @FocusState private var isFocusedOnSearchBar: Bool
    
    let offOpacity: Double = 0.5
    
    var body: some View {
        
        HStack (spacing: 0) {
            HStack(spacing: 0) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(
                        isFocusedOnSearchBar ? Color.mycolor.myAccent : Color.mycolor.mySecondary
                    )

                TextField("Search here ...", text: $vm.searchText)
                    .foregroundStyle(Color.mycolor.myAccent)
                    .autocorrectionDisabled(true)
                    .frame(height: isFocusedOnSearchBar ? 50 : 35)
                    .focused($isFocusedOnSearchBar)
                    .submitLabel(.search)
                    .padding(.leading, isFocusedOnSearchBar ? 8 : 0)
                
                xmarkButton
            }
            .font(.body)
            .padding(.leading, 8)
            .padding(.trailing, isFocusedOnSearchBar ? 0 : 8)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .background(
                ZStack {
                    Capsule()
                        .stroke(
                            isFocusedOnSearchBar ? Color.mycolor.myBlue : Color.mycolor.mySecondary,
                            lineWidth: isFocusedOnSearchBar ? 5 : 1
                        )
                }
            )
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .animation(.easeInOut, value: isFocusedOnSearchBar)
    }
    
    
    private var xmarkButton: some View {
        
        Image(systemName: "xmark")
            .imageScale(.large)
            .foregroundStyle(Color.mycolor.myRed)
            .padding(isFocusedOnSearchBar ? 15 : 0)
            .background(.black.opacity(0.001))
            .opacity(isFocusedOnSearchBar ? 1 : 0)
            .onTapGesture {
                isFocusedOnSearchBar = false
                vm.searchText = ""
            }
    }
//    
//    private func removeDoubleSpaces(_ string: String) -> String {
//        return string.replacingOccurrences(of: "  ", with: " ")
//    }
}

#Preview {
    
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppSyncState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    
    let vm = PostsViewModel(modelContext: context)
    
    ZStack {
        Color.pink.opacity(0.1)
            .ignoresSafeArea()
        SearchBarView()
            .environmentObject(vm)
    }
    
}
