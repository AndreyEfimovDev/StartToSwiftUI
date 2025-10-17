//
//  SearchBarView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 28.08.2025.
//

import SwiftUI

struct SearchBarView: View {
    
    @FocusState private var isFocusedOnSearchBar: Bool
    
    @Binding var searchText: String
    
    var body: some View {
        
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(
                    searchText.isEmpty ? Color.mycolor.secondaryText : Color.mycolor.accent
                )
            TextField("Search here ...", text: $searchText)
                .foregroundStyle(Color.mycolor.accent)
                .autocorrectionDisabled(true)
                .frame(height: isFocusedOnSearchBar ? 40 : 20)
                .focused($isFocusedOnSearchBar)
                .submitLabel(.search)
                .overlay(
                    Image(systemName: "xmark")
                        .imageScale(.large)
                        .foregroundStyle(Color.mycolor.red)
                        .frame(width: 55, height: isFocusedOnSearchBar ? 55 : 35)
                        .background(.black.opacity(0.001))
                        .offset(x: 8)
                        .opacity(isFocusedOnSearchBar ? 1 : 0)
                        .onTapGesture {
                            isFocusedOnSearchBar = false
                            searchText = ""
                        }
                    , alignment: .trailing
                )
        }
        .font(.body)
        .padding(8)
        .background(
            ZStack {
//                Capsule()
//                    .fill(.ultraThickMaterial)
                Capsule()
                    .stroke(
                        searchText.isEmpty ? Color.mycolor.accent.opacity(0.3) : Color.mycolor.accent,
                        lineWidth: 1
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
        VStack {
            SearchBarView(searchText: .constant(""))
            SearchBarView(searchText: .constant("sample text types "))
        }
    }
}
