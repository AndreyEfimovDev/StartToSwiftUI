//
//  FavoriteButton.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 28.08.2025.
//

import SwiftUI

struct FavoriteButton: View {
    
    let isFavorite: FavoriteChoice
    let action: () -> Void
    
    var body: some View {
        
        Button {
            action()
        } label: {
            Image(systemName: isFavorite == .yes ? "star.fill" : "star")
                .font(.body)
                .foregroundStyle(isFavorite == .yes ? Color.mycolor.yellow : Color.mycolor.secondaryText)
//                .frame(width: 30, height: 30)
        }
        .padding(8)
    }
}

#Preview {
    ZStack {
        Color.pink.opacity(0.1)
            .ignoresSafeArea()
        VStack {
            FavoriteButton(isFavorite: FavoriteChoice.yes) {}
            FavoriteButton(isFavorite: FavoriteChoice.no) {}

        }
    }
}
