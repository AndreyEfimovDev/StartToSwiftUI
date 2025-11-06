//
//  SearchBarView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 28.08.2025.
//

import SwiftUI

struct SearchBarView: View {
    
    @EnvironmentObject private var vm: PostsViewModel

    @FocusState private var isFocusedOnSearchBar: Bool
    
    var body: some View {
        
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(
                    vm.searchText.isEmpty ? Color.mycolor.mySecondaryText : Color.mycolor.myAccent
                )
            TextField("Search here ...", text: $vm.searchText)
                .foregroundStyle(Color.mycolor.myAccent)
                .autocorrectionDisabled(true)
                .keyboardType(.asciiCapable)
                .frame(height: isFocusedOnSearchBar ? 40 : 20)
                .focused($isFocusedOnSearchBar)
                .submitLabel(.search)
                .overlay(
                    Image(systemName: "xmark")
                        .imageScale(.large)
                        .foregroundStyle(Color.mycolor.myRed)
                        .frame(width: 55, height: isFocusedOnSearchBar ? 55 : 35)
                        .background(.black.opacity(0.001))
                        .offset(x: 8)
                        .opacity(isFocusedOnSearchBar ? 1 : 0)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isFocusedOnSearchBar = false
                                vm.searchText = ""
                            }
                        }
                    , alignment: .trailing
                )
        }
        .font(.body)
        .padding(8)
        .background(
            ZStack {
                Capsule()
                    .stroke(
                        !isFocusedOnSearchBar ? Color.mycolor.myAccent.opacity(0.3) : Color.mycolor.myBlue,
                        lineWidth: !isFocusedOnSearchBar ? 1 : 3
                    )
            }
        )
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
        .background(.ultraThickMaterial)
    }
}

#Preview {
    ZStack {
        Color.pink.opacity(0.1)
            .ignoresSafeArea()
            SearchBarView()
    }
    .environmentObject(PostsViewModel())

}
