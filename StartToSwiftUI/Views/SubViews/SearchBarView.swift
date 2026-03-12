//
//  SearchBarView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 28.08.2025.
//

import SwiftUI

struct SearchBarView: View {
    
    @Binding var searchText: String
    
    @FocusState private var isFocusedOnSearchBar: Bool
    
    let offOpacity: Double = 0.5
    
    var body: some View {
        
        HStack (spacing: 0) {
            HStack(spacing: 0) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(
                        isFocusedOnSearchBar ? Color.mycolor.myAccent : Color.mycolor.mySecondary
                    )

                TextField("Search here ...", text: $searchText)
                    .foregroundStyle(Color.mycolor.myAccent)
                    .autocorrectionDisabled(true)
                    .frame(height: 35)
                    .focused($isFocusedOnSearchBar)
                    .submitLabel(.search)
                    .padding(.leading, isFocusedOnSearchBar ? 8 : 0)
                
                xmarkButton
            }
            .font(.body)
            .padding(.horizontal, 8)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .background(
                Capsule()
                    .stroke(
                        isFocusedOnSearchBar ? Color.mycolor.myBlue : Color.mycolor.mySecondary,
                        lineWidth: isFocusedOnSearchBar ? 5 : 1)
            )
//            .padding(.trailing)
            .padding(.vertical, 8)
        }
        .animation(.easeInOut, value: isFocusedOnSearchBar)
    }
    
    private var xmarkButton: some View {
        
        Image(systemName: "xmark")
            .imageScale(.large)
            .foregroundStyle(Color.mycolor.myRed)
            .padding(.horizontal, 6)
            .background(.black.opacity(0.001))
            .opacity(isFocusedOnSearchBar ? 1 : 0)
            .onTapGesture {
                isFocusedOnSearchBar = false
                searchText = ""
            }
    }
}

#Preview {
    
    @Previewable @State var searchText = ""
    ZStack {
        Color.pink.opacity(0.1)
            .ignoresSafeArea()
        SearchBarView(searchText: $searchText)
    }
    
}
